local REL = (...):gsub('[^.]*$', '')
local APP_ROOT = rawget(_G, 'LUIGI_APP_ROOT') or ''

local ffi = require 'ffi'
local sdl = require(REL .. 'sdl')

local SDL2_image = ffi.load 'SDL2_image'

ffi.cdef [[ SDL_Surface *IMG_Load(const char *file); ]]

local Image = setmetatable({}, { __call = function (self, ...)
    local object = setmetatable({}, { __index = self })
    return object, self.constructor(object, ...)
end })

function Image:constructor (renderer, path)
    self.sdlRenderer = renderer
    self.sdlSurface = ffi.gc(
        SDL2_image.IMG_Load(APP_ROOT .. path),
        sdl.freeSurface)

    if self.sdlSurface == nil then
        error(ffi.string(sdl.getError()))
    end

    self.sdlTexture = ffi.gc(
        sdl.createTextureFromSurface(renderer, self.sdlSurface),
        sdl.destroyTexture)

    if self.sdlTexture == nil then
        error(ffi.string(sdl.getError()))
    end

    self.width = self.sdlSurface.w
    self.height = self.sdlSurface.h
end

function Image:getWidth ()
    return self.width
end

function Image:getHeight ()
    return self.height
end

return Image
