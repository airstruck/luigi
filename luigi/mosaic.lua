local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Base = require(ROOT .. 'base')

local Mosaic = Base:extend()

local imageCache = {}
local sliceCache = {}

local function loadImage (path)
    if not imageCache[path] then
        imageCache[path] = Backend.Image(path)
    end

    return imageCache[path]
end

function Mosaic.fromWidget (widget)
    local mosaic = widget.mosaic
    if mosaic and mosaic.slicePath == widget.slices then
        return mosaic
    end
    if widget.slices then
        widget.mosaic = Mosaic(widget.slices)
        return widget.mosaic
    end
end

function Mosaic:constructor (path)
    local slices = self:loadSlices(path)
    self.batch = Backend.SpriteBatch(slices.image)
    self.slices = slices
    self.slicePath = path
end

function Mosaic:setRectangle (x, y, w, h)
    if self.x == x and self.y == y and self.width == w and self.height == h then
        self.needsRefresh = false
        return
    end
    self.needsRefresh = true
    self.x, self.y, self.width, self.height = x, y, w, h
end

function Mosaic:loadSlices (path)
    local slices = sliceCache[path]

    if not slices then
        slices = {}
        sliceCache[path] = slices
        local image = loadImage(path)
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

function Mosaic:draw ()
    local batch = self.batch

    if not self.needsRefresh then
        Backend.draw(batch)
        return
    end

    self.needsRefresh = false

    local x, y, w, h = self.x, self.y, self.width, self.height
    local slices = self.slices
    local sliceWidth, sliceHeight = slices.width, slices.height

    local xScale = (w - sliceWidth * 2) / sliceWidth
    local yScale = (h - sliceHeight * 2) / sliceHeight

    batch:clear()

    batch:add(slices.middleCenter, x + sliceWidth, y + sliceHeight, 0,
    xScale, yScale)

    batch:add(slices.topCenter, x + sliceWidth, y, 0,
        xScale, 1)
    batch:add(slices.bottomCenter, x + sliceWidth, y + h - sliceHeight, 0,
        xScale, 1)

    batch:add(slices.middleLeft, x, y + sliceHeight, 0,
        1, yScale)
    batch:add(slices.middleRight, x + w - sliceWidth, y + sliceHeight, 0,
        1, yScale)

    batch:add(slices.topLeft, x, y)
    batch:add(slices.topRight, x + w - sliceWidth, y)
    batch:add(slices.bottomLeft, x, y + h - sliceHeight)
    batch:add(slices.bottomRight, x + w - sliceWidth, y + h - sliceHeight)

    Backend.draw(batch)
end

return Mosaic
