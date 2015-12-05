--[[--
A menu item.

When a `menu` is created, any sub-items not having a specified type
are automatically given a type of `'menu.item'`. These widgets should
not be explicitly created.

@widget menu.item
--]]--
local ROOT = (...):gsub('[^.]*.[^.]*.[^.]*$', '')

local Backend = require(ROOT .. 'backend')

local Layout, Event

local function addLayoutChildren (self)
    local root = self.menuLayout.root
    local textWidth = 0
    local keyWidth = 0
    local height = 0

    while #root > 0 do rawset(root, #root, nil) end

    root.height = 0
    root.width = 0

    for index, child in ipairs(self.items) do
        child.type = child.type or 'menu.item'
        root:addChild(child)
        local childHeight = child:getHeight()
        height = height + childHeight
        if child.type == 'menu.item' then
            local pad = child.padding or 0
            local tw = child.fontData:getAdvance(child[2].text)
                + pad * 2 + childHeight
            local kw = child.fontData:getAdvance(child[3].text)
                + pad * 2 + childHeight
            textWidth = math.max(textWidth, tw)
            keyWidth = math.max(keyWidth, kw)
        end
    end

    local isSubmenu = self.parentMenu and self.parentMenu.parentMenu
    local x = isSubmenu and self:getWidth() or 0
    local y = isSubmenu and 0 or self:getHeight()

    root.left = self:getX() + x
    root.top = self:getY() + y
    root.height = height
    root.width = textWidth + keyWidth + (root.padding or 0)
end

local function show (self)
    if not self.items or #self.items < 1 then return end

    addLayoutChildren(self)
    self.menuLayout:show()
end

local function deactivateSiblings (target)
    local sibling = target.parent and target.parent[1]
    local wasSiblingOpen

    if not sibling then
        return
    end

    while sibling do
        local layout = sibling.menuLayout
        local items = sibling.items

        sibling.active = nil

        if layout and layout.isShown then
            wasSiblingOpen = true
            layout:hide()
        end

        if items and items[1] then
            deactivateSiblings(items[1])
        end

        sibling = sibling:getNextSibling()
    end

    return wasSiblingOpen
end

local function activate (event, ignoreIfNoneOpen)
    local target = event.target

    while target.parent
    and target.parent.type ~= 'menu' and target.parent.type ~= 'submenu' do
        target = target.parent
        if not target then
            return
        end
    end

    local wasSiblingOpen = deactivateSiblings(target)
    local ignore = ignoreIfNoneOpen and not wasSiblingOpen

    if not ignore then
        show(target)
        target.active = true
    end
end

local function registerLayoutEvents (self)
    local menuLayout = self.menuLayout

    menuLayout:onReshape(function (event)
        menuLayout:hide()
        deactivateSiblings(self.rootMenu[1])
    end)

    menuLayout:onPressStart(function (event)
        if not event.hit then
            menuLayout:hide()
            if self.parentMenu == self.rootMenu then
                deactivateSiblings(self.rootMenu[1])
            end
        else
            activate(event)
        end
    end)

    menuLayout:onPress(function (event)
        for widget in event.target:eachAncestor(true) do
            if widget.type == 'menu.item' and #widget.items == 0 then
                menuLayout:hide()
                deactivateSiblings(self.rootMenu[1])
            end
        end
    end)

    menuLayout:onPressEnd(function (event)
        for widget in event.target:eachAncestor(true) do
            if widget.type == 'menu.item' and #widget.items == 0
            and event.target ~= event.origin then
                widget:bubbleEvent('Press', event)
            end
        end
    end)

    menuLayout:onEnter(activate)
    menuLayout:onPressEnter(activate)
end

local function initialize (self)
    if not self.fontData then
        self.fontData = Backend.Font(self.font, self.size)
    end
    local pad = self.padding or 0
    local isSubmenu = self.parentMenu and self.parentMenu.parentMenu
    local text, key, icon = self.text or '', self.key or '', self.icon
    local textWidth = self.fontData:getAdvance(text) + pad * 2

    if isSubmenu then
        local tc = self.color or { 0, 0, 0, 255 }
        local keyColor = { tc[1], tc[2], tc[3], 0x90 }
        local edgeType
        if #self.items > 0 then
            key = ' '
            edgeType = 'menu.expander'
        else
            key = key:gsub('%f[%w].', string.upper) -- :gsub('-', '+')
        end
        self.height = self.fontData:getLineHeight() + pad * 2
        self.flow = 'x'
        self:addChild { icon = icon, width = self.height }
        self:addChild { text = text, width = textWidth }
        self:addChild {
            type = edgeType,
            text = key,
            align = 'middle right',
            minwidth = self.height,
            color = function ()
                local c = self.color or { 0, 0, 0 }
                return { c[1], c[2], c[3], (c[4] or 256) / 2 }
            end
        }

        self.icon = nil
        self.text = nil
    else
        self.width = textWidth
    end
end

local function extractChildren (self)
    self.items = {}
    for index, child in ipairs(self) do
        self[index] = nil
        self.items[#self.items + 1] = child
        child.parentMenu = self
        child.rootMenu = self.rootMenu
        child.type = child.type or 'menu.item'
    end
end

local function registerEvents (self)
    self:onPressStart(activate)

    self:onEnter(function (event)
        activate(event, true)
    end)

    self:onPressEnter(function (event)
        activate(event, true)
    end)
end

local function createLayout (self)
    Layout = Layout or require(ROOT .. 'layout')

    self.menuLayout = Layout({ type = 'submenu' }, self.rootMenu.layout)
end

return function (self)
    extractChildren(self)
    initialize(self)
    registerEvents(self)

    if not self.items or #self.items < 1 then return end
    createLayout(self)
    registerLayoutEvents(self)
    addLayoutChildren(self)
end
