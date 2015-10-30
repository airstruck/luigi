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
    'Reshape', 'Display', 'KeyPress', 'KeyRelease', 'TextInput', 'Move',
    'Enter', 'Leave', 'PressEnter', 'PressLeave',
    'PressStart', 'PressEnd', 'PressDrag', 'PressMove', 'Press',
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
