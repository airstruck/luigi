local REL = (...):gsub('[^.]*$', '')

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
    self.sdlSurface = SDL2_image.IMG_Load(path)
    ffi.gc(self.sdlSurface, sdl.freeSurface)
    self.sdlTexture = sdl.createTextureFromSurface(renderer, self.sdlSurface)
    ffi.gc(self.sdlTexture, sdl.destroyTexture)
    self.width = self.sdlSurface.w
    self.height = self.sdlSurface.h
end

function Image:getWidth ()
    return self.width
end

function Image:getHeight ()
    return self.height
end

function Image:draw (x, y, sx, sy)
    local w = self.width * (sx or 1)
    local h = self.height * (sy or 1)

    -- HACK. Somehow drawing something first prevents renderCopy from
    -- incorrectly scaling up in some cases (after rendering slices).
    -- For example http://stackoverflow.com/questions/28218906
    sdl.renderDrawPoint(self.sdlRenderer, -1, -1)

    -- Draw the image.
    sdl.renderCopy(self.sdlRenderer, self.sdlTexture, nil, sdl.Rect(x, y, w, h))
end

return Image
