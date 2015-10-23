local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Font = require(ROOT .. 'font')

local Renderer = Base:extend()

local imageCache = {}

function Renderer:loadImage (path)
    if not imageCache[path] then
        imageCache[path] = love.graphics.newImage(path)
    end

    return imageCache[path]
end

function Renderer:renderBackground (widget, window)
    local bg = widget.background
    if not bg then return end
    local bend = widget.bend
    local x1, y1, x2, y2 = widget:getRectangle(true)
    window:fill(x1, y1, x2, y2, bg)
end

function Renderer:renderOutline (widget, window)
    if not widget.outline then return end
    local x1, y1, x2, y2 = widget:getRectangle(true)
    window:outline(x1, y1, x2, y2, widget.outline)
end

-- returns icon coordinates and rectangle with remaining space
function Renderer:positionIcon (widget, x1, y1, x2, y2)
    if not widget.icon then
        return nil, nil, x1, y1, x2, y2
    end

    local icon = self:loadImage(widget.icon)
    local iconWidth, iconHeight = icon:getWidth(), icon:getHeight()
    local align = widget.align or ''
    local padding = widget.padding or 0
    local x, y

    -- horizontal alignment
    if align:find('right') then
        x = x2 - iconWidth
        x2 = x2 - iconWidth - padding
    elseif align:find('center') then
        x = x1 + (x2 - x1) / 2 - iconWidth / 2
    else -- if align:find('left') then
        x = x1
        x1 = x1 + iconWidth + padding
    end

    -- vertical alignment
    if align:find('bottom') then
        y = y2 - iconHeight
    elseif align:find('middle') then
        y = y1 + (y2 - y1) / 2 - iconHeight / 2
    else -- if align:find('top') then
        y = y1
    end

    return x, y, x1, y1, x2, y2
end

-- returns text coordinates
function Renderer:positionText (widget, x1, y1, x2, y2)
    if not widget.text then
        return nil, nil, x1, y1, x2, y2
    end

    if not widget.fontData then
        widget.fontData = Font(widget.font, widget.fontSize, widget.textColor)
    end

    local font = widget.fontData
    local align = widget.align or ''
    local padding = widget.padding or 0

    font:setWidth(x2 - x1)

    -- horizontal alignment
    if align:find('right') then
        font:setAlignment('right')
    elseif align:find('center') then
        font:setAlignment('center')
    elseif align:find('justify') then
        font:setAlignment('justify')
    else -- if align:find('left') then
        font:setAlignment('left')
    end

    local y

    -- vertical alignment
    if align:find('bottom') then
        local textHeight = font:getWrappedHeight(widget.text)
        y = y2 - textHeight
    elseif align:find('middle') then
        local textHeight = font:getWrappedHeight(widget.text)
        y = y2 - (y2 - y1) / 2 - textHeight / 2
    else -- if align:find('top') then
        y = y1
    end

    return font, x1, y
end

function Renderer:renderIconAndText (widget, window)
    local x1, y1, x2, y2 = widget:getRectangle(true, true)

    -- if the drawable area has no width or height, don't render
    if x2 <= x1 or y2 <= y1 then
        return
    end

    love.graphics.push('all')

    love.graphics.setScissor(x1, y1, x2 - x1, y2 - y1)

    local iconX, iconY, textX, textY, font

    -- calculate position for icon and text based on alignment and padding
    iconX, iconY, x1, y1, x2, y2 = self:positionIcon(widget, x1, y1, x2, y2)
    font, textX, textY = self:positionText(widget, x1, y1, x2, y2)

    local icon = widget.icon and self:loadImage(widget.icon)
    local text = widget.text
    local align = widget.align or ''
    local padding = widget.padding or 0

    -- if aligned center, icon displays above the text
    -- reposition icon and text for proper vertical alignment
    if icon and text and align:find('center') then
        local iconHeight = icon:getHeight()
        local textHeight = font:getWrappedHeight(text)
        local contentHeight = textHeight + padding + iconHeight
        local offset = ((y2 - y1) - contentHeight) / 2

        if align:find('middle') then
            iconY = y1 + offset
            textY = y1 + offset + padding + iconHeight
        elseif align:find('top') then
            iconY = y1
            textY = y1 + padding + iconHeight
        else -- if align:find('bottom')
            textY = y2 - textHeight
            iconY = textY - padding - iconHeight
        end
    end

    -- draw the icon
    if icon then
        iconX, iconY = math.floor(iconX), math.floor(iconY)
        if widget.tint then
            love.graphics.setColor(widget.tint)
        end
        love.graphics.draw(icon, iconX, iconY)
    end

    -- draw the text
    if text then
        textX, textY = math.floor(textX), math.floor(textY)
        love.graphics.setFont(font.font)
        love.graphics.setColor(font.color)

        local layout = font.layout
        love.graphics.printf(text, textX, textY, x2 - x1, layout.align)
    end

    love.graphics.pop()
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
