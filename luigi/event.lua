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

local eventNames = {
    'Reshape', -- widget's dimensions changed
    'PreDisplay', 'Display', -- before/after widget is drawn
    'KeyPress', 'KeyRelease', -- keyboard key pressed/released
    'TextInput', -- text is entered
    'Move', -- cursor moves, no button pressed
    'Enter', 'Leave', -- cursor enters/leaves widget, no button pressed
    'PressEnter', 'PressLeave', -- cursor enters/leaves widget, button pressed
    'PressStart', 'PressEnd', -- cursor or accelerator key press starts/ends
    'PressDrag', -- pressed cursor moves, targets originating widget
    'PressMove', -- pressed cursor moves, targets widget at cursor position
    'Press', -- cursor is pressed and released on same widget
    'Change', -- widget's value changed via Widget:setValue
}

local weakKeyMeta = { __mode = 'k' }

for i, name in ipairs(eventNames) do
    Event[name] = Event:extend({
        name = name,
        registry = setmetatable({}, weakKeyMeta),
    })
end

function Event.injectBinders (t)
    for i, name in ipairs(eventNames) do
        t['on' .. name] = function (...) return Event[name]:bind(...) end
    end
end

return Event
