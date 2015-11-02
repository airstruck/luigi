local utf8 = require 'utf8'

local blendMultiply = love._version_minor < 10 and 'multiplicative'
    or 'multiply'

local function getCaretPosition (self, text)
    local font = self.fontData.font
    local x1, y1, x2, y2 = self:getRectangle(true, true)
    return #text, font:getWidth(text) + x1 - self.scrollX
end

local function scrollToCaret (self)
    local x1, y1, x2, y2 = self:getRectangle(true, true)
    local oldX = self.endX
    local newX

    if oldX <= x1 then
        self.scrollX = self.scrollX - (x1 - oldX)
        newX = x1
    elseif oldX >= x2 then
        self.scrollX = self.scrollX + (oldX - x2 + 1)
        newX = x2 - 1
    end

    if newX then
        self.endX = newX
        self.startX = self.startX + (newX - oldX)
    end
end

local function setCaretPosition (self, text, mode)
    local index, x = getCaretPosition(self, text)

    if mode == 'start' or not mode then
        self.startIndex, self.startX = index, x
    end
    if mode == 'end' or not mode then
        self.endIndex, self.endX = index, x
    end

    scrollToCaret(self)
end

-- return caret index and x position
local function getCaretFromPoint (self, x, y)
    local x1, y1, x2, y2 = self:getRectangle(true, true)

    local font = self.fontData.font
    local width, lastWidth = 0

    for position in utf8.codes(self.value) do
        local index = utf8.offset(self.value, position)
        text = self.value:sub(1, index)
        lastWidth = width
        width = font:getWidth(text)
        if width > x + self.scrollX - x1 then
            if position == 1 then
                return 0, x1 - self.scrollX
            end
            return utf8.offset(self.value, position - 1), lastWidth + x1 - self.scrollX
        end
    end

    return #self.value, width + x1 - self.scrollX
end

-- move the caret one character to the left
local function moveCaretLeft (self, alterRange)
    local text, endIndex = self.value, self.endIndex

    -- if cursor is at beginning, do nothing
    if endIndex < 1 then
        return false
    end

    -- move left
    local mode = alterRange and 'end'
    local offset = utf8.offset(text, -1, endIndex) or 0

    setCaretPosition(self, text:sub(1, offset), mode)
end

-- move the caret one character to the right
local function moveCaretRight (self, alterRange)
    local text, endIndex = self.value, self.endIndex

    -- if cursor is at end, do nothing
    if endIndex == #text then
        return false
    end

    local mode = alterRange and 'end'
    local offset = endIndex < 1 and utf8.offset(text, 1)
        or utf8.offset(text, 2, endIndex) or #text

    -- move right
    setCaretPosition(self, text:sub(1, offset), mode)
end

local function getRange (self)
    if self.startIndex <= self.endIndex then
        return self.startIndex, self.endIndex
    end

    return self.endIndex, self.startIndex
end

local function deleteRange (self)
    local text = self.value
    local first, last = getRange(self)

    -- if expanded range is selected, delete text in range
    if first ~= last then
        local left = text:sub(1, first)
        text = left .. text:sub(last + 1)
        self:setValue(text)
        setCaretPosition(self, left)
        return true
    end
end

local function deleteCharacterLeft (self)
    local text = self.value
    local first, last = getRange(self)

    -- if cursor is at beginning, do nothing
    if first < 1 then
        return
    end

    -- delete character to the left
    local offset = utf8.offset(text, -1, first) or 0
    local left = text:sub(1, offset)
    text = left .. text:sub(first + 1)
    self:setValue(text)
    setCaretPosition(self, left)
end

local function copyRangeToClipboard (self)
    local text = self.value
    local first, last = getRange(self)
    if last >= first + 1 then
        love.system.setClipboardText(text:sub(first + 1, last))
    end
end

local function pasteFromClipboard (self)
    local text = self.value
    local pasted = love.system.getClipboardText() or ''
    local first, last = getRange(self)
    local left = text:sub(1, first) .. pasted
    text = left .. text:sub(last + 1)
    self:setValue(text)
    setCaretPosition(self, left)
end

local function insertText (self, newText)
    local text = self.value
    local first, last = getRange(self)
    local left = text:sub(1, first) .. newText

    self.value = left .. text:sub(last + 1)
    self:setValue(self.value)
    setCaretPosition(self, left)
end

return function (self)
    self.value = self.value or self.text or ''
    self.text = ''
    self:setValue(self.value)
    self.highlight = self.highlight or { 0x80, 0x80, 0x80 }
    self.scrollX = 32

    self:onPressStart(function (event)
        self.startIndex, self.startX = getCaretFromPoint(self, event.x)
        self.endIndex, self.endX = self.startIndex, self.startX
    end)

    self:onPressDrag(function (event)
        self.endIndex, self.endX = getCaretFromPoint(self, event.x)
        scrollToCaret(self)
    end)

    self:onTextInput(function (event)
        insertText(self, event.text)
    end)

    self:onKeyPress(function (event)
        if event.key == 'backspace' then

            if not deleteRange(self) then
                deleteCharacterLeft(self)
            end

        elseif event.key == 'left' then

            moveCaretLeft(self, love.keyboard.isDown('lshift', 'rshift'))

        elseif event.key == 'right' then

            moveCaretRight(self, love.keyboard.isDown('lshift', 'rshift'))

        elseif event.key == 'x' and love.keyboard.isDown('lctrl', 'rctrl') then

            copyRangeToClipboard(self)
            deleteRange(self)

        elseif event.key == 'c' and love.keyboard.isDown('lctrl', 'rctrl') then

            copyRangeToClipboard(self)

        elseif event.key == 'v' and love.keyboard.isDown('lctrl', 'rctrl') then

            pasteFromClipboard(self)

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
        love.graphics.setScissor(x1, y1, x2 - x1, y2 - y1)
        love.graphics.setFont(font)
        love.graphics.setColor(textColor)
        love.graphics.print(self.value, x1 - self.scrollX, textTop)
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
