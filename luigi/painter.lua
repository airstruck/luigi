local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Text = Backend.Text

local Painter = Base:extend()

local imageCache = {}
local sliceCache = {}

local function intersectScissor (x, y, w, h)
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

function Painter:constructor (widget)
    self.widget = widget
end

function Painter:loadImage (path)
    if not imageCache[path] then
        imageCache[path] = Backend.Image(path)
    end

    return imageCache[path]
end

-- TODO: make slices a seperate drawable

function Painter:loadSlices (path)
    local slices = sliceCache[path]

    if not slices then
        slices = {}
        sliceCache[path] = slices
        local image = self:loadImage(path)
        local iw, ih = image:getWidth(), image:getHeight()
        local w, h = math.floor(iw / 3), math.floor(ih / 3)
        local Quad = Backend.Quad

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

function Painter:paintSlices ()
    local widget = self.widget
    local path = widget.slices
    if not path then return end

    local x, y, w, h = widget:getRectangle(true)

    local slices = self:loadSlices(path)

    local batch = Backend.SpriteBatch(slices.image)

    local xScale = (w - slices.width * 2) / slices.width
    local yScale = (h - slices.height * 2) / slices.height

    batch:add(slices.middleCenter, x + slices.width, y + slices.height, 0,
    xScale, yScale)

    batch:add(slices.topCenter, x + slices.width, y, 0,
        xScale, 1)
    batch:add(slices.bottomCenter, x + slices.width, y + h - slices.height, 0,
        xScale, 1)

    batch:add(slices.middleLeft, x, y + slices.height, 0,
        1, yScale)
    batch:add(slices.middleRight, x + w - slices.width, y + slices.height, 0,
        1, yScale)

    batch:add(slices.topLeft, x, y)
    batch:add(slices.topRight, x + w - slices.width, y)
    batch:add(slices.bottomLeft, x, y + h - slices.height)
    batch:add(slices.bottomRight, x + w - slices.width, y + h - slices.height)

    Backend.draw(batch)
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
    local iconX, iconY, x1, y1, x2, y2 = self:positionIcon(
        x, y, x + w, y + h)
    local font, textX, textY = self:positionText(
        x1, y1, x2, y2)

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

    intersectScissor(x, y, w, h)

    -- draw the icon
    if icon then
        iconX, iconY = math.floor(iconX), math.floor(iconY)
        Backend.draw(icon, iconX, iconY)
    end

    -- draw the text
    if text and textX and textY and w > 1 then
        widget.innerHeight = textY - y + widget.textData:getHeight()
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
    Event.PreDisplay:emit(widget, { target = widget }, function()

        local x, y, w, h = widget:getRectangle()

        -- if the drawable area has no width or height, don't paint
        if w < 1 or h < 1 then
            return
        end

        Backend.push()

        if widget.parent then
            intersectScissor(x, y, w, h)
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
