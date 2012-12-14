/*
 * linux/drivers/video/uc1698fb.c -- FB driver for uc1698fb display
 *
 * Copyright (C) 2007, Ico Doornekamp
 * Based on the Hecuba driver
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License. See the file COPYING in the main directory of this archive for
 * more details.
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/string.h>
#include <linux/mm.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/fb.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/list.h>
#include <linux/display.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include <mach/gpio.h>
#include <mach/at91_pio.h>
#include <mach/hardware.h>

#define DPY_W 240
#define DPY_H 128
#define VIDEOMEMORYSIZE (DPY_W * DPY_H * 4)
#define REFRESH_RATE (HZ/8)

struct uc1698fb_par {
	struct fb_info *info;
	struct display_device *dsp;
	int contrast;
};

static struct fb_fix_screeninfo uc1698fb_fix __devinitdata = {
	.id =		"uc1698fb",
	.type =		FB_TYPE_PACKED_PIXELS,
	.visual =	FB_VISUAL_TRUECOLOR,
	.xpanstep =	0,
	.ypanstep =	0,
	.ywrapstep =	0,
	.line_length =	DPY_W * 4,
	.accel =	FB_ACCEL_NONE,
};

static struct fb_var_screeninfo uc1698fb_var __devinitdata = {
	.xres		= DPY_W,
	.yres		= DPY_H,
	.xres_virtual	= DPY_W,
	.yres_virtual	= DPY_H,
	.bits_per_pixel	= 32,
	.nonstd		= 0,

};

static struct platform_device *uc1698fb_device;
static uint8_t cmap[256];

#define PIN_TO_MASK(pin) (1 << ((pin - PIN_BASE) % 32))

#define MASK_SDA	0x00800000
#define MASK_SCK	0x02000000
#define MASK_CD		0x08000000
#define MASK_CS		0x20000000
#define MASK_RST	0x80000000

/* Pins used for SPI bus */

#define PIN_SDA AT91_PIN_PC23
#define PIN_SCK AT91_PIN_PC25
#define PIN_CD  AT91_PIN_PC27
#define PIN_CS  AT91_PIN_PC29
#define PIN_RST AT91_PIN_PC31

/* uc1698 registers */

#define LCD_SET_COLUMN_ADDRESS_LSB		0x00 // 00000000
#define LCD_SET_COLUMN_ADDRESS_MSB		0x10 // 00010000
#define LCD_SET_ADVANCED_PROGRAM_CONTROL 	0x30 // 00110000
#define LCD_SET_TEMP_COMPENSATION		0x24 // 00100100
#define LCD_SET_POWER_CONTROL			0x28 // 00101000
#define LCD_SET_SCROLL_LINE_LSB			0x40 // 01000000
#define LCD_SET_SCROLL_LINE_MSB			0x50 // 01010000
#define LCD_SET_ROW_ADDRESS_LSB			0x60 // 01100000
#define LCD_SET_ROW_ADDRESS_MSB			0x70 // 01110000
#define LCD_SET_VBIAS_POTENTIOMETER		0x81 // 10000001
#define LCD_SET_PARTIAL_DISPLAY_CONTROL		0x84 // 10000100
#define LCD_SET_RAM_ADDRESS_CONTROL		0x88 // 10001000
#define LCD_SET_FIXED_LINES			0x90 // 10001000
#define LCD_SET_LINE_RATE			0xa0 // 10100000
#define LCD_SET_ALL_PIXEL_ON			0xa4 // 10100100
#define LCD_SET_INVERSE_DISPLAY			0xa6 // 10100110
#define LCD_SET_DISPLAY_ENABLE			0xa8 // 10101000
#define LCD_SET_LCD_MAPPING_CONTROL		0xc0 // 11000000
#define LCD_SET_N_LINE_INVERSION		0xc8 // 11001000
#define LCD_SET_COLOR_PATTERN			0xd0 // 11010000
#define LCD_SET_COLOR_MODE			0xd4 // 11010100
#define LCD_SET_COM_SCAN_FUNCTION		0xd8 // 11011000
#define LCD_SYSTEM_RESET 			0xe2 // 11100010
#define LCD_NOP					0xe3 // 11100011
#define LCD_SET_BIAS_RATIO			0xe8 // 11101000
#define LCD_SET_COM_END				0xf1 // 11110001
#define LCD_SET_PARTIAL_DISPLAY_START		0xf2 // 11110010
#define LCD_SET_PARTIAL_DISPLAY_END		0xf3 // 11110011
#define LCD_SET_WINDOW_PROGRAM_START_COL	0xf4 // 11110100
#define LCD_SET_WINDOW_PROGRAM_START_ROW	0xf5 // 11110101
#define LCD_SET_WINDOW_PROGRAM_END_COL		0xf6 // 11110110
#define LCD_SET_WINDOW_PROGRAM_END_ROW		0xf7 // 11110111
#define LCD_SET_WINDOW_PROGRAM_MODE		0xf8 // 11110111

/* Default register initialisation */

#define LCD_VAL_CEN				159  // COM scan end
#define LCD_VAL_DST				0    // Display start com
#define LCD_VAL_DEN				159  // Display end com
#define LCD_VAL_XSTRCOL				0
#define LCD_VAL_XENDCOL				127
#define LCD_VAL_XSTRROW				0
#define LCD_VAL_XENDROW				159
#define LCD_VAL_VBIAS				140
#define COLUMNDEF				24

void __iomem *pio_set;
void __iomem *pio_clr;

static void clock_byte(u8 cd, u8 data)
{
	int i;
	u16 val = (cd << 8) | data;

	__raw_writel(MASK_CS, pio_clr);
	for(i=0; i<9; i++) {
		__raw_writel(MASK_SCK, pio_clr);
		if(val & 0x100) {
			__raw_writel(MASK_SDA, pio_set);
		} else {
			__raw_writel(MASK_SDA, pio_clr);
		}
		val <<= 1;
		__raw_writel(MASK_SCK, pio_set);
	}
	__raw_writel(MASK_CS, pio_set);
}


static void wr_command(u8 command)
{       
	clock_byte(0, command);
} 


static void wr_data(u8 data)
{       
	clock_byte(1, data);
} 


static void __devinit lcd_init(struct uc1698fb_par *par)
{
	/* Configure pins */

	at91_set_gpio_output(PIN_SDA, 1);
	at91_set_gpio_output(PIN_SCK, 1);
	at91_set_gpio_output(PIN_CD,  1);
	at91_set_gpio_output(PIN_CS,  1);
	at91_set_gpio_output(PIN_RST, 1);

	pio_set = AT91_PIOC + (void * __iomem) AT91_VA_BASE_SYS + PIO_SODR;
	pio_clr = AT91_PIOC + (void * __iomem) AT91_VA_BASE_SYS + PIO_CODR;

	/* Hard reset */

	at91_set_gpio_value(PIN_RST, 1);
	mdelay(150);
	at91_set_gpio_value(PIN_RST, 0);
	at91_set_gpio_value(PIN_CD, 0);

	/* Soft reset */

	wr_command(LCD_SYSTEM_RESET);
	mdelay(150);

	/* Initialize LCD parameters */

	wr_command(LCD_SET_TEMP_COMPENSATION | 1);
	wr_command(LCD_SET_POWER_CONTROL | 0x03);
	wr_command(LCD_SET_ADVANCED_PROGRAM_CONTROL | 1); wr_command(0x08);
	wr_command(LCD_SET_VBIAS_POTENTIOMETER); wr_command(par->contrast);
	wr_command(LCD_SET_PARTIAL_DISPLAY_CONTROL);
	wr_command(LCD_SET_RAM_ADDRESS_CONTROL | 0x01);
	wr_command(LCD_SET_SCROLL_LINE_MSB);
	wr_command(LCD_SET_COLUMN_ADDRESS_LSB | 0x11);
	wr_command(LCD_SET_LINE_RATE | 0x00);
	wr_command(LCD_SET_LCD_MAPPING_CONTROL | 0x04);
	wr_command(LCD_SET_N_LINE_INVERSION); wr_command(0x00 |0x05);

	wr_command(LCD_SET_COLOR_PATTERN | 0x01);
	wr_command(LCD_SET_COLOR_MODE | 0x01);
	wr_command(LCD_SET_COM_SCAN_FUNCTION | 0x00);
	wr_command(LCD_SET_BIAS_RATIO | 0x01); 
	wr_command(LCD_SET_INVERSE_DISPLAY | 0x01);

	/* Set geometry */

	wr_command(LCD_SET_COM_END); wr_command(LCD_VAL_CEN);
	wr_command(LCD_SET_PARTIAL_DISPLAY_START); wr_command(LCD_VAL_DST);
	wr_command(LCD_SET_PARTIAL_DISPLAY_END); wr_command(LCD_VAL_DEN);
	wr_command(LCD_SET_WINDOW_PROGRAM_START_COL); wr_command(LCD_VAL_XSTRCOL);
	wr_command(LCD_SET_WINDOW_PROGRAM_END_COL);   wr_command(LCD_VAL_XENDCOL);
	wr_command(LCD_SET_WINDOW_PROGRAM_START_ROW); wr_command(LCD_VAL_XSTRROW); 
	wr_command(LCD_SET_WINDOW_PROGRAM_END_ROW);   wr_command(LCD_VAL_XENDROW);  
	wr_command(LCD_SET_WINDOW_PROGRAM_MODE | 0x00); 
	wr_command(LCD_SET_DISPLAY_ENABLE | 0x07);
}


static void uc1698fb_dpy_update(struct uc1698fb_par *par)
{
	u8 *buf = (unsigned char __force *)par->info->screen_base;
	u32 *pin, c;
	int x, y;
	int i, j;

	//printk("update start\n");

	wr_command(LCD_SET_COLUMN_ADDRESS_LSB | ((COLUMNDEF >> 0) & 0xf));
        wr_command(LCD_SET_COLUMN_ADDRESS_MSB | ((COLUMNDEF >> 4) & 0xf));
	wr_command(LCD_SET_ROW_ADDRESS_LSB | 0);
	wr_command(LCD_SET_ROW_ADDRESS_MSB | 0);

	pin = buf;

	for(y=0; y<DPY_H; y++) {
		for(x=0; x<384; x+=2) {
			c = 0;
			if(x<DPY_W) {
				c |= ((*pin++ >> 4) & 0x0f) << 4;
				c |= ((*pin++ >> 4) & 0x0f);
			}
			c ^= 0xff;
			wr_data(c);
		}
	}
}



static void uc1698fb_fillrect(struct fb_info *info, const struct fb_fillrect *rect)
{
	struct uc1698fb_par *par = info->par;
	sys_fillrect(info, rect);
	uc1698fb_dpy_update(par);
}


static void uc1698fb_copyarea(struct fb_info *info, const struct fb_copyarea *area)
{
	struct uc1698fb_par *par = info->par;
	sys_copyarea(info, area);
	uc1698fb_dpy_update(par);
}


static void uc1698fb_imageblit(struct fb_info *info, const struct fb_image *image)
{
	struct uc1698fb_par *par = info->par;
	sys_imageblit(info, image);
	uc1698fb_dpy_update(par);
}


static ssize_t uc1698fb_write(struct fb_info *info, const char __user *buf, size_t count, loff_t *ppos)
{
	unsigned long p;
	int err = -EINVAL;
	struct uc1698fb_par *par;

	p = *ppos;
	par = info->par;

	if (p > VIDEOMEMORYSIZE)
		return -ENOSPC;

	err = 0;
	if ((count + p) > VIDEOMEMORYSIZE) {
		count = VIDEOMEMORYSIZE - p;
		err = -ENOSPC;
	}

	if (count) {
		char *base_addr;

		base_addr = (char __force *)info->screen_base;
		count -= copy_from_user(base_addr + p, buf, count);
		*ppos += count;
		err = -EFAULT;
	}


	uc1698fb_dpy_update(par);

	if (count)
		return count;

	return err;
}


static int uc1698fb_check_var(struct fb_var_screeninfo *var, struct fb_info *info)
{
	var->xres = info->var.xres;	
	var->yres = info->var.yres;	
	var->xres_virtual = info->var.xres;	
	var->yres_virtual = info->var.yres;	
	var->bits_per_pixel = info->var.bits_per_pixel;

	return 0;
}

static int uc1698fb_setcolreg(u_int regno, u_int red, u_int green, u_int blue,
		                   u_int trans, struct fb_info *info)
{
	if(regno < 256) {
		cmap[regno] = (19595 * red + 38470 * green + 7471 * blue) >> 28;
	}

	return 1;
}

static int uc1698fb_blank(int blank, struct fb_info *info)
{
	return 0;
}


static struct fb_ops uc1698fb_ops = {
	.owner		= THIS_MODULE,
	.fb_write	= uc1698fb_write,
	.fb_fillrect	= uc1698fb_fillrect,
	.fb_copyarea	= uc1698fb_copyarea,
	.fb_imageblit	= uc1698fb_imageblit,
	.fb_check_var	= uc1698fb_check_var,
	.fb_setcolreg	= uc1698fb_setcolreg,
	.fb_blank	= uc1698fb_blank,
};


static void uc1698fb_dpy_deferred_io(struct fb_info *info, struct list_head *pagelist)
{
	uc1698fb_dpy_update(info->par);
}


static struct fb_deferred_io uc1698fb_defio = {
	.delay		= REFRESH_RATE,
	.deferred_io	= uc1698fb_dpy_deferred_io,
};




int uc1698fb_display_set_contrast(struct display_device *dsp, unsigned int contrast)
{
	struct uc1698fb_par *par = dsp->priv_data;

	wr_command(LCD_SET_VBIAS_POTENTIOMETER); wr_command(contrast);
	par->contrast = contrast;
	return 0;
}


int uc1698fb_display_get_contrast(struct display_device *dsp)
{
	struct uc1698fb_par *par = dsp->priv_data;
	return par->contrast;
}


int uc1698fb_display_probe(struct display_device *dsp, void *devdata)
{
	return 1;
}


int uc1698fb_display_remove(struct display_device *dsp)
{
	return 0;
}

static struct display_driver uc1698fb_display_driver = {
	.set_contrast = uc1698fb_display_set_contrast,
	.get_contrast = uc1698fb_display_get_contrast,
	.max_contrast = 255,
	.probe = uc1698fb_display_probe,
	.remove = uc1698fb_display_remove,
};


static int __devinit uc1698fb_probe(struct platform_device *dev)
{
	struct fb_info *info;
	int retval = -ENOMEM;
	unsigned char *videomemory;
	struct uc1698fb_par *par;
	int i;
	int x, y;
	u32 *p;

	if (!(videomemory = vmalloc(VIDEOMEMORYSIZE)))
		return retval;

	info = framebuffer_alloc(sizeof(struct uc1698fb_par), &dev->dev);
	if (!info)
		goto err;

	info->screen_base = (char __iomem *) videomemory;
	info->fbops = &uc1698fb_ops;

	info->var = uc1698fb_var;
	info->fix = uc1698fb_fix;
	info->fix.smem_len = VIDEOMEMORYSIZE;
	par = info->par;
	par->info = info;
	par->contrast = LCD_VAL_VBIAS;
	
	info->flags = FBINFO_FLAG_DEFAULT;
	info->fbdefio = &uc1698fb_defio;
	fb_deferred_io_init(info);

	for(i=0; i<256; i++) cmap[i] = i >> 4;

	retval = register_framebuffer(info);
	if (retval < 0) goto err2;

	platform_set_drvdata(dev, info);

	par->dsp = display_device_register(&uc1698fb_display_driver, &dev->dev, par);
	if(IS_ERR(par->dsp)) {
		printk("display_device_register failed\n");
		goto err2;
	}
	par->dsp->priv_data = par;
	par->dsp->name = "uc1698fb";

	printk(KERN_INFO
	       "fb%d: Mbarc frame buffer device, using %dK of video memory\n",
	       info->node, VIDEOMEMORYSIZE >> 10);

	lcd_init(par);

	p = videomemory;
	for(y=0; y<DPY_H; y++) {
		for(x=0; x<DPY_W; x++) {
			*p++ = (((x>>3)&1) ^ ((y>>3)&1)) ? 0xffffffff : 0x00000000;
		}
	}

	uc1698fb_dpy_update(par);

	return 0;

err2:
	fb_dealloc_cmap(&info->cmap);
	framebuffer_release(info);
err:
	vfree(videomemory);
	return retval;
}


static int __devexit uc1698fb_remove(struct platform_device *dev)
{
	struct fb_info *info = platform_get_drvdata(dev);
	struct uc1698fb_par *par;

	if (info) {
		par = info->par;
		fb_deferred_io_cleanup(info);
		fb_dealloc_cmap(&info->cmap);
		display_device_unregister(par->dsp);
		unregister_framebuffer(info);
		vfree((void __force *)info->screen_base);
		framebuffer_release(info);

		par = info->par;
	}

	return 0;
}


static struct platform_driver uc1698fb_driver = {
	.probe	= uc1698fb_probe,
	.remove = uc1698fb_remove,
	.driver	= {
		.name	= "uc1698fb",
	},
};


static int __init uc1698fb_init(void)
{
	int ret;

	ret = platform_driver_register(&uc1698fb_driver);
	if (!ret) {
		uc1698fb_device = platform_device_alloc("uc1698fb", 0);
		if (uc1698fb_device)
			ret = platform_device_add(uc1698fb_device);
		else
			ret = -ENOMEM;

		if (ret) {
			platform_device_put(uc1698fb_device);
			platform_driver_unregister(&uc1698fb_driver);
		}
	}
	return ret;

}


static void __exit uc1698fb_exit(void)
{
	platform_device_unregister(uc1698fb_device);
	platform_driver_unregister(&uc1698fb_driver);
}


module_init(uc1698fb_init);
module_exit(uc1698fb_exit);

MODULE_DESCRIPTION("fbdev driver for uc1698fb controller");
MODULE_AUTHOR("Ico Doornekamp");
MODULE_LICENSE("GPL");

