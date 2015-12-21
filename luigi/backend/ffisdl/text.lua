local ROOT = (...):gsub('[^.]*.[^.]*.[^.]*$', '')
local REL = (...):gsub('[^.]*$', '')

local ffi = require 'ffi'
local sdl = require(REL .. 'sdl')
local Font = require(REL .. 'font')
local ttf = Font.SDL2_ttf

local Multiline = require(ROOT .. 'multiline')

local Text = setmetatable({}, { __call = function (self, ...)
    local object = setmetatable({}, { __index = self })
    return object, self.constructor(object, ...)
end })

local function renderSingle (self, font, text, color)
    local alphaMod = color and color[4]
    color = sdl.Color(color or 0)
    local surface = ffi.gc(
        ttf.TTF_RenderUTF8_Blended(font.sdlFont, text, color),
        sdl.freeSurface)
    self.sdlSurface = surface
    self.sdlTexture = ffi.gc(
        sdl.createTextureFromSurface(self.sdlRenderer, surface),
        sdl.destroyTexture)
    if alphaMod then
        sdl.setTextureAlphaMod(self.sdlTexture, alphaMod)
    end
    self.width, self.height = surface.w, surface.h
end

local function renderMulti (self, font, text, color, align, limit)
    local alphaMod = color and color[4]
    local lines = Multiline.wrap(font, text, limit)
    local lineHeight = font:getLineHeight()
    local height = #lines * lineHeight
    color = sdl.Color(color or 0)

    -- mask values from SDL_ttf.c
    -- TODO: something with sdl.BYTEORDER == sdl.BIG_ENDIAN ?
    local r, g, b, a = 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000

    local surface = ffi.gc(
        sdl.createRGBSurface(sdl.SWSURFACE, limit, height, 32, r, g, b, a),
        sdl.freeSurface)
    self.sdlSurface = surface

    for index, line in ipairs(lines) do
        local text = table.concat(line)
        local lineSurface = ffi.gc(
            ttf.TTF_RenderUTF8_Blended(font.sdlFont, text, color),
            sdl.freeSurface)
        if lineSurface ~= nil then
            sdl.setSurfaceBlendMode(lineSurface, sdl.BLENDMODE_NONE)

            local w, h = lineSurface.w, lineSurface.h
            local top = (index - 1) * lineHeight

            if align == 'left' then
                sdl.blitSurface(lineSurface, nil, surface,
                    sdl.Rect(0, top, w, h))
            elseif align == 'right' then
                sdl.blitSurface(lineSurface, nil, surface,
                    sdl.Rect(limit - line.width, top, w, h))
            elseif align == 'center' then
                sdl.blitSurface(lineSurface, nil, surface,
                    sdl.Rect((limit - line.width) / 2, top, w, h))
            end
        end
    end

    self.sdlTexture = ffi.gc(
        sdl.createTextureFromSurface(self.sdlRenderer, surface),
        sdl.destroyTexture)

    if alphaMod then
        sdl.setTextureAlphaMod(self.sdlTexture, alphaMod)
    end

    self.width, self.height = limit, height
end

function Text:constructor (renderer, font, text, color, align, limit)
    self.width, self.height = 0, 0
    if not text or text == '' then return end

    self.sdlRenderer = renderer

    if limit then
        renderMulti(self, font, text, color, align, limit)
    else
        renderSingle(self, font, text, color)
    end
end

function Text:getWidth ()
    return self.width
end

function Text:getHeight ()
    return self.height
end

return Text
