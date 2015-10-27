local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Hooker = require(ROOT .. 'hooker')

local Event = Base:extend { name = 'Event' }

function Event:emit (target, data, defaultAction)
    while target do
        local handlers = rawget(target, 'eventHandlers')
        local callbacks = handlers and handlers[self.name]
        if callbacks then
            local result = callbacks(data or {})
            if result ~= nil then return result end
        end
        target = target.widgetClass
    end
    if defaultAction then defaultAction() end
end

function Event:bind (target, callback)
    if not rawget(target, 'eventHandlers') then
        target.eventHandlers = {}
    end
    return Hooker.hook(target.eventHandlers, self.name, callback)
end

local eventNames = {
    'Reshape', 'Display', 'Keyboard', 'TextInput', 'Motion',
    'Enter', 'Leave', 'PressEnter', 'PressLeave',
    'PressStart', 'PressEnd', 'PressDrag', 'PressMove', 'Press',
}

local weakKeyMeta = { __mode = 'k' }

for i, name in ipairs(eventNames) do
    Event[name] = Event:extend { name = name }
end

function Event.injectBinders (t)
    for i, name in ipairs(eventNames) do
        t['on' .. name] = function (...) return Event[name]:bind(...) end
    end
end

return Event
