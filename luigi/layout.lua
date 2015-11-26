--[[--
A Layout contains a tree of widgets with a single `root` widget.

Layouts will resize to fit the window unless a `top` or `left`
property is found in the root widget.

Layouts are drawn in the order that they were shown, so the
most recently shown layout shown will always appear on top.

Other events are sent to layouts in the opposite direction,
and are trapped by the first layout that can handle the event
(for example, the topmost layer that is focused or hovered).

@classmod Layout
--]]--

local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')
local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Widget = require(ROOT .. 'widget')
local Input = require(ROOT .. 'input')
local Style = require(ROOT .. 'style')
local Backend = require(ROOT .. 'backend')

local Layout = Base:extend()

Layout.isLayout = true

--[[--
Layout constructor.

@function Luigi.Layout

@tparam table data
A tree of widget data.

@treturn Layout
A Layout instance.
--]]--
function Layout:constructor (data, master)
    data = data or {}

    if master then
        self:setMaster(master)
    else
        self:setTheme(require(ROOT .. 'theme.light'))
        self:setStyle()
    end

    self:addDefaultHandlers()

    self.hooks = {}
    self.isShown = false
    self.root = data

    Widget(self, data)
end

--[[--
Set the master layout for this layout.

This layout's theme and style will be set the same as the master layout, and
widgets added to this layout will be indexed and keyboard-accelerated by the
master layout instead of this layout.

@tparam Layout layout
Master layout

@treturn Layout Self
--]]--
function Layout:setMaster (layout)
    self.master = layout

    function self:addWidget (...)
        return layout:addWidget(...)
    end

    return self
end

--[[--
Set the style from a definition table or function.

@tparam table|function rules
Style definition.

@treturn Layout Self
--]]--
function Layout:setStyle (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.style = Style(rules or {}, { 'style' })

    return self
end

--[[--
Set the theme from a definition table or function.

@tparam table|function rules
Theme definition.
--]]--
function Layout:setTheme (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.theme = Style(rules or {}, { 'type' })
end

--[[--
Get the style from master layout or this layout.

@treturn table
Style table.
--]]--
function Layout:getStyle ()
    return self.master and self.master:getStyle() or self.style
end

--[[--
Get the theme from master layout or this layout.

@treturn table
Theme table.
--]]--
function Layout:getTheme ()
    return self.master and self.master:getTheme() or self.theme
end

--[[--
Show the layout.

Hooks all appropriate Love events and callbacks.
--]]--
function Layout:show ()
    if self.isShown then
        Backend.hide(self)
        self.isShown = nil
    end

    self.isShown = true

    if not self.input then
        self.input = Input.default -- Input(self)
    end

    Backend.show(self)
    self.root:reshape()
end

--[[--
Hide the layout.

Unhooks Love events and callbacks.
--]]--
function Layout:hide ()
    if not self.isShown then
        return
    end
    self.isShown = nil
    Backend.hide(self)
end

--[[--
Focus next focusable widget.

Traverses widgets using Widget:getNextNeighbor until a focusable widget is
found, and focuses that widget.

@treturn Widget
The widget that was focused, or nil
--]]--
function Layout:focusNextWidget ()
    local widget = self.focusedWidget or self.root
    local nextWidget = widget:getNextNeighbor()

    while nextWidget ~= widget do
        if nextWidget:focus() then return nextWidget end
        nextWidget = nextWidget:getNextNeighbor()
    end
end

--[[--
Focus previous focusable widget.

Traverses widgets using Widget:getPreviousNeighbor until a focusable widget is
found, and focuses that widget.

@treturn Widget
The widget that was focused, or nil
--]]--
function Layout:focusPreviousWidget ()
    local widget = self.focusedWidget or self.root
    local previousWidget = widget:getPreviousNeighbor()

    while previousWidget ~= widget do
        if previousWidget:focus() then return previousWidget end
        previousWidget = previousWidget:getPreviousNeighbor()
    end
end

--[[--
Get the innermost widget at given coordinates.

@tparam number x
Number of pixels from window's left edge.

@tparam number y
Number of pixels from window's top edge.

@tparam[opt] Widget root
Widget to search within, defaults to layout root.
--]]--
function Layout:getWidgetAt (x, y, root)
    local widget = root or self.root

    -- Loop through in reverse, because siblings defined later in the tree
    -- will overdraw earlier siblings.
    local childCount = #widget

    for i = childCount, 1, -1 do
        local child = widget[i]
        local inner = self:getWidgetAt(x, y, child)
        if inner then return inner end
    end

    if widget:isAt(x, y) then return widget end
end

-- Internal, called from Widget:new
--[[
function Layout:addWidget (widget)
    if widget.id then
        self[widget.id] = widget
    end
    if widget.key then
        self.accelerators[widget.key] = widget
    end
end
]]

-- Add handlers for keyboard accelerators and tab focus
function Layout:addDefaultHandlers ()
    self.accelerators = {}

    for i = 0, 8 do
        self.accelerators[i] = {}
    end

    self:onKeyPress(function (event)

        -- tab/shift-tab cycles focused widget
        if event.key == 'tab' then
            if Backend.isKeyDown('lshift', 'rshift') then
                self:focusPreviousWidget()
            else
                self:focusNextWidget()
            end
            return
        end

        -- space/enter presses focused widget
        local widget = self.focusedWidget
        if widget and event.key == 'space' or event.key == ' '
        or event.key == 'return' then
            self.input:handlePressStart(self, event.key, event.x, event.y,
                widget, event.key)
            return
        end

        -- accelerators
        local entry = self.accelerators[event.modifierFlags]
        local acceleratedWidget = entry and entry[event.key]
        if acceleratedWidget then
            acceleratedWidget.hovered = true
            self.input:handlePressStart(self, event.key, event.x, event.y,
                acceleratedWidget, event.key)
        end
    end)

    self:onKeyRelease(function (event)

        -- space / enter presses focused widget
        local widget = self.focusedWidget
        if widget and event.key == 'space' or event.key == ' '
        or event.key == 'return' then
            self.input:handlePressEnd(self, event.key, event.x, event.y,
                widget, event.key)
            return
        end

        -- accelerators
        local entry = self.accelerators[event.modifierFlags]
        local acceleratedWidget = entry and entry[event.key]

        if acceleratedWidget then
            acceleratedWidget.hovered = false
            self.input:handlePressEnd(self, event.key, event.x, event.y,
                acceleratedWidget, event.key)
        end
    end)
end

Event.injectBinders(Layout)

return Layout
