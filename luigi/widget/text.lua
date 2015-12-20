--[[--
A text entry area.

@widget text
--]]--
local ROOT = (...):gsub('[^.]*.[^.]*$', '')

local utf8 = require(ROOT .. 'utf8')
local Backend = require(ROOT .. 'backend')

local function scrollToCaret (self)
    local x1, y1, w, h = self:getRectangle(true, true)
    local x2, y2 = x1 + w, y1 + h
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

local function findCaretFromText (self, text)
    local font = self:getFont()
    local x = self:getRectangle(true, true)
    return #text, font:getAdvance(text) + x - self.scrollX
end

local function setCaretFromText (self, text, mode)
    local index, x = findCaretFromText(self, text)

    if mode == 'start' or not mode then
        self.startIndex, self.startX = index, x
    end
    if mode == 'end' or not mode then
        self.endIndex, self.endX = index, x
    end

    scrollToCaret(self)
end

-- return caret index and x position
local function findCaretFromPoint (self, x, y)
    local x1 = self:getRectangle(true, true)

    local font = self.fontData
    local width, lastWidth = 0
    local lastPosition = 0

    local function checkPosition (position)
        local text = self.value:sub(1, position - 1)
        lastWidth = width
        width = font:getAdvance(text)
        if width > x + self.scrollX - x1 then
            if position == 1 then
                return 0, x1 - self.scrollX
            end
            return lastPosition, lastWidth + x1 - self.scrollX
        end
        lastPosition = position - 1
    end

    for position in utf8.codes(self.value) do
        local a, b = checkPosition(position)
        if a then return a, b end
    end

    local a, b = checkPosition(#self.value + 1)
    if a then return a, b end

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
    local offset = utf8.offset(text, -1, endIndex + 1) or 0

    setCaretFromText(self, text:sub(1, offset - 1), mode)
end

-- move the caret one character to the right
local function moveCaretRight (self, alterRange)
    local text, endIndex = self.value, self.endIndex

    -- if cursor is at end, do nothing
    if endIndex == #text then
        return false
    end

    local mode = alterRange and 'end'
    local offset = utf8.offset(text, 2, endIndex + 1) or #text

    -- move right
    setCaretFromText(self, text:sub(1, offset - 1), mode)
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
        self.value = text
        setCaretFromText(self, left)
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
    local offset = utf8.offset(text, -1, last + 1) or 0
    local left = text:sub(1, offset - 1)
    text = left .. text:sub(first + 1)
    self.value = text
    setCaretFromText(self, left)
end

local function copyRangeToClipboard (self)
    local text = self.value
    local first, last = getRange(self)
    if last >= first + 1 then
        Backend.setClipboardText(text:sub(first + 1, last))
    end
end

local function pasteFromClipboard (self)
    local text = self.value
    local pasted = Backend.getClipboardText() or ''
    local first, last = getRange(self)
    local left = text:sub(1, first) .. pasted
    text = left .. text:sub(last + 1)
    self.value = text
    setCaretFromText(self, left)
end

local function insertText (self, newText)
    local text = self.value
    local first, last = getRange(self)
    local left = text:sub(1, first) .. newText

    self.value = left .. text:sub(last + 1)
    setCaretFromText(self, left)
end

return function (self)
    self.value = tostring(self.value or self.text or '')
    self.text = ''

--[[--
Special Attributes

@section special
--]]--

--[[--
Highlight color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

This color is used to indicate the selected range of text.

@attrib highlight
--]]--

    self:defineAttribute('highlight')

--[[--
@section end
--]]--
    if not self.highlight then
        self.highlight = { 0x80, 0x80, 0x80, 0x80 }
    end

    self.scrollX = 0

    setCaretFromText(self, self.value)

    self:onPressStart(function (event)
        if event.button ~= 'left' then return end
        self.startIndex, self.startX = findCaretFromPoint(self, event.x)
        self.endIndex, self.endX = self.startIndex, self.startX
    end)

    self:onPressDrag(function (event)
        if event.button ~= 'left' then return end
        self.endIndex, self.endX = findCaretFromPoint(self, event.x)
        scrollToCaret(self)
    end)

    self:onTextInput(function (event)
        insertText(self, event.text)
    end)

    self:onKeyPress(function (event)

        -- ignore tabs (keyboard navigation)
        if event.key == 'tab' then
            return
        end

        -- focus next widget on enter (keyboard navigation)
        if event.key == 'return' then
            self.layout:focusNextWidget()
            -- if the next widget is a button, allow the event to propagate
            -- so that the button is pressed (TODO: is this a good idea?)
            return self.layout.focusedWidget.type ~= 'button' or nil
        end

        if event.key == 'backspace' then

            if not deleteRange(self) then
                deleteCharacterLeft(self)
            end

        elseif event.key == 'left' then

            moveCaretLeft(self, Backend.isKeyDown('lshift', 'rshift'))

        elseif event.key == 'right' then

            moveCaretRight(self, Backend.isKeyDown('lshift', 'rshift'))

        elseif event.key == 'x' and Backend.isKeyDown('lctrl', 'rctrl') then

            copyRangeToClipboard(self)
            deleteRange(self)

        elseif event.key == 'c' and Backend.isKeyDown('lctrl', 'rctrl') then

            copyRangeToClipboard(self)

        elseif event.key == 'v' and Backend.isKeyDown('lctrl', 'rctrl') then

            pasteFromClipboard(self)

        end
        return false
    end)

    self:onDisplay(function (event)
        local startX, endX = self.startX or 0, self.endX or 0
        local x, y, w, h = self:getRectangle(true, true)
        local width, height = endX - startX, h
        local font = self:getFont()
        local color = self.color or { 0, 0, 0, 255 }
        local textTop = math.floor(y + (h - font:getLineHeight()) / 2)

        Backend.push()
        Backend.setScissor(x, y, w, h)
        Backend.setFont(font)

        if self.focused then
            -- draw highlighted selection
            Backend.setColor(self.highlight)
            Backend.drawRectangle('fill', startX, y, width, height)
            -- draw cursor selection
            if Backend.getTime() % 2 < 1.75 then
                Backend.setColor(color)
                Backend.drawRectangle('fill', endX, y, 1, height)
            end
        else
            Backend.setColor { color[1], color[2], color[3],
                (color[4] or 256) / 8 }
            Backend.drawRectangle('fill', startX, y, width, height)
        end

        -- draw text
        Backend.setColor(color)
        Backend.print(self.value, x - self.scrollX, textTop)

        Backend.pop()
    end)
end
