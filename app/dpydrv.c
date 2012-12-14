/*
 * Copyright © 2007 All Rights Reserved.
 */

#include <assert.h>
#include <SDL.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>
#include <time.h>
#include <gif_lib.h>
#include <unistd.h>
#include <linux/fb.h>
#include <sys/ioctl.h>
#include <SDL_syswm.h>
#include <SDL_image.h>
#include <ft2build.h>
#include FT_FREETYPE_H

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define UPDATE_FREQ 10.0
#define MAX_IMAGES 18
#define MAX_FRAMES 32

#define BARF(L, msg...) do { lua_pushnil(L); lua_pushfstring(L, msg); return 2; } while(0)

//#define DEBUG
#include "misc.h"

typedef struct {
	SDL_Rect rect; // x, y, w, h
	unsigned frame;
	unsigned nframes;
	double t_update;
	SDL_Surface *surf[MAX_FRAMES];
	double delay[MAX_FRAMES];
} Image;


struct dpydrv {

	lua_State *L;

	/* Geometry and color settings */
	struct fb_var_screeninfo vinfo;
	
	int w, h;
	char c;		/* Color mode, can be 'm' (mono) or 'c' (color) */

	/* SDL */
	
	int x, y;
	Uint32 color;
	Uint32 background_color;
	SDL_Surface *screen;
	double t_dirty;
	double t_refreshed;

	/* Freetype */
	
	FT_Library ft_library;
	FT_Face face;
	int font_loaded;
	int font_size;

	/* image[0] is reserved for use as text-layer */
	Image image[MAX_IMAGES];
};


static double hirestime(void)
{
	struct timespec tv;
	double now;

	clock_gettime(CLOCK_MONOTONIC, &tv);

	now = tv.tv_sec + (tv.tv_nsec) / 1.0E9;
	return now;
}


static int l_new(lua_State *L)
{
	struct dpydrv *dd;
	TRACE();

	dd = lua_newuserdata(L, sizeof *dd);
	if(dd == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, "Can't allocate dpydrv");
		return 2;
	}

	memset(dd, 0, sizeof *dd);
	luaL_getmetatable(L, "Dpydrv");
	lua_setmetatable(L, -2);

	return 1;
}


static int get_fb_info(struct dpydrv *dd)
{
	int fd = 0;
	memset( &(dd->vinfo), 0, sizeof(dd->vinfo) );
	
	fd = open("/dev/fb0", O_RDWR);
	if(fd<0) return -1; //BARF(L,"Error:Can't open /dev/fb0");

	if (ioctl(fd,FBIOGET_VSCREENINFO,&(dd->vinfo)))
	{
		close(fd);
		return -1;
		//BARF(L,"Error: reading variable information");
	}

	TRACE("/dev/fb0: xsize=%d,ysize=%d", dd->vinfo.xres, dd->vinfo.yres );
	close(fd);
	return 0;
}


static int l_open(lua_State *L)
{
	struct dpydrv *dd;
	dd = lua_touserdata(L, 1);

	// Parse arguments

	dd->w = lua_tonumber(L, 2);
	dd->h = lua_tonumber(L, 3);
	dd->c = lua_tonumber(L, 4);
	TRACE(" w=%d, h=%d", dd->w, dd->h);

	// Mute directfb
	setenv("DFBARGS", "quiet=info,no-banner", 1);

	// SDL
	if( SDL_Init(SDL_INIT_VIDEO) == -1 )
		BARF(L, "SDL_Init failed: %s", SDL_GetError());

//	if( SDL_InitSubSystem(SDL_INIT_VIDEO | SDL_INIT_NOPARACHUTE) != 0 )
//		BARF(L, "SDL_InitSubSystem failed: %s", SDL_GetError());

	if( get_fb_info(dd) == 0 && (dd->w != dd->vinfo.xres || dd->h != dd->vinfo.yres) )
	{
		TRACE("Actual display dimensions differ from choosen dimensions");
		TRACE("Changing w from %d to %d, h from %d to %d", dd->w, dd->vinfo.xres, dd->h, dd->vinfo.yres);
		dd->w = dd->vinfo.xres;
		dd->h = dd->vinfo.yres;
	}
	
	//dd->screen = SDL_SetVideoMode(dd->w, dd->h, 32, 0);
	dd->screen = SDL_SetVideoMode(dd->w, dd->h, 0, SDL_SWSURFACE);
	if(dd->screen ==  NULL)
		BARF(L, "Can't SDL_SetVideoMode :%s\n", SDL_GetError());

	// and create the text-layer:
	SDL_Surface *text_layer = SDL_CreateRGBSurface(
		SDL_SWSURFACE,
		dd->w, 
		dd->h,
		8, 0, 0, 0, 0);
	if(!text_layer) BARF(L,"Could not allocate the text-layer");
	dd->image[0].rect.x = 0;
	dd->image[0].rect.y = 0;
	dd->image[0].rect.w = dd->w;
	dd->image[0].rect.h = dd->h;
	dd->image[0].frame = 0;
	dd->image[0].nframes = 1;
	dd->image[0].t_update = 0;
	dd->image[0].delay[0] = 0;
	// set colormap for text-layer
	SDL_Color surf_colormap[256];
	int j;
	for(j=0; j<256; j++) {
		surf_colormap[j].r = j<128 ? 0 : 255;
		surf_colormap[j].g = j<128 ? 0 : 255;
		surf_colormap[j].b = j<128 ? 0 : 255;
	}
	SDL_SetColors(text_layer, surf_colormap, 0, 256);
//	SDL_SetAlpha(text_layer, SDL_SRCALPHA, 0);
	SDL_SetColorKey(text_layer, SDL_SRCCOLORKEY, SDL_MapRGB(text_layer->format, 0, 0, 0));
	
	dd->image[0].surf[0] = SDL_DisplayFormatAlpha(text_layer);
	SDL_FreeSurface(text_layer);

	//if(!dd->screen) BARF(L, "Could not open dpydrv_tiny: %s", SDL_GetError());

	SDL_ShowCursor(SDL_DISABLE);
	
	int r = FT_Init_FreeType(&dd->ft_library);
	if(r) BARF(L, "Init_freetype failed");

	lua_pushnumber(L, UPDATE_FREQ);
	return 1;
}


static int l_close(lua_State *L)
{
	struct dpydrv *dd;

	dd = lua_touserdata(L, 1);
	TRACE();

	// free current images
	int i;
	for(i=0; i<MAX_IMAGES; i++) {
		Image *image = &dd->image[i];
		int j;
		for(j=0; j<image->nframes; j++) {
			SDL_FreeSurface(image->surf[j]);
			image->surf[j] = 0;
		}
		image->nframes = 0;
	}

	// release fonts
	if(dd->font_loaded) {
		FT_Done_Face(dd->face);
		dd->font_loaded = 0;
	}

	int r = FT_Done_FreeType(dd->ft_library);
	if(r) BARF(L, "Done_FreeType failed");

	SDL_FreeSurface(dd->screen);
	dd->screen=0;
	SDL_Quit();

	return 0;
}


/* Dump the contents of the visible screen as a string value
 * this is for automated testing purposes only!
 */
static int l_dump(lua_State *L)
{
	struct dpydrv *dd;
	dd = lua_touserdata(L, 1);
	int l = dd->h * dd->screen->pitch;
	
	char *buff = (char*)malloc( 2*l+1 + dd->h );
	int i;
	int j=0;
	for(i=0; i<l; i++)
	{
		sprintf(buff+j, "%02x", (unsigned)((unsigned char*)(dd->screen->pixels))[i]);
		j=j+2;
		if( (i+1) % dd->screen->pitch == 0 && i+1<l)
			buff[j++] = '\n';
	}
	
	buff[j] = 0;
	lua_pushstring( L, buff );
	free( buff );
	return 1;
}


static int l_gotoxy(lua_State *L)
{
	struct dpydrv *dd;

	dd = lua_touserdata(L, 1);
	dd->x = lua_tonumber(L, 2);
	dd->y = lua_tonumber(L, 3);
	TRACE("x=%d,y=%d", dd->x, dd->y);

	lua_pushboolean(L, 1);
	return 1;
}

// draw a charracter
// the background of a charrecters is always transparent (see impl. below)
static int draw_char(struct dpydrv *dd, int ch, int silent)
{
	FT_GlyphSlot slot;
	FT_Bitmap *bitmap;
	Uint32 *p, *py, *pmax, *pmin;
	int x, y;
	int v;

	FT_Load_Char(dd->face, ch, FT_LOAD_RENDER | FT_LOAD_TARGET_MONO);
	slot = dd->face->glyph;
	bitmap = &slot->bitmap;

	SDL_Surface *surf = dd->image[0].surf[0];
	
	TRACE("char='%c', slot->bitmap_top=%d, dd->font_size=%d", ch, slot->bitmap_top, dd->font_size );
	py = surf->pixels + 
	     (dd->y - slot->bitmap_top + dd->font_size - 2) * surf->pitch +
	     (dd->x + slot->bitmap_left)* 4;

	pmin = surf->pixels;
	pmax = surf->pixels + dd->h * surf->pitch;

	for(y=0; y<bitmap->rows; y++) {
		if( y>=0 && y+dd->y<dd->h-1 ) {
			p = py;

			for(x=0; x<bitmap->width; x++) {

				if( x+dd->x>=0 && x+dd->x < dd->w-1 ) {
					v = bitmap->buffer[x/8 + y*bitmap->pitch] & (128>>(x%8));
					if(v && !silent && p >= pmin && p < pmax) {
						//TRACE("x=%d,y=%d, color=%d", x,y,dd->color);
						*p = dd->color;  //SDL_MapRGB(surf->format, 255, 255, 255);
						//printf("x=%d,y=%d\n", x+dd->x,y+dd->y);
					}
				}
				p++;
			
			}
		}

		py += surf->pitch/4;
	}

	dd->x += slot->advance.x / 64;
	dd->y += slot->advance.y / 64 ;

	return slot->advance.x / 64;
}


static int utf8_decode(char *s, unsigned int *pi)
{
	unsigned int c;
	int i = *pi;

	/* one digit utf-8 */
	if ((s[i] & 128)== 0 ) {
		c = (unsigned int) s[i];
		i += 1;
	} else if ((s[i] & 224)== 192 ) { /* 110xxxxx & 111xxxxx == 110xxxxx */
		c = (( (unsigned int) s[i] & 31 ) << 6) +
			( (unsigned int) s[i+1] & 63 );
		i += 2;
	} else if ((s[i] & 240)== 224 ) { /* 1110xxxx & 1111xxxx == 1110xxxx */
		c = ( ( (unsigned int) s[i] & 15 ) << 12 ) +
			( ( (unsigned int) s[i+1] & 63 ) << 6 ) +
			( (unsigned int) s[i+2] & 63 );
		i += 3;
	} else if ((s[i] & 248)== 240 ) { /* 11110xxx & 11111xxx == 11110xxx */
		c =  ( ( (unsigned int) s[i] & 7 ) << 18 ) +
			( ( (unsigned int) s[i+1] & 63 ) << 12 ) +
			( ( (unsigned int) s[i+2] & 63 ) << 6 ) +
			( (unsigned int) s[i+3] & 63 );
		i+= 4;
	} else if ((s[i] & 252)== 248 ) { /* 111110xx & 111111xx == 111110xx */
		c = ( ( (unsigned int) s[i] & 3 ) << 24 ) +
			( ( (unsigned int) s[i+1] & 63 ) << 18 ) +
			( ( (unsigned int) s[i+2] & 63 ) << 12 ) +
			( ( (unsigned int) s[i+3] & 63 ) << 6 ) +
			( (unsigned int) s[i+4] & 63 );
		i += 5;
	} else if ((s[i] & 254)== 252 ) { /* 1111110x & 1111111x == 1111110x */
		c = ( ( (unsigned int) s[i] & 1 ) << 30 ) +
			( ( (unsigned int) s[i+1] & 63 ) << 24 ) +
			( ( (unsigned int) s[i+2] & 63 ) << 18 ) +
			( ( (unsigned int) s[i+3] & 63 ) << 12 ) +
			( ( (unsigned int) s[i+4] & 63 ) << 6 ) +
			( (unsigned int) s[i+5] & 63 );
		i += 6;
	} else {
		c = '?';
		i++;
	}
	*pi = i;
	return c;
}


static int l_draw_text(lua_State *L)
{
	struct dpydrv *dd;
	const char *text;
	int ch;
	const char *p;
	unsigned int pi;
	int w, h, wmax;
	int silent = 0;

	dd = lua_touserdata(L, 1);
	text = luaL_checkstring(L, 2);
	silent = lua_toboolean(L, 3);
	TRACE("text='%s', silent=%s", text, (silent ? "true" : "false"));

	if(! dd->font_loaded) BARF(L, "Cant draw_text, no font loaded");

	/* UTF-8 decode string and draw characters */

	ch = 0;
	w = 0;
	wmax = 0;
	h = dd->font_size;

	p = text;
	while(*p) {
		pi = 0;
		ch = utf8_decode((char *)p, &pi);
		if(ch == '\n') {
			dd->x = 0;
			dd->y += dd->font_size;
			w=0;
			h += dd->font_size;
		} else {
			w += draw_char(dd, ch, silent);
			if (w>wmax)
				wmax = w;
		}

		p += pi;
	}
	
	dd->t_dirty = hirestime();

	lua_pushinteger(L, wmax);
	lua_pushinteger(L, h);

	lua_pushinteger(L, dd->x);
	lua_pushinteger(L, dd->y);

	return 4;
}


/* l_set_font( L )
 * @param L[2]	font_name, this is the filename of the fontfile. eg "arial.ttf"
 * @param l[3]	font_size in points
 */
static int l_set_font(lua_State *L)
{
	struct dpydrv *dd;
	const char *font_name;
	int font_size;
	int r;

	dd = lua_touserdata(L, 1);
	font_name = luaL_checkstring(L, 2);
	font_size = luaL_checknumber(L, 3);
	TRACE("font_name=%s, size=%d", font_name, font_size);

	if(dd->font_loaded) {
		FT_Done_Face(dd->face);
		dd->font_loaded = 0;
	}

	r = FT_New_Face(dd->ft_library, font_name, 0, &dd->face);
	if(r) BARF(L, "Can't load font %s", font_name);
	
	r = FT_Set_Pixel_Sizes(dd->face, 0, font_size);
	if(r) BARF(L, "Can't select font size");

	r = FT_Select_Charmap(dd->face, FT_ENCODING_UNICODE);
	if(r) BARF(L, "Can't select charmap");

	dd->font_size = font_size;
	dd->font_loaded = 1;

	return 1;
}

// only set the fontsize
// @param L[2] the fontsize
static int l_set_font_size(lua_State *L)
{
	struct dpydrv *dd;
	int font_size;
	int r;

	dd = lua_touserdata(L, 1);
	font_size = luaL_checknumber(L, 2);
	TRACE("font_size=%d", font_size);

	if(! dd->font_loaded) {
		BARF(L, "No font loaded: Can't set fontsize");
		return 1;
	}

	r = FT_Set_Pixel_Sizes(dd->face, 0, font_size);
	if(r) BARF(L, "Can't select font size");

	dd->font_size = font_size;

	return 1;
}

static int l_draw_video(lua_State *L)      { BARF(L, "Not implemented"); }
static int l_draw_box(lua_State *L)        { BARF(L, "Not implemented"); }
static int l_draw_filled_box(lua_State *L) { BARF(L, "Not implemented"); }
static int l_list_fonts(lua_State *L)      { BARF(L, "Not implemented"); }


static int l_set_color(lua_State *L)
{ 
	struct dpydrv *dd;
	int r, g, b;

	dd = lua_touserdata(L, 1);
	r = (int)(luaL_checknumber(L, 2) * 255 +.5);
	g = (int)(luaL_checknumber(L, 3) * 255 +.5);
	b = (int)(luaL_checknumber(L, 4) * 255 +.5);
	TRACE("r=%d, g=%d, b=%d", r,g,b);

	dd->color = SDL_MapRGB(dd->image[0].surf[0]->format, r, g, b);

	return 0;
}

static int l_set_background_color(lua_State *L)
{ 
	struct dpydrv *dd;
	int r, g, b;

	dd = lua_touserdata(L, 1);
	r = (int)(luaL_checknumber(L, 2) * 255 +.5);
	g = (int)(luaL_checknumber(L, 3) * 255 +.5);
	b = (int)(luaL_checknumber(L, 4) * 255 +.5);

	dd->background_color = SDL_MapRGB(dd->image[0].surf[0]->format, r, g, b);
	TRACE("background = %x = {r=%d, g=%d, b=%d}",dd->background_color, r,g,b);

	return 0;
}


static void image_blit(struct dpydrv *dd, Image *image, SDL_Rect* rect)
{
	double now = hirestime();
	if(image->nframes == 0) return;

	*rect = image->rect;
	
	//TRACE("nframes=%d, frame=%d, x=%d, y=%d, w=%d, h=%d", image->nframes, image->frame, rect->x, rect->y, rect->w, rect->h );

	// transparent blit: see SDL_SetColorKey in surface innitialisation
	assert( image->surf[image->frame] );
	if( image->surf[image->frame] )
		SDL_BlitSurface(image->surf[image->frame], NULL, dd->screen, rect);
	else
		TRACE("FATAL ERROR: image->surf[image->frame]==null");

	if(image->nframes > 1)
	{
		if( now >= image->t_update )
		{
			// next frame
			image->t_update = now + image->delay[image->frame];
			image->frame = (image->frame + 1) % image->nframes;
		}
	
		if( dd->t_dirty > image->t_update )
			dd->t_dirty = image->t_update ;
	}
}


static int l_update(lua_State *L)
{
	struct dpydrv *dd;
	int i;
	Image *image;
	int force;
	
	dd = lua_touserdata(L, 1);
	force = lua_toboolean(L, 2);

	double now = hirestime();

	// only update if forced or max 2 times per second:
	// This is because of performance reasons: the wifi module/driver has 
	// problems when the app requires 20% cpu time.
	if( force || 
		(now > dd->t_dirty + 0.05 && now-dd->t_refreshed > 0.4) )
	{
		// update at least 1 time per 15 seconds
		dd->t_dirty = now+15;
		
		// clear buffer:
		SDL_FillRect(dd->screen, NULL, dd->background_color);

		/* Blit images, checking for animation updates as well */
		SDL_Rect rects[MAX_IMAGES];
		unsigned rect_count = 0;
		for(i=0; i<MAX_IMAGES; i++) {
			image = &dd->image[i];
			if(image->nframes > 0) {
				//TRACE("Blitting image %d", i);
				image_blit(dd, image, &(rects[rect_count]));
				rect_count++;
				sleep(0);
			}
		}

		SDL_UpdateRects(dd->screen, rect_count, rects);
		sleep(0);
		SDL_Flip(dd->screen);
		dd->t_refreshed = now;
	}
	
	
	lua_pushboolean(L, 1);
	return 0;
}

// Draw an image.
// Each image is loaded in memory and put into an SDL_Surface
// There can be as much as MAX_IMAGES images, each image having
// as much as MAX_FRAMES frames.
// L[1] device context
// L[2] filename
// L[3] x-coord
// L[4] y-coord
// return image_index, error
static int l_draw_image(lua_State *L)
{
	//TRACE_ON();

	struct dpydrv *dd = lua_touserdata(L, 1);
	const char *fname = luaL_optstring(L, 2, "");
	lua_Number img_x = luaL_optnumber(L, 3, 0);
	lua_Number img_y = luaL_optnumber(L, 4, 0);
	TRACE("fname=%s, x=%d, y=%d", fname, (int)img_x, (int)img_y);

	dd->x = (int)img_x;
	dd->y = (int)img_y;
	
	// Find empty image slot
	Image *image = NULL;
	int animations = 0;
	int ii;
	int image_index = 0;
	for(ii=1; ii<MAX_IMAGES; ii++) 
	{
		if(dd->image[ii].nframes == 0 && image==0)
		{
			image = &dd->image[ii];
			image_index = ii;
		}
		else if( dd->image[ii].nframes > 1 )
		{
			animations++;
		}
	}

	if(image == NULL) BARF(L, "Too many images");

	memset(image, 0, sizeof *image);

	// Open and read GIF image
	
	GifFileType *gif = DGifOpenFileName(fname);
	if(gif == NULL) 
		BARF(L, "Could not open image '%s', error '%d'", fname, GifLastError() );

	TRACE("gif->SWith=%d,gif->SHeight=%d", gif->SWidth, gif->SHeight );
	TRACE("gif->SColorResolution=%d", gif->SColorResolution );
	TRACE("gif->SBackGroundColor=%d", gif->SBackGroundColor );
	
/*	if( gif->SWidth > dd->w || gif->SHeight > dd->h )
	{
		DGifCloseFile(gif);
		BARF(L, "Error loading image %s: Image size can be max %dx%d", fname, dd->w, dd->h);
	}
*/
	TRACE("gifslurp...");
	int r = DGifSlurp(gif);
	if(r != GIF_OK)
	{
		DGifCloseFile(gif);
		BARF(L, "Error decoding image '%s'", fname);
	}

	TRACE("gif->ImageCount=%d", gif->ImageCount );
	TRACE("gif->Image.Interlace=%d", gif->Image.Interlace );

	int nframes = gif->ImageCount < MAX_FRAMES ? gif->ImageCount : MAX_FRAMES;
	if( nframes > 1 && animations >= 2 )
	{
		DGifCloseFile(gif);
		BARF(L, "Maximum of 2 animations exceeded for image '%s'", fname);
	}

	image->nframes = nframes;
	image->rect.x = dd->x;
	image->rect.y = dd->y;
	image->rect.w = gif->SWidth < dd->w ? gif->SWidth : dd->w;
	image->rect.h = gif->SHeight < dd->h ? gif->SHeight : dd->h;
	image->frame = 0;

	// Temp surf for reading gif data

	SDL_Surface *surf = SDL_CreateRGBSurface(
		SDL_SWSURFACE,
		image->rect.w, 
		image->rect.h,
		8, 0, 0, 0, 0);
	if( !surf )
	{
		DGifCloseFile(gif);
		BARF(L, "Could not allocate memory for image '%s'", fname);
	}

	int i;
	for(i=0; i<image->nframes; i++) 
	{
		struct SavedImage *savedimage = gif->SavedImages + i;

		// Copy colormap from gif into surface
		TRACE("gif=%u, gif->SColorMap=%u, savedimage->ImageDesc.ColorMap=%u", (unsigned)gif, (unsigned)gif->SColorMap, (unsigned)savedimage->ImageDesc.ColorMap);

		SDL_Color surf_colormap[256];
		memset(surf_colormap, 0, sizeof(SDL_Color)*128);
		memset(&(surf_colormap[128]), 0xff, sizeof(SDL_Color)*128);

		ColorMapObject *cmap = gif->Image.ColorMap ? gif->Image.ColorMap : gif->SColorMap;
		if(cmap)
		{
			struct GifColorType *gif_colormap = cmap->Colors;
			TRACE("gif_colormap = %u, colorcount=%d", (unsigned)gif_colormap, cmap->ColorCount);
			{   int j;
				for(j=0; j<cmap->ColorCount; j++) 
				{
					#ifdef DEBUG
						if( gif_colormap[j].Red != 0 || gif_colormap[j].Green != 0 || gif_colormap[j].Blue != 0 )
							TRACE("color[%d]=%d,%d,%d", j, gif_colormap[j].Red, gif_colormap[j].Green, gif_colormap[j].Blue );
					#endif
					surf_colormap[j].r = gif_colormap[j].Red;
					surf_colormap[j].g = gif_colormap[j].Green;
					surf_colormap[j].b = gif_colormap[j].Blue;
				}
			}
		}
		
TRACE();

		SDL_SetColors(surf, surf_colormap, 0, 256);

		// Copy pixel data
		{   
			TRACE("Copying pixel data");

			struct GifImageDesc *desc = &savedimage->ImageDesc;
			TRACE( "desc->Width=%d, desc->Height=%d, desc->Left=%d, desc->Top=%d",
					desc->Width, desc->Height, desc->Left, desc->Top);
			TRACE( "image->rect.w=%d, image->rect.h=%d", image->rect.w, image->rect.h);
			TRACE( "surf->pitch=%d", surf->pitch);

			int cw = desc->Width;
			if( cw + desc->Left > image->rect.w ) cw = image->rect.w - desc->Left ;
			if( cw < 0 ) cw = 0;
			
			int ch = desc->Height;
			if( ch + desc->Top > image->rect.h ) ch = image->rect.h - desc->Top ; 
			if( ch < 0 ) ch = 0;

			TRACE("cw=%d, ch=%d", cw, ch);
			
			int j;
			for(j=0; j<ch; j++)
			{
				Uint8 *pfrom = savedimage->RasterBits + (desc->Width * j);
				Uint8 *pto = surf->pixels + (surf->pitch * (j + desc->Top)) + desc->Left;
				memcpy(pto, pfrom, cw);
				#ifdef NODEF //DEBUG
				printf("pixels: ");
				int k;
				for(k=0; k < gif->SWidth; k++)
				{
					printf("%d,", pfrom[k]);
				}
				printf("\n");
				
				#endif
			}
		}

		// If animated gif, get delay time
		double delay = 0;
		{   int j;
			for(j=0; j<savedimage->ExtensionBlockCount; j++)
			{
				ExtensionBlock *eb = &savedimage->ExtensionBlocks[j];
				if(eb->Function == 0xf9) 
				{
					delay = ((unsigned char)eb->Bytes[2]*256 + (unsigned char)eb->Bytes[1]) / 100.0;
					TRACE("delaytime=%f", delay);
				}
			}
		}
		image->delay[i] = delay;

TRACE();

		// turn on transparency when the transparent color is used:
		int j;
		for(j=0; j<255; j++)
		{
			if( surf_colormap[j].r == 0 && 
				surf_colormap[j].g == 0 &&
				surf_colormap[j].b == 255 )
			{
				// pure blue functions as transparent
				SDL_SetColorKey(surf, SDL_SRCCOLORKEY, SDL_MapRGB(surf->format, 0, 0, 255));
				break;
			}
		}
TRACE();

		// Copy indexed GIF surface to image frame surface
		image->surf[i] = SDL_DisplayFormatAlpha(surf);
	}

	TRACE("SDL_FreeSurface");
	SDL_FreeSurface(surf);

	TRACE("DGifCloseFile");
	DGifCloseFile(gif);

	//TRACE_OFF();

	dd->t_dirty = hirestime();

	// and return the image index:
	lua_pushinteger(L, image_index);
	return 1;
}

/* invert all pixels of a certain layer
 * watch out: this cost some performance!
 * use L[1]=layer 
 */
static int l_invert(lua_State *L)
{
	//TRACE_ON();
	struct dpydrv *dd = lua_touserdata(L, 1);

	int layer_nr = (int)luaL_optnumber(L, 2, 0);

	if( layer_nr < MAX_IMAGES )
	{
		Image *image = &dd->image[layer_nr];
		if( image->nframes > 0 )
		{
			int frame;
			for(frame=0; frame < image->nframes; frame++)
			{
				TRACE("inverting layer %d, frame %d", layer_nr, frame);
				Uint32 white = SDL_MapRGB(image->surf[frame]->format, 0xff,0xff,0xff );
				Uint32 black = SDL_MapRGB(image->surf[frame]->format, 0x00,0x00,0x00 );
			
				int l = image->rect.w * image->rect.h;
				TRACE("Processing #%d pixels", l );
				int c=0;
				for( c = 0; c < l; c++ )
				{
					Uint32 *p = &((Uint32*)image->surf[frame]->pixels)[c];
					//TRACE("Inverting pixel %d (0x%ld)", c++, (unsigned long)p);
					if( *p == white )
					{
						*p = black;
					}
					else if( *p == black )
					{
						*p = white;
					}
				}
			
			}
			dd->t_dirty = hirestime();
		}
	}
	//TRACE_OFF();
	return 0;
}

/* clear screen
 * use L[1]=layer to clear only a certain layer. (layer[0] is for text)
 */
static int l_clear(lua_State *L)
{
	Image *image;
	struct dpydrv *dd;
	int i, j;

	dd = lua_touserdata(L, 1);
	int layer = luaL_optint(L, 2, -1);

	TRACE();
	SDL_FillRect(dd->screen, NULL, dd->background_color);
	if(layer==-1 || layer==0)
		SDL_FillRect(dd->image[0].surf[0], NULL, dd->background_color);

	dd->x = 0;
	dd->y = 0;

	// start counting from 1: surface 0 is the text layer
	for(i=1; i<MAX_IMAGES; i++) {
		if(layer == -1 || layer == i)
		{
			image = &dd->image[i];
			for(j=0; j<image->nframes; j++) 
			{
				SDL_FreeSurface(image->surf[j]);
				image->surf[j] = 0;
			}
			image->nframes = 0;
		}
	}
	
	dd->t_dirty = hirestime();

	return 0;
}


static int l_free(lua_State *L) 
{ 
	struct dpydrv *dd;
	TRACE();
	
	l_close(L);

	dd = lua_touserdata(L, 1);
	free(dd);

	return(0); 
}


/***************************************************************************
* Lua bindings
***************************************************************************/

static struct luaL_Reg dpydrv_metatable[] = {
	{ "open",			l_open },
	{ "close",			l_close },
	{ "draw_image",		l_draw_image },
	{ "draw_video",		l_draw_video },
	{ "gotoxy",			l_gotoxy },
	{ "set_font",		l_set_font },
	{ "set_font_size",	l_set_font_size },
	{ "set_color",		l_set_color },
	{ "set_background_color",		l_set_background_color },
	{ "draw_text",		l_draw_text },
	{ "draw_box",		l_draw_box },
	{ "draw_filled_box",l_draw_filled_box },
	{ "clear",			l_clear },
	{ "invert",			l_invert },
	{ "update",			l_update },
	{ "list_fonts",		l_list_fonts },
	{ "dump",           l_dump }, // for testing pruposes only!
	{ NULL },
};


static struct luaL_Reg dpydrv_table[] = {
	{ "new",	l_new },
	{ "__gc",	l_free },
	{ NULL },
};

int luaopen_dpydrv(lua_State *L)
{
	TRACE();
	luaL_newmetatable(L, "Dpydrv"); 
	lua_pushstring(L, "__index");
	lua_pushvalue(L, -2); 
	lua_settable(L, -3); 

	luaL_register(L, NULL, dpydrv_metatable);
	luaL_register(L, "dpydrv", dpydrv_table);

	return 0;
}


/*
 * vi: ft=c ts=4 sw=4 
 */
