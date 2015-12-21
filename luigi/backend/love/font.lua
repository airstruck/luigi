local Font = setmetatable({}, { __call = function (self, ...)
    local object = setmetatable({}, { __index = self })
    return object, self.constructor(object, ...)
end })

local fontCache = {}

function Font:constructor (path, size, color)
    if not size then
        size = 12
    end
    if not color then
        color = { 0, 0, 0 }
    end
    local key = (path or '') .. '_' .. size

    if not fontCache[key] then
        if path then
            fontCache[key] = love.graphics.newFont(path, size)
        else
            fontCache[key] = love.graphics.newFont(size)
        end
    end

    self.loveFont = fontCache[key]
    self.color = color
end

function Font:setAlignment (align)
    self.align = align
end

function Font:setWidth (width)
    self.width = width
end

function Font:getLineHeight ()
    return self.loveFont:getHeight()
end

function Font:getAscender ()
    return self.loveFont:getAscent()
end

function Font:getDescender ()
    return self.loveFont:getDescent()
end

function Font:getAdvance (text)
    return (self.loveFont:getWidth(text))
end

return Font
