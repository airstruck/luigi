local Hooker = {}

local wrapped = setmetatable({}, { __mode = 'k' })

local hooks = setmetatable({}, { __mode = 'k' })

local function unhook (item)
    if item.prev then
        item.prev.next = item.next
    end

    if item.next then
        item.next.prev = item.prev
    end

    if hooks[item.host][item.key] == item then
        hooks[item.host][item.key] = item.next
    end

    item.host = nil
    item.prev = nil
    item.next = nil
    item.func = nil
end

local function hook (host, key, func)
    if not func then
        return
    end

    if not hooks[host] then
        hooks[host] = {}
    end

    local next = hooks[host][key]
    local item = {
        next = next,
        unhook = unhook,
        host = host,
        key = key,
        func = func,
    }

    if next then
        next.prev = item
    end

    hooks[host][key] = item

    return item
end

function Hooker.unhook (item)
    return unhook(item)
end

function Hooker.hook (host, key, func)
    if not wrapped[host] then
        wrapped[host] = {}
    end

    if not wrapped[host][key] then
        wrapped[host][key] = true

        hook(host, key, host[key])

        host[key] = function (...)
            local item = hooks[host][key]

            while item do
                local result = item.func(...)
                if result ~= nil then
                    return result
                end
                item = item.next
            end
        end
    end

    return hook(host, key, func)
end

return Hooker
