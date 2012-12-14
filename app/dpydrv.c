/*
 * Copyright © 2007 All Rights Reserved.
 */

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
#define MAX_IMAGES 8
#define MAX_FRAMES 32

#define BARF(L, msg...) do { lua_pushnil(L); lua_pushfstring(L, msg); return 2; } while(0)

//#define TRACE(msg...) { fprintf(stderr,"%s:%d - %s ", __FILE__, __LINE__, __FUNCTION__);fprintf(stderr,msg);fprintf(stderr,"\n"); }
#define TRACE(msg...) {}

struct image {
	int x, y;
	int w, h;
	unsigned frame;
	unsigned nframes;
	double t_update;
	SDL_Surface *surf[32];
	double delay[32];
};


struct dpydrv {

	lua_State *L;

	/* Geometry and color settings */

	int w, h;
	char c;		/* Color mode, can be 'm' (mono) or 'c' (color) */

	/* SDL */
	
	int x, y;
	Uint32 color;
	Uint32 background_color;
	SDL_Surface *screen;
	double t_dirty;

	/* Freetype */
	
	FT_Library ft_library;
	FT_Face face;
	int font_loaded;
	int font_size;
	int text_x_start, text_y_start;

	struct image image[MAX_IMAGES];
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
TRACE(" ");

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


static int l_open(lua_State *L)
{
	int r;
	struct dpydrv *dd;
TRACE(" ");
	dd = lua_touserdata(L, 1);

	/* Parse arguments */

	dd->w = lua_tonumber(L, 2);
	dd->h = lua_tonumber(L, 3);
	dd->c = lua_tonumber(L, 4);

	/* Mute directfb */
TRACE(" ");

	setenv("DFBARGS", "quiet=info,no-banner", 1);
TRACE(" ");

	/* SDL */

	if (SDL_InitSubSystem(SDL_INIT_VIDEO | SDL_INIT_NOPARACHUTE) != 0)
		BARF(L, "SDL_InitSubSystem failed: %s", SDL_GetError());

TRACE(" w=%d, h=%d", dd->w, dd->h);
	dd->screen = SDL_SetVideoMode(
				dd->w,
				dd->h,
				32, 
				0);
TRACE(" ");

	if(!dd->screen) BARF(L, "Could not open dpydrv_tiny: %s", SDL_GetError());
TRACE(" ");

	SDL_ShowCursor(0);
TRACE(" ");
	
	r = FT_Init_FreeType(&dd->ft_library);
	if(r) BARF(L, "Init_freetype failed");
TRACE(" ");

	lua_pushnumber(L, UPDATE_FREQ);
	return 1;
}


static int l_close(lua_State *L)
{
	struct dpydrv *dd;
TRACE(" ");

	dd = lua_touserdata(L, 1);

	if(dd->font_loaded) {
		FT_Done_Face(dd->face);
		dd->font_loaded = 0;
	}

	int r = FT_Done_FreeType(dd->ft_library);
	if(r) BARF(L, "Done_FreeType failed");

	SDL_FreeSurface(dd->screen);
	SDL_QuitSubSystem(SDL_INIT_VIDEO);
	SDL_Quit();

	return 0;
}


static int l_gotoxy(lua_State *L)
{
	struct dpydrv *dd;
TRACE(" ");

	dd = lua_touserdata(L, 1);
	dd->x = lua_tonumber(L, 2);
	dd->y = lua_tonumber(L, 3);

	lua_pushboolean(L, 1);
	return 1;
}


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

	py = dd->screen->pixels + 
	     (dd->y - slot->bitmap_top + dd->font_size - 4) * dd->screen->pitch +
	     (dd->x + slot->bitmap_left)* 4;

	pmin = dd->screen->pixels;
	pmax = dd->screen->pixels + dd->h * dd->screen->pitch;

	for(y=0; y<bitmap->rows; y++) {
		if( y>=0 && y+dd->y<dd->h-1 ) {
			p = py;

			for(x=0; x<bitmap->width; x++) {

				if( x+dd->x>=0 && x+dd->x < dd->w-1 ) {
					v = bitmap->buffer[x/8 + y*bitmap->pitch] & (128>>(x%8));
					if(v && !silent && p >= pmin && p < pmax) {
						*p = SDL_MapRGB(dd->screen->format, 255, 255, 255);
					}
				}
				p++;
			
			}
		}

		py += dd->screen->pitch/4;
	}

	dd->x += slot->advance.x / 64;
	dd->y += slot->advance.y / 64;

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
TRACE(" ");

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
			dd->x = dd->text_x_start;
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


static void image_blit(struct dpydrv *dd, struct image *image)
{
	SDL_Rect rect;
	double now;
	
	now = hirestime();
	if(now < image->t_update) return;
	if(image->nframes == 0) return;
TRACE(" ");

	rect.x = image->x;
	rect.y = image->y;
	rect.w = image->w;
	rect.h = image->h;

	SDL_BlitSurface(image->surf[image->frame], NULL, dd->screen, &rect);
	SDL_UpdateRects(dd->screen, 1, &rect);

	if((image->nframes > 1) && (image->delay[image->frame] > 0)) {
		image->t_update = now + image->delay[image->frame];
	} else {
		image->t_update = now + 1E6;
	}

	image->frame = (image->frame + 1) % image->nframes;
	
	dd->t_dirty = hirestime();
}


static int l_draw_image(lua_State *L)
{
	struct image *image = NULL;
	struct dpydrv *dd;
	const char *fname;
	SDL_Surface *surf;
	SDL_Color surf_colormap[256];
	struct GifColorType *gif_colormap;
	GifFileType *gif;
	struct SavedImage *savedimage;
	struct GifImageDesc *desc;
	ExtensionBlock *eb;
	lua_Number img_x, img_y;
	int r;
	int i, j;
	int y;
	Uint8 *pfrom, *pto;
	double delay;

	dd = lua_touserdata(L, 1);
	fname = luaL_optstring(L, 2, "");
	img_x = luaL_optnumber(L, 3, 0);
	img_y = luaL_optnumber(L, 4, 0);
TRACE(" ");

	dd->x = (int)img_x;
	dd->y = (int)img_y;
	
	/* Find empty image slot */
	
	for(i=0; i<MAX_IMAGES; i++) {
		if(dd->image[i].nframes == 0) {
			image = &dd->image[i];
			break;
		}
	}

	if(image == NULL) BARF(L, "Too many images");

	memset(image, 0, sizeof *image);

	/* Open and read GIF image */
	
	gif = DGifOpenFileName(fname);
	if(gif == NULL) 
		BARF(L, "Could not open image '%s', error '%d'", fname, GifLastError() );

	r = DGifSlurp(gif);
	if(r != GIF_OK) {
		DGifCloseFile(gif);
		BARF(L, "Error decoding image '%s'", fname);
	}

	image->x = dd->x;
	image->y = dd->y;
	image->w = gif->SWidth;
	image->h = gif->SHeight;
	image->frame = 0;
	image->nframes = gif->ImageCount;

	/* Temp surf for reading gif data */

	surf = SDL_CreateRGBSurface(
		SDL_SWSURFACE,
		image->w, 
		image->h,
		8, 0, 0, 0, 0);

	for(i=0; i<image->nframes; i++) {

		savedimage = gif->SavedImages + i;
		desc = &savedimage->ImageDesc;
	
		/* Copy colormap from gif into surface */

		gif_colormap = gif->SColorMap->Colors;
		for(j=0; j<256; j++) {
			surf_colormap[j].r = gif_colormap[j].Red;
			surf_colormap[j].g = gif_colormap[j].Green;
			surf_colormap[j].b = gif_colormap[j].Blue;
		}

		SDL_SetColors(surf, surf_colormap, 0, 256);

		/* Copy pixel data */

		for(y=0; y<desc->Height; y++) {
			pfrom = savedimage->RasterBits + (desc->Width * y);
			pto = surf->pixels + (surf->pitch * (y + desc->Top)) + desc->Left;
			memcpy(pto, pfrom, desc->Width);
		}

		/* If animated gif, get delay time */

		delay = 0;
		for(j=0; j<savedimage->ExtensionBlockCount; j++) {
			eb = &savedimage->ExtensionBlocks[j];
			if(eb->Function == 0xf9) {
				delay = ((unsigned char)eb->Bytes[2]*256 + (unsigned char)eb->Bytes[1]) / 100.0;
			}
		}

		image->delay[i] = delay;

		/* Copy indexed GIF surface to image frame surface */
		 
		image->surf[i] = SDL_DisplayFormatAlpha(surf);
	}
	
	SDL_FreeSurface(surf);
	DGifCloseFile(gif);

	image_blit(dd, image);

	lua_pushboolean(L, 1);
	return 1;
}


static int l_set_font(lua_State *L)
{
	struct dpydrv *dd;
	const char *font_name;
	int font_size;
	int r;

	dd = lua_touserdata(L, 1);
	font_name = luaL_checkstring(L, 2);
	font_size = luaL_checknumber(L, 3);
TRACE(" ");

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
TRACE(" ");

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
	double r, g, b;

	dd = lua_touserdata(L, 1);
	r = luaL_checknumber(L, 2) * 255;
	g = luaL_checknumber(L, 3) * 255;
	b = luaL_checknumber(L, 4) * 255;
TRACE(" ");

	dd->color = SDL_MapRGB(dd->screen->format, r, g, b);

	return 0;
}

static int l_set_background_color(lua_State *L)
{ 
	struct dpydrv *dd;
	double r, g, b;

	dd = lua_touserdata(L, 1);
	r = luaL_checknumber(L, 2) * 255;
	g = luaL_checknumber(L, 3) * 255;
	b = luaL_checknumber(L, 4) * 255;
TRACE(" ");

	dd->background_color = SDL_MapRGB(dd->screen->format, r, g, b);

	return 0;
}


static int l_update(lua_State *L)
{
	struct dpydrv *dd;
	unsigned i;
	struct image *image;
	double now;
	int force;
	
	dd = lua_touserdata(L, 1);
	force = lua_toboolean(L, 2);

	/* Blit images, checking for animation updates as well */

	for(i=0; i<MAX_IMAGES; i++) {
		image = &dd->image[i];
		if(image->nframes > 0) {
			image_blit(dd, image);
		}
	}

	/* Update the display as soon as the last dirty time is > 0.05 second away */

	now = hirestime();

	if(force || (now >= dd->t_dirty + 0.05)) {
		SDL_Flip(dd->screen);
		dd->t_dirty = now + 1E6;
	}
	
	lua_pushboolean(L, 1);
	return 0;
}

/* clear screen
 */
static int l_clear(lua_State *L)
{
	struct image *image;
	struct dpydrv *dd;
	int i, j;

	dd = lua_touserdata(L, 1);

	SDL_FillRect(dd->screen, NULL, dd->background_color);

	dd->x = 0;
	dd->y = 0;

	for(i=0; i<MAX_IMAGES; i++) {
		image = &dd->image[i];
		for(j=0; j<image->nframes; j++) {
			SDL_FreeSurface(image->surf[j]);
		}
		image->nframes = 0;
	}
	
	dd->t_dirty = hirestime();

	return 0;
}



static int l_free(lua_State *L) 
{ 
	struct dpydrv *dd;
TRACE(" ");
	
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
	{ "update",			l_update },
	{ "list_fonts",		l_list_fonts },
	{ NULL },
};


static struct luaL_Reg dpydrv_table[] = {
	{ "new",	l_new },
	{ "__gc",	l_free },
	{ NULL },
};

int luaopen_dpydrv(lua_State *L)
{
TRACE(" ");
	luaL_newmetatable(L, "Dpydrv"); 
	lua_pushstring(L, "__index");
	lua_pushvalue(L, -2); 
	lua_settable(L, -3); 

	luaL_register(L, NULL, dpydrv_metatable);
	luaL_register(L, "dpydrv", dpydrv_table);

	return 0;
}


/*
 * End
 */

