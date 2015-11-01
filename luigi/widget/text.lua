local utf8 = require 'utf8'

local blendMultiply = love._version_minor < 10 and 'multiplicative'
    or 'multiply'

local function setCaretPosition (self, text)
    local font = self.fontData.font
    local x1, y1, x2, y2 = self:getRectangle(true, true)
    self.startIndex = #text
    self.startX = font:getWidth(text) + x1
    self.endIndex, self.endX = self.startIndex, self.startX
end

-- return caret index and x position
local function getCaretFromEvent (self, event)
    local x1, y1, x2, y2 = self:getRectangle(true, true)

    if event.x <= x1 then
        return 0, x1
    end

    local font = self.fontData.font
    local width, lastWidth = 0

    for position in utf8.codes(self.value) do
        local index = utf8.offset(self.value, position)
        text = self.value:sub(1, index)
        lastWidth = width
        width = font:getWidth(text)
        if width > event.x - x1 then
            if position == 1 then
                return 0, x1
            end
            return utf8.offset(self.value, position - 1), lastWidth + x1
        end
    end

    return #self.value, width + x1
end

local function getRange (self)
    if self.startIndex <= self.endIndex then
        return self.startIndex, self.endIndex
    end

    return self.endIndex, self.startIndex
end

return function (self)
    self.value = self.value or self.text or ''
    self.text = ''
    self:setValue(self.value)
    self.highlight = self.highlight or { 0x80, 0x80, 0x80 }

    self:onPressStart(function (event)
        self.startIndex, self.startX = getCaretFromEvent(self, event)
        self.endIndex, self.endX = self.startIndex, self.startX
    end)

    self:onPressMove(function (event)
        self.endIndex, self.endX = getCaretFromEvent(self, event)
    end)

    self:onTextInput(function (event)
        local text = self.value
        local first, last = getRange(self)
        local left = text:sub(1, first) .. event.text

        self.value = left .. text:sub(last + 1)
        self:setValue(self.value)
        setCaretPosition(self, left)
    end)

    self:onKeyPress(function (event)
        if event.key == 'backspace' then

            local text = self.value
            local first, last = getRange(self)

            -- if expanded range is selected, delete text in range
            if first ~= last then
                local left = text:sub(1, first)
                self.value = left .. text:sub(last + 1)
                self:setValue(self.value)
                setCaretPosition(self, left)
                return false
            end

            -- if cursor is at beginning, do nothing
            if first < 1 then
                return false
            end

            -- delete character to the left
            local offset = utf8.offset(self.value, -1, first) or 0
            local left = self.value:sub(1, offset)
            self.value = left .. self.value:sub(first + 1)
            self:setValue(self.value)
            setCaretPosition(self, left)

        elseif event.key == 'left' then

            local text, endIndex = self.value, self.endIndex

            -- if cursor is at beginning, do nothing
            if endIndex < 1 then
                return false
            end

            -- move cursor left
            local offset = utf8.offset(text, -1, endIndex) or 0

            setCaretPosition(self, text:sub(1, offset))

        elseif event.key == 'right' then

            local text, endIndex = self.value, self.endIndex

            -- if cursor is at end, do nothing
            if endIndex == #text then
                return false
            end

            local offset = endIndex < 1 and utf8.offset(text, 1)
                or utf8.offset(text, 2, endIndex) or #text

            -- move cursor right
            setCaretPosition(self, text:sub(1, offset))

        end
        return false
    end)

    self:onDisplay(function (event)
        local startX, endX = self.startX or 0, self.endX or 0
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local width, height = endX - startX, y2 - y1
        local fontData = self.fontData
        local font = fontData.font
        local textColor = fontData.color
        local textTop = math.floor(y1 + ((y2 - y1) - font:getHeight()) / 2)

        love.graphics.push('all')
        love.graphics.setFont(font)
        love.graphics.setColor(textColor)
        love.graphics.print(self.value, x1, textTop)
        if not self.focused then
            love.graphics.pop()
            return
        end
        love.graphics.setBlendMode(blendMultiply)
        love.graphics.setColor(self.highlight)
        love.graphics.rectangle('fill', startX, y1, width, height)
        if love.timer.getTime() % 2 < 1.75 then
            love.graphics.setColor(textColor)
            love.graphics.rectangle('fill', endX, y1, 1, height)
        end
        love.graphics.pop()
    end)
end
