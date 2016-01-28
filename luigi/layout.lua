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

    self.isReady = true
end

--[[--
Create a detached widget.

Internal function used to create widgets that are associated with
a layout, but "detached" from it.

Used by context menus, which use their "owner" widget's layout
for theme and style information but appear in a separate layout.

@tparam table data
A tree of widget data.

@treturn Widget
A widget instance.
--]]--
function Layout:createWidget (data)
    return Widget(self, data)
end

local function clearWidget (widget)
    widget.textData = nil
    widget.fontData = nil
    widget.position = {}
    widget.dimensions = {}
    widget.type = widget.type
    for _, child in ipairs(widget) do
        clearWidget(child)
    end
    local items = widget.items
    if items then
        for _, item in ipairs(items) do
            clearWidget(item)
        end
    end
end

local function reset (self)
    if not self.root then return end
    clearWidget(self.root)
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

    reset(self)
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

    reset(self)
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
    reset(self)
    return self
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

@treturn Layout
Return this layout for chaining.
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

    return self
end

--[[--
Hide the layout.

Unhooks Love events and callbacks.

@treturn Layout
Return this layout for chaining.
--]]--
function Layout:hide ()
    if not self.isShown then
        return
    end
    self.isShown = nil
    Backend.hide(self)

    return self
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
    if not root then
        root = self.root
    end
    -- Loop through in reverse, because siblings defined later in the tree
    -- will overdraw earlier siblings.
    for i = #root, 1, -1 do
        local child = root[i]
        if child:isAt(x, y) then
            local inner = self:getWidgetAt(x, y, child)
            if inner then return inner end
        end
    end

    if root:isAt(x, y) then return root end
end

--[[--
Place a layout near a point or rectangle.

@tparam number left
Number of pixels from window's left edge.

@tparam number top
Number of pixels from window's top edge.

@tparam[opt] number width
Width of the rectangle to place layout outside of, defaults to 0.

@tparam[opt] number height
Height of the rectangle to place layout outside of, defaults to 0.

@treturn Layout
Return this layout for chaining.
--]]--
function Layout:placeNear (left, top, width, height)
    width, height = width or 0, height or 0
    local root = self.root
    -- place to the left if there's no room to the right
    local layoutWidth = root:getWidth()
    local windowWidth, windowHeight = Backend.getWindowSize()
    if left + width + layoutWidth > windowWidth then
        left = left - layoutWidth - width
    else
        left = left + width
    end
    -- place above if there's no room below
    local layoutHeight = root:getHeight()
    if top + height + layoutHeight > windowHeight then
        top = top - layoutHeight - height
    else
        top = top + height
    end
    root.left = left
    root.top = top
end


-- Add handlers for keyboard shortcuts, tab focus, and mouse wheel scroll
function Layout:addDefaultHandlers ()
    self.shortcuts = {}

    for i = 0, 15 do
        self.shortcuts[i] = {}
    end

    self.behavior = {}

    local function createBehavior (name, hooks)
        self.behavior[name] = hooks
        function hooks.destroy ()
            for _, hook in ipairs(hooks) do
                hook:unhook()
            end
            self.behavior[name] = nil
        end
    end

    createBehavior('context', {
        self:onPressStart(function (event)
            -- show context menu on right click
            if event.button ~= 'right' then return end
            local menu = event.target.context
            if not menu then return end
            menu:bubbleEvent('PressStart', event)
            -- make sure it fits in the window
            -- TODO: open in a new borderless window under SDL?
            menu.menuLayout:placeNear(event.x - 1, event.y - 1, 2, 2)
            return false
        end)
    })

    createBehavior('shortcut', {
        self:onKeyPress(function (event)
            local entry = self.shortcuts[event.modifierFlags]
            local widget = entry and entry[event.key]
            if not widget then return end
            widget.hovered = true
            self.input:handlePressStart(self, 'left', event.x, event.y,
                widget, widget.shortcut)
            return false
        end),

        self:onKeyRelease(function (event)
            local entry = self.shortcuts[event.modifierFlags]
            local widget = entry and entry[event.key]
            if not widget then return end
            widget.hovered = false
            self.input:handlePressEnd(self, 'left', event.x, event.y,
                widget, widget.shortcut)
            return false
        end)
    })

    createBehavior('navigate', {
        self:onKeyPress(function (event)
            -- tab/shift-tab cycles focused widget
            if event.key == 'tab' then
                if Backend.isKeyDown('lshift', 'rshift') then
                    self:focusPreviousWidget()
                else
                    self:focusNextWidget()
                end
                return false
            end

            -- space/enter presses focused widget
            local widget = self.focusedWidget
            if widget and event.key == 'space' or event.key == ' '
            or event.key == 'return' then
                self.input:handlePressStart(self, 'left', event.x, event.y,
                    widget, event.key)
                return false
            end
        end),

        self:onKeyRelease(function (event)
            -- space / enter presses focused widget
            local widget = self.focusedWidget
            if widget and event.key == 'space' or event.key == ' '
            or event.key == 'return' then
                self.input:handlePressEnd(self, 'left', event.x, event.y,
                    widget, event.key)
                return false
            end
        end)
    })

    createBehavior('scroll', {
        self:onWheelMove(function (event)
            if not event.hit then return end
            local amount = event.scrollY ~= 0 and event.scrollY or event.scrollX
            for widget in event.target:eachAncestor(true) do
                if widget:scrollBy(amount) then return false end
            end -- ancestor loop
            return false
        end) -- wheel move
    })

    createBehavior('status', {
        self:onEnter(function (event)
            local statusWidget = (self.master or self).statusWidget
            if not statusWidget then return end

            statusWidget.text = event.target.status
            return false
        end)
    })

end

Event.injectBinders(Layout)

return Layout
