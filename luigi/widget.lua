local ROOT = (...):gsub('[^.]*$', '')

local Event = require(ROOT .. 'event')
local Font = require(ROOT .. 'font')

local Widget = {}

Event.injectBinders(Widget)

Widget.isWidget = true

Widget.typeDecorators = {
    button = require(ROOT .. 'widget.button'),
    progress = require(ROOT .. 'widget.progress'),
    sash = require(ROOT .. 'widget.sash'),
    slider = require(ROOT .. 'widget.slider'),
    stepper = require(ROOT .. 'widget.stepper'),
    text = require(ROOT .. 'widget.text'),
}

function Widget.register (name, decorator)
    Widget.typeDecorators[name] = decorator
end

local function new (Widget, layout, self)
    self = self or {}
    self.layout = layout
    self.children = {}
    self.position = { x = nil, y = nil }
    self.dimensions = { width = nil, height = nil }
    self.shadowProperties = {}

    for _, property
    in ipairs { 'font', 'fontSize', 'textColor', 'width', 'height' } do
        self.shadowProperties[property] = self[property]
        self[property] = nil
    end

    local meta = setmetatable(self, {
        __index = function (self, property)
            local value = self.shadowProperties[property]
            if value ~= nil then return value end

            local value = Widget[property]
            if value ~= nil then return value end

            local style = self.layout.style
            value = style and style:getProperty(self, property)
            if value ~= nil and value ~= 'defer' then return value end

            local theme = self.layout.theme
            return theme and theme:getProperty(self, property)
        end,
        __newindex = function (self, property, value)
            if property == 'font'
            or property == 'fontSize'
            or property == 'textColor' then
                self.shadowProperties[property] = value
                self.fontData = Font(self.font, self.fontSize, self.textColor)
                return
            end

            if property == 'width' or property == 'height' then
                self.shadowProperties[property] = value
                ;(self.parent or self):reshape()
                return
            end

            rawset(self, property, value)
        end
    })

    self.type = self.type or 'generic'
    self.fontData = Font(self.font, self.fontSize, self.textColor)

    layout:addWidget(self)

    local decorate = Widget.typeDecorators[self.type]

    if decorate then
        decorate(self)
    end

    for k, v in ipairs(self) do
        self.children[k] = v.isWidget and v or new(Widget, self.layout, v)
        self.children[k].parent = self
    end

    return self
end

function Widget:bubbleEvent (eventName, data)
    local event = Event[eventName]
    data = data or {}
    data.target = self
    for ancestor in self:eachAncestor(true) do
        local result = event:emit(ancestor, data)
        if result ~= nil then return result end
    end
    return event:emit(self.layout, data)
end

function Widget:setValue (value)
    local oldValue = self.value
    self.value = value

    self:bubbleEvent('Change', {
        value = value,
        oldValue = oldValue,
    })
end

function Widget:getPrevious ()
    if not self.parent then return end
    local siblings = self.parent.children
    for i, widget in ipairs(siblings) do
        if widget == self then return siblings[i - 1] end
    end
end

function Widget:getNext ()
    if not self.parent then return end
    local siblings = self.parent.children
    for i, widget in ipairs(siblings) do
        if widget == self then return siblings[i + 1] end
    end
end

function Widget:addChild (data)
    local layout = self.layout
    local child = Widget(layout, data or {})

    table.insert(self.children, child)
    child.parent = self

    return child
end

local function clamp (value, min, max)
    return value < min and min or value > max and max or value
end

function Widget:calculateDimension (name)
    if self.dimensions[name] then
        return self.dimensions[name]
    end

    local min = (name == 'width') and (self.minwidth or 0)
        or (self.minheight or 0)

    local max = name == 'width' and love.graphics.getWidth()
        or love.graphics.getHeight()

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
    if not self.parent then
        self[name] = size
        return
    end
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

    local min = (name == 'width') and (self.minwidth or 0)
        or (self.minheight or 0)
            
    self[name] = math.max(size, min)
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

function Widget:eachAncestor (includeSelf)
    local instance = includeSelf and self or self.parent
    return function()
        local widget = instance
        if not widget then return end
        instance = widget.parent
        return widget
    end
end

-- reshape the widget. Call this after changing position/dimensions.
function Widget:reshape ()
    if self.isReshaping then return end
    self.isReshaping = true
    self.position = {}
    self.dimensions = {}
    Event.Reshape:emit(self, {
        target = self
    })
    for i, widget in ipairs(self.children) do
        widget:reshape()
    end
    self.isReshaping = nil
end

return setmetatable(Widget, { __call = new })
