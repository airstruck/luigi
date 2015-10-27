local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')

local Widget = Base:extend()

Widget.isWidget = true

Widget.registeredTypes = {
    sash = ROOT .. 'widget.sash',
    slider = ROOT .. 'widget.slider',
    stepper = ROOT .. 'widget.stepper',
    text = ROOT .. 'widget.text',
}

function Widget.create (layout, data)
    local path = data.type and Widget.registeredTypes[data.type]

    if path then
        return require(path)(layout, data)
    end

    return Widget(layout, data)
end

function Widget:constructor (layout, data)
    self.type = 'generic'
    self.layout = layout
    self.children = {}
    self.position = { x = nil, y = nil }
    self.dimensions = { width = nil, height = nil }
    self:extract(data)
    layout:addWidget(self)
    local widget = self
    local meta = getmetatable(self)
    local metaIndex = meta.__index
    function meta:__index(property)
        local value = metaIndex[property]
        local style = widget.layout.style
        local theme = widget.layout.theme
        if value ~= nil then return value end
        value = style and style:getProperty(self, property)
        if value ~= nil then return value end
        return theme and theme:getProperty(self, property)
    end
end

function Widget:extract (data)
    local children = self.children
    -- TODO: get rid of pairs somehow
    for k, v in pairs(data) do
        if type(k) == 'number' then
            children[k] = v.isWidget and v or Widget.create(self.layout, v)
            children[k].parent = self
        else
            self[k] = v
        end
    end
end

function Widget:getPrevious ()
    local siblings = self.parent.children
    for i, widget in ipairs(siblings) do
        if widget == self then return siblings[i - 1] end
    end
end

function Widget:getNext ()
    local siblings = self.parent.children
    for i, widget in ipairs(siblings) do
        if widget == self then return siblings[i + 1] end
    end
end

function Widget:addChild (data)
    local layout = self.layout
    local child = Widget.create(layout, data)

    table.insert(self.children, child)
    child.parent = self
    layout:addWidget(child)

    return child
end

local function clamp (value, min, max)
    return value < min and min or value > max and max or value
end

function Widget:calculateDimension (name)
    if self.dimensions[name] then
        return self.dimensions[name]
    end

    local min = (name == 'width') and (self.minimumWidth or 0)
        or (self.minimumHeight or 0)

    local max = self.layout.root[name]

    if self[name] then
        self.dimensions[name] = clamp(self[name], min, max)
        return self.dimensions[name]
    end

    local parent = self.parent

    if not parent then
        self.dimensions[name] = max
        return self.dimensions[name]
    end

    local parentDimension = parent:calculateDimension(name)
    parentDimension = parentDimension - (parent.margin or 0) * 2
    parentDimension = parentDimension - (parent.padding or 0) * 2
    local parentFlow = parent.flow or 'y'
    if (parentFlow == 'y' and name == 'width') or
        (parentFlow == 'x' and name == 'height')
    then
        self.dimensions[name] = clamp(parentDimension, min, max)
        return self.dimensions[name]
    end
    local claimed = 0
    local unsized = 1
    for i, widget in ipairs(self.parent.children) do
        if widget ~= self then
            if widget[name] then
                claimed = claimed + widget:calculateDimension(name)
                if claimed > parentDimension then
                    claimed = parentDimension
                end
            else
                unsized = unsized + 1
            end
        end
    end
    local size = (parentDimension - claimed) / unsized

    size = clamp(size, min, max)
    self.dimensions[name] = size
    return size
end

function Widget:calculatePosition (axis)
    if self.position[axis] then
        return self.position[axis]
    end
    local parent = self.parent
    if not parent then
        self.position[axis] = 0
        return 0
    end
    local parentPos = parent:calculatePosition(axis)
    local p = parentPos
    p = p + (parent.margin or 0)
    p = p + (parent.padding or 0)
    local parentFlow = parent.flow or 'y'
    for i, widget in ipairs(parent.children) do
        if widget == self then
            self.position[axis] = p
            return p
        end
        if parentFlow == axis then
            local dimension = (axis == 'x') and 'width' or 'height'
            p = p + widget:calculateDimension(dimension)
        end
    end
    self.position[axis] = 0
    return 0
end

function Widget:getX ()
    return self:calculatePosition('x')
end

function Widget:getY ()
    return self:calculatePosition('y')
end

function Widget:getWidth ()
    return self:calculateDimension('width')
end

function Widget:getHeight ()
    return self:calculateDimension('height')
end

function Widget:setDimension (name, size)
    local parentDimension = self.parent:calculateDimension(name)
    local claimed = 0
    for i, widget in ipairs(self.parent.children) do
        if widget ~= self and widget[name] then
            claimed = claimed + widget[name]
        end
    end
    if claimed + size > parentDimension then
        size = parentDimension - claimed
    end
    self[name] = size
end

function Widget:setWidth (size)
    return self:setDimension('width', size)
end

function Widget:setHeight (size)
    return self:setDimension('height', size)
end

function Widget:getOrigin ()
    return self:getX(), self:getY()
end

function Widget:getExtent ()
    local x, y = self:getX(), self:getY()
    return x + self:getWidth(), y + self:getHeight()
end

function Widget:getRectangle (useMargin, usePadding)
    local x1, y1 = self:getOrigin()
    local x2, y2 = self:getExtent()
    local function shrink(amount)
        x1 = x1 + amount
        y1 = y1 + amount
        x2 = x2 - amount
        y2 = y2 - amount
    end
    if useMargin then
        shrink(self.margin or 0)
    end
    if usePadding then
        shrink(self.padding or 0)
    end
    return math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2)
end

function Widget:isAt (x, y)
    local x1, y1, x2, y2 = self:getRectangle()
    return (x1 < x) and (x2 > x) and (y1 < y) and (y2 > y)
end

function Widget:getAncestors (includeSelf)
    local instance = includeSelf and self or self.parent
    return function()
        local widget = instance
        if not widget then return end
        instance = widget.parent
        return widget
    end
end

-- Reflow the widget. Call this after changing position/dimensions.
function Widget:reflow ()
    self.position = {}
    self.dimensions = {}
    Event.Reshape:emit(self, {
        target = self
    })
    for i, widget in ipairs(self.children) do
        widget:reflow()
    end
end

Event.injectBinders(Widget)

return Widget
