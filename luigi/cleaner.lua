local Cleaner = {}

local marked = {}
local watched = setmetatable({}, { __mode = 'k' })

function Cleaner.mark (t, key)
    local length = #marked
    local keys = watched[t]
    if not keys then
        keys = {}
        watched[t] = keys
    elseif keys[key] then
        return
    end
    keys[key] = true
    local i = length + 1
    marked[i] = t
    marked[i + 1] = key
end

function Cleaner.clean ()
    for i = #marked - 1, 1, -2 do
        local t = marked[i]
        local key = marked[i + 1]
        t[key] = nil
        marked[i] = nil
        marked[i + 1] = nil
        watched[t][key] = nil
    end
end

return Cleaner
