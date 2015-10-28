local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')

local Font = Base:extend()

local cache = {}

function Font:constructor (path, size, color)
    if not size then
        size = 12
    end
    if not color then
        color = { 0, 0, 0 }
    end
    local key = (path or '') .. '_' .. size

    if not cache[key] then
        if path then
            cache[key] = love.graphics.newFont(path, size)
        else
            cache[key] = love.graphics.newFont(size)
        end
    end

    self.layout = {}
    self.font = cache[key]
    self.color = color
end

function Font:setAlignment (align)
    self.layout.align = align
end

function Font:setWidth (width)
    self.layout.width = width
end

function Font:getLineHeight ()
    return self.font:getLineHeight()
end

function Font:getAscender ()
    return self.font:getAscent()
end

function Font:getDescender ()
    return self.font:getDescent()
end

function Font:getAdvance (text)
    return (self.font:getWidth(text))
end

if love._version_minor < 10 then
    function Font:getWrappedHeight (text)
        local _, lines = self.font:getWrap(text, self.layout.width)
        return lines * self.font:getHeight()
    end
else
    function Font:getWrappedHeight (text)
        local _, lines = self.font:getWrap(text, self.layout.width)
        return #lines * self.font:getHeight()
    end
end

return Font
