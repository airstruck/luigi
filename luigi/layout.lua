local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')
local Event = require(ROOT .. 'event')
local Window = require(ROOT .. 'window')
local Widget = require(ROOT .. 'widget')
local Input = require(ROOT .. 'input')
local Style = require(ROOT .. 'style')

local Layout = Base:extend()

local weakValueMeta = { __mode = 'v' }

function Layout:constructor (data)
    self.widgets = setmetatable({}, weakValueMeta)
    self.root = Widget.create(self, data or {})
    self:setStyle()
    self:setTheme()
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
    if not self.window then
        self.window = Window(self.input)
    end
    self.window:show(width, height, title)
end

function Layout:hide ()
    self.window:hide()
end

-- Update the display. Call this after you change widget properties
-- that affect display.
function Layout:update (reshape)
    self.window:update(reshape)
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

-- event binders

Event.injectBinders(Layout)

return Layout
