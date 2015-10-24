local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Widget = require(ROOT .. 'widget')
local Input = require(ROOT .. 'input')
local Style = require(ROOT .. 'style')
local Hooker = require(ROOT .. 'hooker')

local Layout = Base:extend()

local weakValueMeta = { __mode = 'v' }

function Layout:constructor (data)
    self.widgets = setmetatable({}, weakValueMeta)
    self.root = Widget.create(self, data or {})
    self:setStyle()
    self:setTheme()

    self.isMousePressed = false
    self.isManagingInput = false
    self.hooks = {}
end

function Layout:setStyle (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.style = Style(rules or {}, 'id', 'style')
end

function Layout:setTheme (rules)
    if type(rules) == 'function' then
        rules = rules()
    end
    self.theme = Style(rules or {}, 'type')
end

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
end

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
    table.insert(self.widgets, widget)
end

-- event stuff

function Layout:hook (key, method)
    self.hooks[#self.hooks + 1] = Hooker.hook(key, method)
end

function Layout:unhook ()
    for _, item in ipairs(self.hooks) do
        Hooker.unhook(item)
    end
    self.hooks = {}
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
        return input:handlePressStart(button, x, y)
    end)
    self:hook('mousereleased', function (x, y, button)
        self.isMousePressed = false
        return input:handlePressEnd(button, x, y)
    end)
    self:hook('mousemoved', function (x, y, dx, dy)
        if self.isMousePressed then
            return input:handlePressedMotion(x, y)
        else
            return input:handleMotion(x, y)
        end
    end)
    self:hook('keypressed', function (key, isRepeat)
        return input:handleKeyboard(key, love.mouse.getX(), love.mouse.getY())
    end)
end

-- event binders

Event.injectBinders(Layout)

return Layout
