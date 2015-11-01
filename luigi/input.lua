local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Renderer = require(ROOT .. 'renderer')

local Input = Base:extend()

local weakValueMeta = { __mode = 'v' }

function Input:constructor (layout)
    self.layout = layout
    self.pressedWidgets = setmetatable({}, weakValueMeta)
    self.passedWidgets = setmetatable({}, weakValueMeta)
end

function Input:handleDisplay ()
    local root = self.layout.root
    if root then Renderer:render(root) end
    Event.Display:emit(self.layout)
end

function Input:handleKeyPress (key, x, y)
    local widget = self.layout.focusedWidget or self.layout:getWidgetAt(x, y)
    local result = widget:bubbleEvent('KeyPress', {
        key = key, x = x, y = y
    })
    if result ~= nil then return result end
end

function Input:handleKeyRelease (key, x, y)
    local widget = self.layout.focusedWidget or self.layout:getWidgetAt(x, y)
    local result = widget:bubbleEvent('KeyRelease', {
        key = key, x = x, y = y
    })
    if result ~= nil then return result end
end

function Input:handleTextInput (text, x, y)
    local widget = self.layout.focusedWidget or self.layout:getWidgetAt(x, y)
    widget:bubbleEvent('TextInput', {
        text = text, x = x, y = y
    })
end

function Input:handleMove (x, y)
    local widget = self.layout:getWidgetAt(x, y)
    local previousWidget = self.previousMoveWidget
    if not widget.hovered then
        if previousWidget then
            previousWidget.hovered = nil
        end
        widget.hovered = true
    end
    widget:bubbleEvent('Move', {
        oldTarget = previousWidget,
        x = x, y = y
    })
    if widget ~= previousWidget then
        if previousWidget then
            previousWidget:bubbleEvent('Leave', {
                newTarget = widget,
                x = x, y = y
            })
        end
        widget:bubbleEvent('Enter', {
            oldTarget = previousWidget,
            x = x, y = y
        })
        if widget.cursor then
            love.mouse.setCursor(love.mouse.getSystemCursor(widget.cursor))
        else
            love.mouse.setCursor()
        end
        self.previousMoveWidget = widget
    end
end

function Input:handlePressedMove (x, y)
    local widget = self.layout:getWidgetAt(x, y)
    for button = 1, 3 do
        local originWidget = self.pressedWidgets[button]
        local passedWidget = self.passedWidgets[button]
        if originWidget then
            originWidget:bubbleEvent('PressDrag', {
                newTarget = widget,
                button = button,
                x = x, y = y
            })
            if (widget == passedWidget) then
                widget:bubbleEvent('PressMove', {
                    origin = originWidget,
                    button = button,
                    x = x, y = y
                })
            else
                originWidget.pressed = (widget == originWidget) or nil
                if passedWidget then
                    passedWidget:bubbleEvent('PressLeave', {
                        newTarget = widget,
                        origin = originWidget,
                        button = button,
                        x = x, y = y
                    })
                end
                widget:bubbleEvent('PressEnter', {
                        oldTarget = passedWidget,
                        origin = originWidget,
                        button = button,
                        x = x, y = y
                    })
                self.passedWidgets[button] = widget
            end
        end
    end
end

function Input:handlePressStart (button, x, y, widget, accelerator)
    local widget = widget or self.layout:getWidgetAt(x, y)
    widget.pressed = true
    self.pressedWidgets[button] = widget
    self.passedWidgets[button] = widget
    self.layout:tryFocus(widget)
    widget:bubbleEvent('PressStart', {
        button = button,
        accelerator = accelerator,
        x = x, y = y
    })
end

function Input:handlePressEnd (button, x, y, widget, accelerator)
    local widget = widget or self.layout:getWidgetAt(x, y)
    local originWidget = self.pressedWidgets[button]
    if not originWidget then return end
    originWidget.pressed = nil
    widget:bubbleEvent('PressEnd', {
        origin = originWidget,
        accelerator = accelerator,
        button = button, x = x, y = y
    })
    if (widget == originWidget) then
        widget:bubbleEvent('Press', {
            button = button,
            accelerator = accelerator,
            x = x, y = y
        })
    end
    self.pressedWidgets[button] = nil
    self.passedWidgets[button] = nil
end

function Input:handleReshape (width, height)
    local root = self.layout.root

    root.width = width
    root.height = height
    root:reshape()
end

return Input
