--[[--
Layout class.

@classmod Layout
--]]--

local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Widget = require(ROOT .. 'widget')
local Input = require(ROOT .. 'input')
local Style = require(ROOT .. 'style')
local Hooker = require(ROOT .. 'hooker')

local Layout = Base:extend()

--[[--
Layout constructor.

@function Luigi.Layout

@tparam table data
A tree of widget data.

@treturn Layout
A Layout instance.
--]]--
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

--[[--
Set the style from a definition table or function.

@tparam table|function rules
Style definition.
--]]--
function Layout:setStyle (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.style = Style(rules or {}, { 'id', 'style' })
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
Show the layout.

Hooks all appropriate Love events and callbacks.
--]]--
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

--[[--
Hide the layout.

Unhooks Love events and callbacks.
--]]--
function Layout:hide ()
    if not self.isManagingInput then
        return
    end
    self.isManagingInput = false
    self:unhook()
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

-- Add handlers for keyboard accelerators and tab focus
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

-- ffi

function Layout:showMessage () end

local _, ffi = pcall(require, 'ffi')
if ffi then

    ffi.cdef [[
        int SDL_ShowSimpleMessageBox(
            uint32_t flags,
            const char* title,
            const char* message,
            void* window
        );
    ]]

    function Layout:showMessage (title, message)
        ffi.C.SDL_ShowSimpleMessageBox(0, title, message, nil)
    end

end

return Layout
