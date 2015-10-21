local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Font = require(ROOT .. 'font')

local Renderer = Base:extend()

function Renderer:renderBackground (widget, window)
    local bg = widget.background
    if not bg then return end
    local bend = widget.bend
    local x1, y1, x2, y2 = widget:getRectangle(true)
    window:fill(x1, y1, x2, y2, bg, bend)
end

function Renderer:renderOutline (widget, window)
    if not widget.outline then return end
    local x1, y1, x2, y2 = widget:getRectangle(true)
    window:outline(x1, y1, x2, y2, widget.outline)
end

local imageCache = {}

local function loadImage (path)
    if not imageCache[path] then
        imageCache[path] = love.graphics.newImage(path)
    end

    return imageCache[path]
end

-- TODO: this function is a monster, fix it somehow
function Renderer:renderIconAndText (widget, window)
    local x1, y1, x2, y2 = widget:getRectangle(true, true)
    local icon = widget.icon and loadImage(widget.icon)
    local align = widget.align or ''
    local padding = widget.padding or 0
    local text = widget.text
    local x, y, iconWidth, iconHeight

    if icon then
        iconWidth, iconHeight = icon:getWidth(), icon:getHeight()
        -- horizontal alignment
        if align:find('right') then
            x = x2 - iconWidth
        elseif align:find('center') then
            x = x1 + (x2 - x1) / 2 - iconWidth / 2
        else -- if align:find('left') then
            x = x1
        end

        -- vertical alignment
        if align:find('bottom') then
            y = y2 - iconHeight
        elseif align:find('middle') then
            y = y1 + (y2 - y1) / 2 - iconHeight / 2
        else -- if align:find('top') then
            y = y1
        end

        --[[
        if text and align:find('center') then
            if align:find('bottom') then
                y = y - textHeight - padding
            elseif align:find('middle') then
                y = y - (textHeight + padding) / 2
            end
        end
        --]]

        love.graphics.draw(icon, x, y)
    end

    -- render text
    if not text then return end

    if not widget.fontData then
        widget.fontData = Font(widget.font, widget.fontSize, widget.textColor)
    end

    local font = widget.fontData

    if icon then
        if align:find('center') then
            -- y1 = y1 + iconHeight + padding
        elseif align:find('right') then
            x2 = x2 - iconWidth - padding
        else
            x1 = x1 + iconWidth + padding
        end
    end

    font:setWidth(x2 - x1)
    if align:find('right') then
     font:setAlignment('right')
    elseif align:find('center') then
     font:setAlignment('center')
    elseif align:find('justify') then
     font:setAlignment('justify')
    else -- if align:find('left') then
     font:setAlignment('left')
    end

    local textHeight = font:getWrappedHeight(text)

    local x, y

    -- vertical alignment
    if align:find('bottom') then
        y = y2 - textHeight
    elseif align:find('middle') then
        y = y2 - (y2 - y1) / 2 - textHeight / 2
        if icon and align:find('center') then
            y = y1 + (iconHeight + padding) / 2
        end
    else -- if align:find('top') then
        y = y1
        if icon and align:find('center') then
            y = y1 + iconHeight + padding
        end
    end

    x = math.floor(x1)
    y = math.floor(y)

    window:write(x, y, x1, y1, x2, y2, text, font)
end

function Renderer:renderChildren (widget)
    for i, child in ipairs(widget.children) do self:render(child) end
end

function Renderer:render (widget)
    Event.Display:emit(widget, {}, function()
        local window = widget.layout.window
        self:renderBackground(widget, window)
        self:renderOutline(widget, window)
        self:renderIconAndText(widget, window)
        return self:renderChildren(widget)
    end)
end

return Renderer
