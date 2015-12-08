--[[--
Widget class.

@classmod Widget
--]]--

local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Event = require(ROOT .. 'event')
local Attribute = require(ROOT .. 'attribute')
local Font = Backend.Font

local Widget = {}

Event.injectBinders(Widget)

Widget.isWidget = true

Widget.typeDecorators = {
    button = require(ROOT .. 'widget.button'),
    check = require(ROOT .. 'widget.check'),
    menu = require(ROOT .. 'widget.menu'),
    ['menu.item'] = require(ROOT .. 'widget.menu.item'),
    progress = require(ROOT .. 'widget.progress'),
    radio = require(ROOT .. 'widget.radio'),
    sash = require(ROOT .. 'widget.sash'),
    slider = require(ROOT .. 'widget.slider'),
    status = require(ROOT .. 'widget.status'),
    stepper = require(ROOT .. 'widget.stepper'),
    text = require(ROOT .. 'widget.text'),
}

--[[--
Register a custom widget type.

@static

@tparam string name
A unique name for this type of widget.

@tparam function(Widget) decorator
An initialization function for this type of widget.
--]]--
function Widget.register (name, decorator)
    Widget.typeDecorators[name] = decorator
end

local function maybeCall (something, ...)
    return something
end

-- look for properties in attributes, Widget, style, and theme
local function metaIndex (self, property)
    -- look in widget's own attributes
    local A = Attribute[property]
    if A then
        local value = A.get and A.get(self) or self.attributes[property]
        if type(value) == 'function' then value = value(self) end
        if value ~= nil then return value end
    end

    -- look in Widget class properties
    local value = Widget[property]
    if value ~= nil then return value end

    -- look in style
    local layout = self.layout
    value = layout:getStyle():getProperty(self, property)
    if value ~= nil then return value end

    -- look in theme
    return layout:getTheme():getProperty(self, property)
end

-- setting attributes triggers special behavior
local function metaNewIndex (self, property, value)
    local A = Attribute[property]
    if A then
        if A.set then
            A.set(self, value)
        else
            self.attributes[property] = value
        end
    else
        rawset(self, property, value)
    end
end

local attributeNames = {}

for name in pairs(Attribute) do
    if name ~= 'type' then -- type must be handled last
        attributeNames[#attributeNames + 1] = name
    end
end

attributeNames[#attributeNames + 1] = 'type'

--[[--
Widget pseudo-constructor.

@function Luigi.Widget

@within Constructor

@tparam Layout layout
The layout this widget belongs to.

@tparam[opt] table data
The data definition table for this widget.
This table is identical to the constructed widget.

@treturn Widget
A Widget instance.
--]]--
local function metaCall (Widget, layout, self)
    self = self or {}
    self.layout = layout
    self.position = { x = nil, y = nil }
    self.dimensions = { width = nil, height = nil }
    self.attributes = {}

    setmetatable(self, { __index = metaIndex, __newindex = metaNewIndex })

    for _, property in ipairs(attributeNames) do
        local value = rawget(self, property)
        rawset(self, property, nil)
        self[property] = value
    end

    for k, v in ipairs(self) do
        self[k] = v.isWidget and v or metaCall(Widget, self.layout, v)
        self[k].parent = self
    end

    return self
end

--[[--
Fire an event on this widget and each ancestor.

If any event handler returns non-nil, stop the event from propagating.

@tparam string eventName
The name of the Event.

@tparam[opt] table data
Information about the event to send to handlers.

@treturn mixed
The first value returned by an event handler.
--]]--
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

--[[--
Get widget's previous sibling.

@treturn Widget|nil
The widget's previous sibling, if any.
--]]--
function Widget:getPreviousSibling ()
    local parent = self.parent
    if not parent then return end
    for i, widget in ipairs(parent) do
        if widget == self then return parent[i - 1] end
    end
end

--[[--
Get widget's next sibling.

@treturn Widget|nil
The widget's next sibling, if any.
--]]--
function Widget:getNextSibling ()
    local parent = self.parent
    if not parent then return end
    for i, widget in ipairs(parent) do
        if widget == self then return parent[i + 1] end
    end
end

--[[--
Attempt to focus the widget.

Unfocus currently focused widget, and focus this widget if it's focusable.

@treturn boolean
true if this widget was focused, else false.
--]]--
function Widget:focus ()
    local layout = self.layout

    if layout.focusedWidget then
        layout.focusedWidget.focused = nil
        layout.focusedWidget = nil
    end

    if self.focusable then
        self.focused = true
        layout.focusedWidget = self
        return true
    end

    return false
end

--[[--
Get the next widget, depth-first.

If the widget has children, returns the first child.
Otherwise, returns the next sibling of the nearest possible ancestor.
Cycles back around to the layout root from the last widget in the tree.

@treturn Widget
The next widget in the tree.
--]]--
function Widget:getNextNeighbor ()
    if #self > 0 then
        return self[1]
    end
    for ancestor in self:eachAncestor(true) do
        local nextWidget = ancestor:getNextSibling()
        if nextWidget then return nextWidget end
    end
    return self.layout.root
end

-- get the last child of the last child of the last child of the...
local function getGreatestDescendant (widget)
    while #widget > 0 do
        widget = widget[#widget]
    end
    return widget
end

--[[--
Get the previous widget, depth-first.

Uses the reverse of the traversal order used by `getNextNeighbor`.
Cycles back around to the last widget in the tree from the layout root.

@treturn Widget
The previous widget in the tree.
--]]--
function Widget:getPreviousNeighbor ()
    local layout = self.layout

    if self == layout.root then
        return getGreatestDescendant(self)
    end

    for ancestor in self:eachAncestor(true) do
        local previousWidget = ancestor:getPreviousSibling()
        if previousWidget then
            return getGreatestDescendant(previousWidget)
        end
        if ancestor ~= self then return ancestor end
    end

    return layout.root
end

--[[--
Add a child to this widget.

@tparam Widget|table data
A widget or definition table representing a widget.

@treturn Widget
The newly added child widget.
--]]--
function Widget:addChild (data)
    local layout = self.layout
    local child = data and data.isWidget and data or Widget(layout, data or {})

    self[#self + 1] = child
    child.parent = self
    child.layout = self.layout

    return child
end

local function clamp (value, min, max)
    return value < min and min or value > max and max or value
end

local function checkReshape (widget)
    if widget.needsReshape then
        widget.position = {}
        widget.dimensions = {}
        widget.needsReshape = false
    end
end

function Widget:calculateDimension (name)
    checkReshape(self)

    if self.dimensions[name] then
        return self.dimensions[name]
    end

    local min = (name == 'width') and (self.minwidth or 0)
        or (self.minheight or 0)

    local windowWidth, windowHeight = Backend.getWindowSize()

    local max = name == 'width' and windowWidth or windowHeight

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
    for i, widget in ipairs(self.parent) do
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

local function calculateRootPosition (self, axis)
    local value = (axis == 'x' and self.left) or (axis == 'y' and self.top)

    if value then
        self.position[axis] = value
        return value
    end

    local ww, wh = Backend.getWindowSize()

    if axis == 'x' and self.width then
        value = (ww - self.width) / 2
    elseif axis == 'y' and self.height then
        value = (wh - self.height) / 2
    else
        value = 0
    end

    self.position[axis] = value
    return value
end

function Widget:calculatePosition (axis)
    checkReshape(self)

    if self.position[axis] then
        return self.position[axis]
    end
    local parent = self.parent
    local scroll = 0
    if not parent then
        return calculateRootPosition(self, axis)
    else
        scroll = axis == 'x' and (parent.scrollX or 0)
            or axis == 'y' and (parent.scrollY or 0)
    end
    local parentPos = parent:calculatePosition(axis)
    local p = parentPos - scroll
    p = p + (parent.margin or 0)
    p = p + (parent.padding or 0)
    local parentFlow = parent.flow or 'y'
    for i, widget in ipairs(parent) do
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

--[[--
Get the widget's X coordinate.

@treturn number
The widget's X coordinate.
--]]--
function Widget:getX ()
    return self:calculatePosition('x')
end

--[[--
Get the widget's Y coordinate.

@treturn number
The widget's Y coordinate.
--]]--
function Widget:getY ()
    return self:calculatePosition('y')
end

--[[--
Get the widget's calculated width.

@treturn number
The widget's calculated width.
--]]--
function Widget:getWidth ()
    return self:calculateDimension('width')
end

--[[--
Get the widget's calculated height.

@treturn number
The widget's calculated height.
--]]--
function Widget:getHeight ()
    return self:calculateDimension('height')
end

--[[--
Get the content width.

Gets the combined width of the widget's children.

@treturn number
The content width.
--]]--
function Widget:getContentWidth ()
    local width = 0
    for _, child in ipairs(self) do
        width = width + child:getWidth()
    end
    return width
end

--[[--
Get the content height.

Gets the combined height of the widget's children.

@treturn number
The content height.
--]]--
function Widget:getContentHeight ()
    local height = 0
    for _, child in ipairs(self) do
        height = height + child:getHeight()
    end
    return height
end

--[[--
Get x/y/width/height values describing a rectangle within the widget.

@tparam boolean useMargin
Whether to adjust the rectangle based on the widget's margin.

@tparam boolean usePadding
Whether to adjust the rectangle based on the widget's padding.

@treturn number
The upper left corner's X position.

@treturn number
The upper left corner's Y position.

@treturn number
The rectangle's width

@treturn number
The rectangle's height
--]]--
function Widget:getRectangle (useMargin, usePadding)
    local x, y = self:getX(), self:getY()
    local w, h = self:getWidth(), self:getHeight()
    local function shrink(amount)
        x = x + amount
        y = y + amount
        w = w - amount * 2
        h = h - amount * 2
    end
    if useMargin then
        shrink(self.margin or 0)
    end
    if usePadding then
        shrink(self.padding or 0)
    end
    return math.floor(x), math.floor(y), math.floor(w), math.floor(h)
end

--[[--
Determine whether a point is within a widget.

@tparam number x
The point's X coordinate.

@tparam number y
The point's Y coordinate.

@treturn boolean
true if the point is within the widget, else false.
--]]--
function Widget:isAt (x, y)
    checkReshape(self)

    local x1, y1, w, h = self:getRectangle()
    local x2, y2 = x1 + w, y1 + h
    return (x1 <= x) and (x2 >= x) and (y1 <= y) and (y2 >= y)
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

--[[--
Reshape the widget.

Clears calculated widget dimensions, allowing them to be recalculated, and
fires a Reshape event (does not bubble). Called recursively for each child.

When setting a widget's width or height, this function is automatically called
on the parent widget.
--]]--
function Widget:reshape ()
    if self.isReshaping then return end
    self.isReshaping = true
    self.needsReshape = true
    self.textData = nil
    Event.Reshape:emit(self, {
        target = self
    })
    for i, widget in ipairs(self) do
        if widget.reshape then
            widget:reshape()
        end
    end
    self.isReshaping = nil
end

return setmetatable(Widget, { __call = metaCall })
