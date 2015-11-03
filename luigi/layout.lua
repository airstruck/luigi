local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Widget = require(ROOT .. 'widget')
local Input = require(ROOT .. 'input')
local Style = require(ROOT .. 'style')
local Hooker = require(ROOT .. 'hooker')

local Layout = Base:extend()

function Layout:constructor (data)
    self.accelerators = {}
    self:addDefaultHandlers()
    self:setStyle()
    self:setTheme(require(ROOT .. 'theme.light'))

    self.isMousePressed = false
    self.isManagingInput = false
    self.hooks = {}
    self.root = data or {}
    Widget(self, self.root)
end

-- focus a widget if it's focusable, and return success
function Layout:tryFocus (widget)
    if widget.canFocus then
        if self.focusedWidget then
            self.focusedWidget.focused = false
        end
        widget.focused = true
        self.focusedWidget = widget
        return true
    end
end

-- get the next widget, cycling back around to root (depth first)
function Layout:getNextWidget (widget)
    if #widget.children > 0 then
        return widget.children[1]
    end
    for ancestor in widget:eachAncestor(true) do
        local nextWidget = ancestor:getNext()
        if nextWidget then return nextWidget end
    end
    return self.root
end

-- get the last child of the last child of the last child of the...
local function getGreatestDescendant (widget)
    while #widget.children > 0 do
        local children = widget.children
        widget = children[#children]
    end
    return widget
end

-- get the previous widget, cycling back around to root (depth first)
function Layout:getPreviousWidget (widget)
    if widget == self.root then
        return getGreatestDescendant(widget)
    end
    for ancestor in widget:eachAncestor(true) do
        local previousWidget = ancestor:getPrevious()
        if previousWidget then
            return getGreatestDescendant(previousWidget)
        end
        if ancestor ~= widget then return ancestor end
    end
    return self.root
end

-- focus next focusable widget (depth first)
function Layout:focusNextWidget ()
    local widget = self.focusedWidget or self.root
    local nextWidget = self:getNextWidget(widget)

    while nextWidget ~= widget do
        if self:tryFocus(nextWidget) then return end
        nextWidget = self:getNextWidget(nextWidget)
    end
end

-- focus previous focusable widget (depth first)
function Layout:focusPreviousWidget ()
    local widget = self.focusedWidget or self.root
    local previousWidget = self:getPreviousWidget(widget)

    while previousWidget ~= widget do
        if self:tryFocus(previousWidget) then return end
        previousWidget = self:getPreviousWidget(previousWidget)
    end
end

-- handlers for keyboard accelerators and tab focus
function Layout:addDefaultHandlers ()
    self:onKeyPress(function (event)

        -- tab / shift-tab cycles focused widget
        if event.key == 'tab' then
            if love.keyboard.isDown('lshift', 'rshift') then
                self:focusPreviousWidget()
            else
                self:focusNextWidget()
            end
            return
        end

        -- space / enter presses focused widget
        local widget = self.focusedWidget
        if widget and event.key == 'space' or event.key == ' '
        or event.key == 'return' then
            self.input:handlePressStart(event.key, event.x, event.y,
                widget, event.key)
            return
        end

        -- accelerators
        local acceleratedWidget = self.accelerators[event.key]

        if acceleratedWidget then
            acceleratedWidget.hovered = true
            self.input:handlePressStart(event.key, event.x, event.y,
                acceleratedWidget, event.key)
        end
    end)

    self:onKeyRelease(function (event)

        -- space / enter presses focused widget
        local widget = self.focusedWidget
        if widget and event.key == 'space' or event.key == ' '
        or event.key == 'return' then
            self.input:handlePressEnd(event.key, event.x, event.y,
                widget, event.key)
            return
        end

        -- accelerators
        local acceleratedWidget = self.accelerators[event.key]

        if acceleratedWidget then
            acceleratedWidget.hovered = false
            self.input:handlePressEnd(event.key, event.x, event.y,
                acceleratedWidget, event.key)
        end
    end)
end

-- set the style from a definition table or function
function Layout:setStyle (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.style = Style(rules or {}, { 'id', 'style' })
end

-- set the theme from a definition table or function
function Layout:setTheme (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.theme = Style(rules or {}, { 'type' })
end

-- show the layout (hooks all appropriate love events and callbacks)
function Layout:show ()
    local root = self.root
    local width = root.width
    local height = root.height
    local title = root.title
    if not self.input then
        self.input = Input(self)
    end

    local currentWidth, currentHeight, flags = love.window.getMode()
    love.window.setMode(width or currentWidth, height or currentHeight, flags)
    if title then
        love.window.setTitle(title)
    end
    self:manageInput(self.input)
    root:reshape()
end

-- hide the layout (unhooks love events and callbacks)
function Layout:hide ()
    if not self.isManagingInput then
        return
    end
    self.isManagingInput = false
    self:unhook()
end

-- Get the innermost widget at a position, within a root widget.
-- Should always return a widget since all positions are within
-- the layout's root widget.
function Layout:getWidgetAt (x, y, root)
    local widget = root or self.root
    local children = widget.children
    local childCount = #children
    -- Loop through in reverse, because siblings defined later in the tree
    -- will overdraw earlier siblings.
    for i = childCount, 1, -1 do
        local child = children[i]
        local inner = self:getWidgetAt(x, y, child)
        if inner then return inner end
    end
    if widget:isAt(x, y) then return widget end
    if widget == self.root then return widget end
end

-- Internal, called from Widget:new
function Layout:addWidget (widget)
    if widget.id then
        self[widget.id] = widget
    end
    if widget.key then
        self.accelerators[widget.key] = widget
    end
end

-- event stuff

function Layout:hook (key, method)
    self.hooks[#self.hooks + 1] = Hooker.hook(love, key, method)
end

function Layout:unhook ()
    for _, item in ipairs(self.hooks) do
        Hooker.unhook(item)
    end
    self.hooks = {}
end

local getMouseButtonId

if love._version_minor < 10 then
    getMouseButtonId = function (value)
        return value == 'l' and 1
            or value == 'r' and 2
            or value == 'm' and 3
    end
else
    getMouseButtonId = function (value)
        return value
    end
end

function Layout:manageInput (input)
    if self.isManagingInput then
        return
    end
    self.isManagingInput = true

    self:hook('draw', function ()
        input:handleDisplay()
    end)
    self:hook('resize', function (width, height)
        return input:handleReshape(width, height)
    end)
    self:hook('mousepressed', function (x, y, button)
        self.isMousePressed = true
        return input:handlePressStart(getMouseButtonId(button), x, y)
    end)
    self:hook('mousereleased', function (x, y, button)
        self.isMousePressed = false
        return input:handlePressEnd(getMouseButtonId(button), x, y)
    end)
    self:hook('mousemoved', function (x, y, dx, dy)
        if self.isMousePressed then
            return input:handlePressedMove(x, y)
        else
            return input:handleMove(x, y)
        end
    end)
    self:hook('keypressed', function (key, isRepeat)
        return input:handleKeyPress(key, love.mouse.getX(), love.mouse.getY())
    end)
    self:hook('keyreleased', function (key)
        return input:handleKeyRelease(key, love.mouse.getX(), love.mouse.getY())
    end)
    self:hook('textinput', function (text)
        return input:handleTextInput(text, love.mouse.getX(), love.mouse.getY())
    end)
end

-- event binders

Event.injectBinders(Layout)

return Layout
