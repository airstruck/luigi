local REL = (...):gsub('[^.]*$', '')
local APP_ROOT = rawget(_G, 'LUIGI_APP_ROOT') or ''

local ffi = require 'ffi'
local sdl = require(REL .. 'sdl')

local SDL2_ttf = ffi.load 'SDL2_ttf'

local IntOut = ffi.typeof 'int[1]'

ffi.cdef [[

/* The internal structure containing font information */
typedef struct _TTF_Font TTF_Font;

/* Initialize the TTF engine - returns 0 if successful, -1 on error */
int TTF_Init(void);

/* Open a font file and create a font of the specified point size.
 * Some .fon fonts will have several sizes embedded in the file, so the
 * point size becomes the index of choosing which size.  If the value
 * is too high, the last indexed size will be the default. */
TTF_Font *TTF_OpenFont(const char *file, int ptsize);
TTF_Font *TTF_OpenFontIndex(const char *file, int ptsize, long index);
TTF_Font *TTF_OpenFontRW(SDL_RWops *src, int freesrc, int ptsize);
TTF_Font *TTF_OpenFontIndexRW(SDL_RWops *src, int freesrc, int ptsize, long index);

/* Set and retrieve the font style
#define TTF_STYLE_NORMAL        0x00
#define TTF_STYLE_BOLD          0x01
#define TTF_STYLE_ITALIC        0x02
#define TTF_STYLE_UNDERLINE     0x04
#define TTF_STYLE_STRIKETHROUGH 0x08
 */

int TTF_GetFontStyle(const TTF_Font *font);
void TTF_SetFontStyle(TTF_Font *font, int style);
int TTF_GetFontOutline(const TTF_Font *font);
void TTF_SetFontOutline(TTF_Font *font, int outline);

/* Set and retrieve FreeType hinter settings
#define TTF_HINTING_NORMAL    0
#define TTF_HINTING_LIGHT     1
#define TTF_HINTING_MONO      2
#define TTF_HINTING_NONE      3
 */

int TTF_GetFontHinting(const TTF_Font *font);
void TTF_SetFontHinting(TTF_Font *font, int hinting);

/* Get the total height of the font - usually equal to point size */
int TTF_FontHeight(const TTF_Font *font);

/* Get the offset from the baseline to the top of the font
   This is a positive value, relative to the baseline.
 */
int TTF_FontAscent(const TTF_Font *font);

/* Get the offset from the baseline to the bottom of the font
   This is a negative value, relative to the baseline.
 */
int TTF_FontDescent(const TTF_Font *font);

/* Get the recommended spacing between lines of text for this font */
int TTF_FontLineSkip(const TTF_Font *font);

/* Get/Set whether or not kerning is allowed for this font */
int TTF_GetFontKerning(const TTF_Font *font);
void TTF_SetFontKerning(TTF_Font *font, int allowed);

/* Get the number of faces of the font */
long TTF_FontFaces(const TTF_Font *font);

/* Get the font face attributes, if any */
int TTF_FontFaceIsFixedWidth(const TTF_Font *font);
char *TTF_FontFaceFamilyName(const TTF_Font *font);
char *TTF_FontFaceStyleName(const TTF_Font *font);

/* Check wether a glyph is provided by the font or not */
int TTF_GlyphIsProvided(const TTF_Font *font, Uint16 ch);

/* Get the metrics (dimensions) of a glyph
   To understand what these metrics mean, here is a useful link:
    http://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html
 */
int TTF_GlyphMetrics(TTF_Font *font, Uint16 ch,
                     int *minx, int *maxx,
                                     int *miny, int *maxy, int *advance);

/* Get the dimensions of a rendered string of text */
int TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h);
int TTF_SizeUTF8(TTF_Font *font, const char *text, int *w, int *h);
int TTF_SizeUTF8_Wrapped(TTF_Font *font, const char *text, int wrapLength, int *w, int *h, int *lineCount);
int TTF_SizeUNICODE(TTF_Font *font, const Uint16 *text, int *w, int *h);

/* Create an 8-bit palettized surface and render the given text at
   fast quality with the given font and color.  The 0 pixel is the
   colorkey, giving a transparent background, and the 1 pixel is set
   to the text color.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderText_Solid(TTF_Font *font,
                const char *text, SDL_Color fg);
SDL_Surface *TTF_RenderUTF8_Solid(TTF_Font *font,
                const char *text, SDL_Color fg);
SDL_Surface *TTF_RenderUNICODE_Solid(TTF_Font *font,
                const Uint16 *text, SDL_Color fg);

/* Create an 8-bit palettized surface and render the given glyph at
   fast quality with the given font and color.  The 0 pixel is the
   colorkey, giving a transparent background, and the 1 pixel is set
   to the text color.  The glyph is rendered without any padding or
   centering in the X direction, and aligned normally in the Y direction.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderGlyph_Solid(TTF_Font *font,
                    Uint16 ch, SDL_Color fg);

/* Create an 8-bit palettized surface and render the given text at
   high quality with the given font and colors.  The 0 pixel is background,
   while other pixels have varying degrees of the foreground color.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderText_Shaded(TTF_Font *font,
                const char *text, SDL_Color fg, SDL_Color bg);
SDL_Surface *TTF_RenderUTF8_Shaded(TTF_Font *font,
                const char *text, SDL_Color fg, SDL_Color bg);
SDL_Surface *TTF_RenderUNICODE_Shaded(TTF_Font *font,
                const Uint16 *text, SDL_Color fg, SDL_Color bg);

/* Create an 8-bit palettized surface and render the given glyph at
   high quality with the given font and colors.  The 0 pixel is background,
   while other pixels have varying degrees of the foreground color.
   The glyph is rendered without any padding or centering in the X
   direction, and aligned normally in the Y direction.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderGlyph_Shaded(TTF_Font *font,
                Uint16 ch, SDL_Color fg, SDL_Color bg);

/* Create a 32-bit ARGB surface and render the given text at high quality,
   using alpha blending to dither the font with the given color.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderText_Blended(TTF_Font *font,
                const char *text, SDL_Color fg);
SDL_Surface *TTF_RenderUTF8_Blended(TTF_Font *font,
                const char *text, SDL_Color fg);
SDL_Surface *TTF_RenderUNICODE_Blended(TTF_Font *font,
                const Uint16 *text, SDL_Color fg);


/* Create a 32-bit ARGB surface and render the given text at high quality,
   using alpha blending to dither the font with the given color.
   Text is wrapped to multiple lines on line endings and on word boundaries
   if it extends beyond wrapLength in pixels.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderText_Blended_Wrapped(TTF_Font *font,
                const char *text, SDL_Color fg, Uint32 wrapLength);
SDL_Surface *TTF_RenderUTF8_Blended_Wrapped(TTF_Font *font,
                const char *text, SDL_Color fg, Uint32 wrapLength);
SDL_Surface *TTF_RenderUNICODE_Blended_Wrapped(TTF_Font *font,
                const Uint16 *text, SDL_Color fg, Uint32 wrapLength);

/* Create a 32-bit ARGB surface and render the given glyph at high quality,
   using alpha blending to dither the font with the given color.
   The glyph is rendered without any padding or centering in the X
   direction, and aligned normally in the Y direction.
   This function returns the new surface, or NULL if there was an error.
*/
SDL_Surface *TTF_RenderGlyph_Blended(TTF_Font *font,
                        Uint16 ch, SDL_Color fg);

/* Close an opened font file */
void TTF_CloseFont(TTF_Font *font);

/* De-initialize the TTF engine */
void TTF_Quit(void);

/* Check if the TTF engine is initialized */
int TTF_WasInit(void);

/* Get the kerning size of two glyphs */
int TTF_GetFontKerningSize(TTF_Font *font, int prev_index, int index);
]]

if SDL2_ttf.TTF_Init() ~= 0 then
    error(ffi.string(sdl.getError()))
end

local Font = setmetatable({}, { __call = function (self, ...)
    local object = setmetatable({}, { __index = self })
    return object, self.constructor(object, ...)
end })

Font.SDL2_ttf = SDL2_ttf

local fontCache = {}

function Font:constructor (path, size)
    if not size then
        size = 12
    end
    if not path then
        path = REL:gsub('%.', '/') .. 'resource/DejaVuSans.ttf'
    end
    local key = path .. '_' .. size

    if not fontCache[key] then
        local font = SDL2_ttf.TTF_OpenFont(APP_ROOT .. path, size)

        if font == nil then
            error(ffi.string(sdl.getError()))
        end

        fontCache[key] = font
    end

    self.sdlFont = fontCache[key]
end

function Font:setAlignment (align)
    self.align = align
end

function Font:setWidth (width)
    self.width = width
end

function Font:getLineHeight ()
    return SDL2_ttf.TTF_FontHeight(self.sdlFont)
end

function Font:getAscender ()
    return SDL2_ttf.TTF_FontAscent(self.sdlFont)
end

function Font:getDescender ()
    return SDL2_ttf.TTF_FontDescent(self.sdlFont)
end

function Font:getAdvance (text)
    local w, h = IntOut(), IntOut()
    SDL2_ttf.TTF_SizeUTF8(self.sdlFont, text, w, h)
    return w[0]
end

return Font
