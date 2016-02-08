local REL = (...):gsub('[^.]*$', '')

local sdl = require(REL .. 'sdl')

local SpriteBatch = setmetatable({}, { __call = function (self, ...)
    local object = setmetatable({}, { __index = self })
    return object, self.constructor(object, ...)
end })

--[[
spriteBatch = SpriteBatch( image, size )

Arguments

Image image
    The Image to use for the sprites.
number size (1000)
    The max number of sprites.

Returns

SpriteBatch spriteBatch
    The new SpriteBatch.
--]]
function SpriteBatch:constructor (image)
    self.image = image
    self.sprites = {}
end

function SpriteBatch:clear ()
    self.sprites = {}
end

--[[
id = SpriteBatch:add( quad, x, y, r, sx, sy )

Arguments

Quad quad
    The Quad to add.
number x
    The position to draw the object (x-axis).
number y
    The position to draw the object (y-axis).
number r (0)
    Orientation (radians). (not implemented)
number sx (1)
    Scale factor (x-axis).
number sy (sx)
    Scale factor (y-axis).

Returns

number id
    An identifier for the added sprite.
--]]
function SpriteBatch:add (quad, x, y, r, sx, sy)
    local sprites = self.sprites

    sprites[#sprites + 1] = { quad = quad, x = x, y = y,
        sx = sx or 1, sy = sy or 1 }
end

function SpriteBatch:draw ()
    local image = self.image
    local renderer = image.sdlRenderer
    local texture = image.sdlTexture

    for _, sprite in ipairs(self.sprites) do
        local quad = sprite.quad
        local w = math.ceil(quad[3] * sprite.sx)
        local h = math.ceil(quad[4] * sprite.sy)
        local src = sdl.Rect(quad)
        local dst = sdl.Rect(sprite.x, sprite.y, w, h)
        sdl.renderCopy(renderer, texture, src, dst)
    end
end

return SpriteBatch
