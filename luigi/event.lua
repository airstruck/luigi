--[[--
Event class.

@classmod Event
--]]--

local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Hooker = require(ROOT .. 'hooker')

local Event = Base:extend({ name = 'Event' })

function Event:emit (target, data, defaultAction)
    local callbacks = self.registry[target]
    local result = callbacks and callbacks(data or {})
    if result ~= nil then return result end
    if defaultAction then defaultAction() end
end

function Event:bind (target, callback)
    local registry = self.registry
    return Hooker.hook(registry, target, callback)
end

--[[--
Event names.
--]]--
Event.names = {
    'Reshape', -- A widget is being reshaped.
    'PreDisplay', -- A widget is about to be drawn.
    'Display', -- A widget was drawn.
    'KeyPress', -- A keyboard key was pressed.
    'KeyRelease', -- A keyboard key was released.
    'TextInput', -- Text was entered.
    'Move', -- The cursor moved, and no button was pressed.
    'Enter', -- The cursor entered a widget, and no button was pressed.
    'Leave', -- The cursor left a widget, and no button was pressed.
    'PressEnter', -- The cursor entered a widget, and a button was pressed.
    'PressLeave', -- The cursor left a widget, and a button was pressed.
    'PressStart', -- A pointer button or keyboard shortcut was pressed.
    'PressEnd', -- A pointer button or keyboard shortcut was released.
    'PressDrag', -- A pressed cursor moved; targets originating widget.
    'PressMove', -- A pressed cursor moved; targets widget at cursor position.
    'Press', -- A pointer button was pressed and released on the same widget.
    'Change', -- A widget's value changed.
    'WheelMove', -- The scroll wheel on the mouse moved.
}

local weakKeyMeta = { __mode = 'k' }

for i, name in ipairs(Event.names) do
    Event[name] = Event:extend({
        name = name,
        registry = setmetatable({}, weakKeyMeta),
    })
end

function Event.injectBinders (t)
    for i, name in ipairs(Event.names) do
        t['on' .. name] = function (...) return Event[name]:bind(...) end
    end
end

return Event
