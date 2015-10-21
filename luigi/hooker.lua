local Hooker = {}

local wrapped = {}

local hooks = {}

local function hook (key, func)
    if not func then
        return
    end

    local next = hooks[key]
    local item = { next = next, unhook = unhook, key = key, func = func }

    if next then
        next.prev = item
    end

    hooks[key] = item

    return item
end

local function unhook (item)
    if item.prev then
        item.prev.next = item.next
    end

    if item.next then
        item.next.prev = item.prev
    end

    if hooks[item.key] == item then
        hooks[item.key] = item.next
    end

    item.prev = nil
    item.next = nil
    item.func = nil
end

function Hooker.hook (key, func)
    if not wrapped[key] then
        wrapped[key] = true

        hook(key, love[key])

        love[key] = function (...)
            local item = hooks[key]

            while item do
                item.func(...)
                item = item.next
            end
        end
    end

    return hook(key, func)
end

function Hooker.unhook (item)
    return unhook(item)
end

return Hooker
