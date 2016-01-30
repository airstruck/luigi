local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Shortcut = require(ROOT .. 'shortcut')

local Input = Base:extend()

local weakValueMeta = { __mode = 'v' }

function Input:constructor ()
    self.pressedWidgets = setmetatable({}, weakValueMeta)
    self.passedWidgets = setmetatable({}, weakValueMeta)
end

function Input:handleDisplay (layout)
    local root = layout.root
    if root then root:paint() end
    Event.Display:emit(layout)
end

function Input:handleKeyPress (layout, key, x, y)
    local widget = layout.focusedWidget or layout.root
    local result = widget:bubbleEvent('KeyPress', {
        key = key,
        modifierFlags = Shortcut.getModifierFlags(),
        x = x, y = y
    })
    if result ~= nil then return result end
    if layout.root.modal then return false end
end

function Input:handleKeyRelease (layout, key, x, y)
    local widget = layout.focusedWidget or layout.root
    local result = widget:bubbleEvent('KeyRelease', {
        key = key,
        modifierFlags = Shortcut.getModifierFlags(),
        x = x, y = y
    })
    if result ~= nil then return result end
    if layout.root.modal then return false end
end

function Input:handleTextInput (layout, text, x, y)
    local widget = layout.focusedWidget or layout.root
    local result = widget:bubbleEvent('TextInput', {
        text = text,
        x = x, y = y
    })
    if result ~= nil then return result end
    if layout.root.modal then return false end
end

local function checkHit (widget, layout)
    local root = layout.root
    return widget and widget.solid or root.modal, widget or root
end

function Input:handleMove (layout, x, y)
    local hit, widget = checkHit(layout:getWidgetAt(x, y), layout)
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
    local hit, widget = checkHit(layout:getWidgetAt(x, y), layout)
    for _, button in ipairs { 'left', 'middle', 'right' } do
        local originWidget = self.pressedWidgets[button]
        if originWidget then
            local passedWidget = self.passedWidgets[button]
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
                originWidget.pressed[button] = (widget == originWidget) or nil
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
        end -- if originWidget
    end -- mouse buttons
    return hit
end

function Input:handlePressStart (layout, button, x, y, widget, shortcut)
    local hit, widget = checkHit(widget or layout:getWidgetAt(x, y), layout)
    -- if hit then
        self.pressedWidgets[button] = widget
        self.passedWidgets[button] = widget
        widget.pressed[button] = true
        if button == 'left' then
            widget:focus()
        end
    -- end
    widget:bubbleEvent('PressStart', {
        hit = hit,
        button = button,
        shortcut = shortcut,
        x = x, y = y
    })
    return hit
end

function Input:handlePressEnd (layout, button, x, y, widget, shortcut)
    local originWidget = widget or self.pressedWidgets[button]
    if not originWidget then return end
    local hit, widget = checkHit(widget or layout:getWidgetAt(x, y), layout)
    local wasPressed = originWidget.pressed[button]
    if hit then
        originWidget.pressed[button] = nil
    end
    widget:bubbleEvent('PressEnd', {
        hit = hit,
        origin = originWidget,
        shortcut = shortcut,
        button = button,
        x = x, y = y
    })
    if (widget == originWidget and wasPressed) then
        widget:bubbleEvent('Press', {
            hit = hit,
            button = button,
            shortcut = shortcut,
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

    root:reshape()

    if root.type ~= 'window' then -- FIXME: move stuff below to a Widget method
        if not root.width then
            root.dimensions.width = width
        end
        if not root.height then
            root.dimensions.height = height
        end
    end

    Event.Reshape:emit(layout, {
        target = layout,
        width = width,
        height = height
    })
end

function Input:handleWheelMove (layout, scrollX, scrollY)
    local x, y = Backend.getMousePosition()
    local hit, widget = checkHit(layout:getWidgetAt(x, y), layout)

    widget:bubbleEvent('WheelMove', {
        hit = hit,
        x = x, y = y,
        scrollX = scrollX, scrollY = scrollY
    })

    return hit
end

Input.default = Input()

return Input
