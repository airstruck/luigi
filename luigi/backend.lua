local ROOT = (...):gsub('[^.]*$', '')
local Backend

if _G.love and _G.love._version_minor > 8 then
    Backend = require(ROOT .. 'backend.love')
else
    Backend = require(ROOT .. 'backend.ffisdl')
end

Backend.intersectScissor = Backend.intersectScissor or function (x, y, w, h)
    local sx, sy, sw, sh = Backend.getScissor()
    if not sx then
        return Backend.setScissor(x, y, w, h)
    end
    local x1 = math.max(sx, x)
    local y1 = math.max(sy, y)
    local x2 = math.min(sx + sw, x + w)
    local y2 = math.min(sy + sh, y + h)
    if x2 > x1 and y2 > y1 then
        Backend.setScissor(x1, y1, x2 - x1, y2 - y1)
    else
        -- HACK
        Backend.setScissor(-100, -100, 1, 1)
    end
end

return Backend
