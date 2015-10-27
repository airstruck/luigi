local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Font = require(ROOT .. 'font')

local Renderer = Base:extend()

local imageCache = {}
local sliceCache = {}

function Renderer:loadImage (path)
    if not imageCache[path] then
        imageCache[path] = love.graphics.newImage(path)
    end

    return imageCache[path]
end

function Renderer:loadSlices (path)
    local slices = sliceCache[path]

    if not slices then
        slices = {}
        sliceCache[path] = slices
        local image = self:loadImage(path)
        local iw, ih = image:getWidth(), image:getHeight()
        local w, h = math.floor(iw / 3), math.floor(ih / 3)
        local Quad = love.graphics.newQuad

        slices.image = image
        slices.width = w
        slices.height = h

        slices.topLeft = Quad(0, 0, w, h, iw, ih)
        slices.topCenter = Quad(w, 0, w, h, iw, ih)
        slices.topRight = Quad(iw - w, 0, w, h, iw, ih)

        slices.middleLeft = Quad(0, h, w, h, iw, ih)
        slices.middleCenter = Quad(w, h, w, h, iw, ih)
        slices.middleRight = Quad(iw - w, h, w, h, iw, ih)

        slices.bottomLeft = Quad(0, ih - h, w, h, iw, ih)
        slices.bottomCenter = Quad(w, ih - h, w, h, iw, ih)
        slices.bottomRight = Quad(iw - w, ih - h, w, h, iw, ih)
    end

    return slices
end

function Renderer:renderSlices (widget)
    local path = widget.slices
    if not path then return end

    local x1, y1, x2, y2 = widget:getRectangle(true)

    local slices = self:loadSlices(path)

    local batch = love.graphics.newSpriteBatch(slices.image)

    local xScale = ((x2 - x1) - slices.width * 2) / slices.width
    local yScale = ((y2 - y1) - slices.height * 2) / slices.height

    batch:add(slices.middleCenter, x1 + slices.width, y1 + slices.height, 0,
    xScale, yScale)

    batch:add(slices.topCenter, x1 + slices.width, y1, 0,
        xScale, 1)
    batch:add(slices.bottomCenter, x1 + slices.width, y2 - slices.height, 0,
        xScale, 1)

    batch:add(slices.middleLeft, x1, y1 + slices.height, 0,
        1, yScale)
    batch:add(slices.middleRight, x2 - slices.width, y1 + slices.height, 0,
        1, yScale)

    batch:add(slices.topLeft, x1, y1)
    batch:add(slices.topRight, x2 - slices.width, y1)
    batch:add(slices.bottomLeft, x1, y2 - slices.height)
    batch:add(slices.bottomRight, x2 - slices.width, y2 - slices.height)

    love.graphics.draw(batch)
end

function Renderer:renderBackground (widget)
    if not widget.background then return end
    local x1, y1, x2, y2 = widget:getRectangle(true)

    love.graphics.push('all')
    love.graphics.setColor(widget.background)
    love.graphics.rectangle('fill', x1, y1, x2 - x1, y2 - y1)
    love.graphics.pop()
end

function Renderer:renderOutline (widget)
    if not widget.outline then return end
    local x1, y1, x2, y2 = widget:getRectangle(true)

    love.graphics.push('all')
    love.graphics.setColor(widget.outline)
    love.graphics.rectangle('line', x1 + 0.5, y1 + 0.5, x2 - x1, y2 - y1)
    love.graphics.pop()
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

function Renderer:renderIconAndText (widget)
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

        if align:find('middle') then
            local textHeight = font:getWrappedHeight(text)
            local contentHeight = textHeight + padding + iconHeight
            local offset = ((y2 - y1) - contentHeight) / 2
            iconY = y1 + offset
            textY = y1 + offset + padding + iconHeight
        elseif align:find('top') then
            iconY = y1
            textY = y1 + padding + iconHeight
        else -- if align:find('bottom')
            local textHeight = font:getWrappedHeight(text)
            textY = y2 - textHeight
            iconY = textY - padding - iconHeight
        end
    end

    -- draw the icon
    if icon then
        iconX, iconY = math.floor(iconX), math.floor(iconY)
        if widget.tint then
            love.graphics.setBlendMode('alpha', true)
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
        self:renderBackground(widget)
        self:renderOutline(widget)
        self:renderSlices(widget)
        self:renderIconAndText(widget)
        return self:renderChildren(widget)
    end)
end

return Renderer
