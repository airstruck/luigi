local ROOT = (...):gsub('[^.]*.[^.]*.[^.]*$', '')
local REL = (...):gsub('[^.]*$', '')

local Multiline = require(ROOT .. 'multiline')

local Text = setmetatable({}, { __call = function (self, ...)
    local object = setmetatable({}, { __index = self })
    return object, self.constructor(object, ...)
end })

local function renderSingle (self, x, y, font, text, color)
    love.graphics.push('all')
    love.graphics.setColor(color or { 0, 0, 0 })
    love.graphics.setFont(font.loveFont)
    love.graphics.print(text, math.floor(x), math.floor(y))
    love.graphics.pop()

    self.height = font:getLineHeight()
    self.width = font:getAdvance(text)
end

local function renderMulti (self, x, y, font, text, color, align, limit)
    local lines = Multiline.wrap(font, text, limit)
    local lineHeight = font:getLineHeight()
    local height = #lines * lineHeight

    love.graphics.push('all')
    love.graphics.setColor(color or { 0, 0, 0 })
    love.graphics.setFont(font.loveFont)

    for index, line in ipairs(lines) do
        local text = table.concat(line)
        local top = (index - 1) * lineHeight
        local w = line.width

        if align == 'left' then
            love.graphics.print(text,
                math.floor(x), math.floor(top + y))
        elseif align == 'right' then
            love.graphics.print(text,
                math.floor(limit - w + x), math.floor(top + y))
        elseif align == 'center' then
            love.graphics.print(text,
                math.floor((limit - w) / 2 + x), math.floor(top + y))
        end
    end

    love.graphics.pop()

    self.height = height
    self.width = limit
end

function Text:constructor (font, text, color, align, limit)
    if limit then
        function self:draw (x, y)
            return renderMulti(self, x, y, font, text, color, align, limit)
        end
    else
        function self:draw (x, y)
            return renderSingle(self, x, y, font, text, color)
        end
    end
    self:draw(-1000000, -1000000)
end

function Text:getWidth ()
    return self.width
end

function Text:getHeight ()
    return self.height
end

return Text
