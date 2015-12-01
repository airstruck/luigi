local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Renderer = require(ROOT .. 'renderer')

local Input = Base:extend()

local weakValueMeta = { __mode = 'v' }

function Input:constructor () --(layout)
    -- layout = layout
    self.pressedWidgets = setmetatable({}, weakValueMeta)
    self.passedWidgets = setmetatable({}, weakValueMeta)
end

function Input:handleDisplay (layout)
    local root = layout.root
    if root then Renderer:render(root) end
    Event.Display:emit(layout)
end

function Input:getModifierFlags ()
    local alt = Backend.isKeyDown('lalt', 'ralt') and 1 or 0
    local ctrl = Backend.isKeyDown('lctrl', 'rctrl') and 2 or 0
    local shift = Backend.isKeyDown('lshift', 'rshift') and 4 or 0

    return alt + ctrl + shift
end

function Input:handleKeyPress (layout, key, x, y)
    local widget = layout.focusedWidget or layout.root
    local result = widget:bubbleEvent('KeyPress', {
        key = key,
        modifierFlags = self:getModifierFlags(),
        x = x, y = y
    })
    if result ~= nil then return result end
end

function Input:handleKeyRelease (layout, key, x, y)
    local widget = layout.focusedWidget or layout.root
    local result = widget:bubbleEvent('KeyRelease', {
        key = key,
        modifierFlags = self:getModifierFlags(),
        x = x, y = y
    })
    if result ~= nil then return result end
end

function Input:handleTextInput (layout, text, x, y)
    local widget = layout.focusedWidget or layout.root
    local result = widget:bubbleEvent('TextInput', {
        hit = hit,
        text = text,
        x = x, y = y
    })
    if result ~= nil then return result end
end

function Input:handleMove (layout, x, y)
    local widget = layout:getWidgetAt(x, y)
    local hit = true
    if not widget then
        hit = nil
        widget = layout.root
    end
    local previousWidget = self.previousMoveWidget
    if widget ~= previousWidget then
        if previousWidget then
            for ancestor in previousWidget:eachAncestor(true) do
                ancestor.hovered = nil
            end
        end
        for ancestor in widget:eachAncestor(true) do
            ancestor.hovered = true
        end
    end
    widget:bubbleEvent('Move', {
        hit = hit,
        oldTarget = previousWidget,
        x = x, y = y
    })
    if widget ~= previousWidget then
        if previousWidget then
            previousWidget:bubbleEvent('Leave', {
                hit = hit,
                newTarget = widget,
                x = x, y = y
            })
        end
        widget:bubbleEvent('Enter', {
            hit = hit,
            oldTarget = previousWidget,
            x = x, y = y
        })
        if widget.cursor then
            Backend.setCursor(Backend.getSystemCursor(widget.cursor))
        else
            Backend.setCursor()
        end
        self.previousMoveWidget = widget
    end
    return hit
end

function Input:handlePressedMove (layout, x, y)
    local widget = layout:getWidgetAt(x, y)
    local hit = true
    if not widget then
        hit = nil
        widget = layout.root
    end
    for button = 1, 3 do
        local originWidget = self.pressedWidgets[button]
        local passedWidget = self.passedWidgets[button]
        if originWidget then
            originWidget:bubbleEvent('PressDrag', {
                hit = hit,
                newTarget = widget,
                button = button,
                x = x, y = y
            })
            if (widget == passedWidget) then
                widget:bubbleEvent('PressMove', {
                    hit = hit,
                    origin = originWidget,
                    button = button,
                    x = x, y = y
                })
            else
                originWidget.pressed = (widget == originWidget) or nil
                if passedWidget then
                    passedWidget:bubbleEvent('PressLeave', {
                        hit = hit,
                        newTarget = widget,
                        origin = originWidget,
                        button = button,
                        x = x, y = y
                    })
                end
                widget:bubbleEvent('PressEnter', {
                    hit = hit,
                    oldTarget = passedWidget,
                    origin = originWidget,
                    button = button,
                    x = x, y = y
                })
                self.passedWidgets[button] = widget
            end
        end
    end
    return hit
end

function Input:handlePressStart (layout, button, x, y, widget, accelerator)
    local widget = widget or layout:getWidgetAt(x, y)
    local hit = true
    if not widget then
        hit = nil
        widget = layout.root
    end
    if hit then
        widget.pressed = true
        self.pressedWidgets[button] = widget
        self.passedWidgets[button] = widget
        widget:focus()
    end
    widget:bubbleEvent('PressStart', {
        hit = hit,
        button = button,
        accelerator = accelerator,
        x = x, y = y
    })
    return hit
end

function Input:handlePressEnd (layout, button, x, y, widget, accelerator)
    local widget = widget or layout:getWidgetAt(x, y)
    local hit = true
    if not widget then
        hit = nil
        widget = layout.root
    end
    local originWidget = self.pressedWidgets[button]
    if not originWidget then return end
    if hit then
        originWidget.pressed = nil
    end
    widget:bubbleEvent('PressEnd', {
        hit = hit,
        origin = originWidget,
        accelerator = accelerator,
        button = button,
        x = x, y = y
    })
    if (widget == originWidget) then
        widget:bubbleEvent('Press', {
            hit = hit,
            button = button,
            accelerator = accelerator,
            x = x, y = y
        })
    end
    if hit then
        self.pressedWidgets[button] = nil
        self.passedWidgets[button] = nil
    end
    return hit
end

function Input:handleReshape (layout, width, height)
    local root = layout.root

    Event.Reshape:emit(layout, { target = layout })

    if not root.float then
        root.width = width
        root.height = height
    end
end

function Input:handleWheelMove (layout, x, y)
    local root = layout.root
    local mx, my = Backend.getMousePosition()
    local widget = layout:getWidgetAt(mx, my)

    if not widget then
        hit = nil
        widget = layout.root
    end

    widget:bubbleEvent('WheelMove', {
        hit = hit,
        x = x, y = y
    })

    return hit
end

Input.default = Input()

return Input
