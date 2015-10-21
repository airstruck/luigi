local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')

local Event = Base:extend({ name = 'Event' })

function Event:emit (observer, data, defaultAction)
    local callbacks = self.registry[observer]
    if not callbacks then
        if defaultAction then defaultAction() end
        return
    end
    for i, callback in ipairs(callbacks) do
        local result = callback(data or {})
        if result ~= nil then return result end
    end
    if defaultAction then defaultAction() end
end

function Event:bind (observer, callback)
    local registry = self.registry
    if not registry[observer] then
        registry[observer] = {}
    end
    table.insert(registry[observer], callback)
end

local eventNames = {
    'Display', 'Keyboard', 'Motion', 'Mouse', 'Reshape', 'Enter', 'Leave',
    'Press', 'PressStart', 'PressDrag', 'PressMove', 'PressLeave', 'PressEnter',
    'PressEnd'
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
