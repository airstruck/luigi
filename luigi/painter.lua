local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Mosaic = require(ROOT .. 'mosaic')
local Text = Backend.Text

local Painter = Base:extend()

local imageCache = {}
-- local sliceCache = {}

function Painter:constructor (widget)
    self.widget = widget
end

function Painter:loadImage (path)
    if not imageCache[path] then
        imageCache[path] = Backend.Image(path)
    end

    return imageCache[path]
end

function Painter:paintSlices ()
    local widget = self.widget
    local mosaic = Mosaic.fromWidget(widget)
    if not mosaic then return end
    local x, y, w, h = widget:getRectangle(true)
    mosaic:setRectangle(x, y, w, h)
    mosaic:draw()
end

function Painter:paintBackground ()
    local widget = self.widget
    if not widget.background then return end
    local x, y, w, h = widget:getRectangle(true)

    Backend.push()
    Backend.setColor(widget.background)
    Backend.drawRectangle('fill', x, y, w, h)
    Backend.pop()
end

function Painter:paintOutline ()
    local widget = self.widget
    if not widget.outline then return end
    local x, y, w, h = widget:getRectangle(true)

    Backend.push()
    Backend.setColor(widget.outline)
    Backend.drawRectangle('line', x + 0.5, y + 0.5, w, h)
    Backend.pop()
end

-- returns icon coordinates and rectangle with remaining space
function Painter:positionIcon (x1, y1, x2, y2)
    local widget = self.widget
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
function Painter:positionText (x1, y1, x2, y2)
    local widget = self.widget
    if not widget.text or x1 >= x2 then
        return nil, nil, x1, y1, x2, y2
    end

    local font = widget:getFont()
    local align = widget.align or ''
    local horizontal = 'left'

    -- horizontal alignment
    if align:find 'right' then
        horizontal = 'right'
    elseif align:find 'center' then
        horizontal = 'center'
    elseif align:find 'justify' then
        horizontal = 'justify'
    end

    if not widget.textData then
        local limit = widget.wrap and x2 - x1 or nil
        widget.textData = Text(
            font, widget.text, widget.color, horizontal, limit)
    end

    local textHeight = widget.textData:getHeight()
    local y

    -- vertical alignment
    if align:find('bottom') then
        y = y2 - textHeight
    elseif align:find('middle') then
        y = y2 - (y2 - y1) / 2 - textHeight / 2
    else -- if align:find('top') then
        y = y1
    end

    return font, x1, y
end

function Painter:paintIconAndText ()
    local widget = self.widget
    if not (widget.icon or widget.text) then return end
    local x, y, w, h = widget:getRectangle(true, true)
    if w < 1 or h < 1 then return end

    -- calculate position for icon and text based on alignment and padding
    local iconX, iconY, x1, y1, x2, y2 = self:positionIcon(x, y, x + w, y + h)
    local font, textX, textY = self:positionText(x1, y1, x2, y2)

    local icon = widget.icon and self:loadImage(widget.icon)
    local text = widget.text
    local align = widget.align or ''
    local padding = widget.padding or 0

    -- if aligned center, icon displays above the text
    -- reposition icon and text for proper vertical alignment
    if icon and text and align:find('center') then
        local iconHeight = icon:getHeight()

        if align:find 'middle' then
            local textHeight = widget.textData:getHeight()
            local contentHeight = textHeight + padding + iconHeight
            local offset = (h - contentHeight) / 2
            iconY = y + offset
            textY = y + offset + padding + iconHeight
        elseif align:find 'top' then
            iconY = y
            textY = y + padding + iconHeight
        else -- if align:find 'bottom'
            local textHeight = widget.textData:getHeight()
            textY = y + h - textHeight
            iconY = textY - padding - iconHeight
        end
    end

    -- horizontal alignment for non-wrapped text
    -- TODO: handle this in Backend.Text
    if text and not widget.wrap then
        if align:find 'right' then
            textX = textX + (w - widget.textData:getWidth())
        elseif align:find 'center' then
            textX = textX + (w - widget.textData:getWidth()) / 2
        end
    end

    Backend.push()

    Backend.intersectScissor(x, y, w, h)

    -- draw the icon
    if icon then
        iconX, iconY = math.floor(iconX), math.floor(iconY)
        Backend.draw(icon, iconX, iconY)
    end

    -- draw the text
    if text and textX and textY and w > 1 then
        widget.innerHeight = textY - y + widget.textData:getHeight()
        widget.innerWidth = textX - x + widget.textData:getWidth()
        textX = math.floor(textX - (widget.scrollX or 0))
        textY = math.floor(textY - (widget.scrollY or 0))
        Backend.draw(widget.textData, textX, textY)
    end

    Backend.pop()
end

function Painter:paintChildren ()
    for i, child in ipairs(self.widget) do
        child:paint()
    end
end

function Painter:paint ()
    local widget = self.widget
    local x, y, w, h = widget:getRectangle()

    -- if the drawable area has no width or height, don't paint
    if w < 1 or h < 1 then return end

    Event.PreDisplay:emit(widget, { target = widget }, function()

        Backend.push()

        if widget.parent then
            Backend.intersectScissor(x, y, w, h)
        else
            Backend.setScissor()
        end

        self:paintBackground()
        self:paintOutline()
        self:paintSlices()
        self:paintIconAndText()
        self:paintChildren()

        Backend.pop()

    end)
    Event.Display:emit(widget, { target = widget })
end

return Painter
