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
end

local function hook (host, key, func, atEnd)
    if not func then
        return
    end

    if not hooks[host] then
        hooks[host] = {}
    end

    local current = hooks[host][key]
    local item = {
        next = not atEnd and current or nil,
        unhook = unhook,
        host = host,
        key = key,
        func = func,
    }

    if atEnd then
        if current then
            while current.next do
                current = current.next
            end
            current.next = item
            item.prev = current
        else
            hooks[host][key] = item
        end
        return item
    end

    if current then
        current.prev = item
    end

    hooks[host][key] = item

    return item
end

function Hooker.unhook (item)
    return unhook(item)
end

function Hooker.hook (host, key, func, atEnd)
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
            end -- while
        end -- function
    end -- if

    return hook(host, key, func, atEnd)
end

return Hooker
