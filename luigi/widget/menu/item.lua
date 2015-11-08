local ROOT = (...):gsub('[^.]*.[^.]*.[^.]*$', '')

local Layout

local show

local function deactivateSiblings (target)
    local sibling = target.parent and target.parent[1]
    local wasSiblingOpen

    if not sibling then
        return
    end

    while sibling do
        local layout = sibling.menuLayout

        sibling.active = nil

        if layout and layout.isShown then
            wasSiblingOpen = true
            layout:hide()
        end

        if sibling.items and sibling.items[1] then
            deactivateSiblings(sibling.items[1])
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

show = function (self)
    if not self.items or #self.items < 1 then
        return
    end
    if self.menuLayout then
        self.menuLayout:show()
        return
    end

    local Layout = Layout or require(ROOT .. 'layout')

    local isSubmenu = self.parentMenu and self.parentMenu.parentMenu

    local x = isSubmenu and self:getWidth() or 0
    local y = isSubmenu and 0 or self:getHeight()

    local menuLayout = Layout {
        type = 'submenu',
        left = self:getX() + x,
        top = self:getY() + y,
        width = 0,
        height = 0,
    }

    local root = menuLayout.root

    local rootPad = root.padding or 0

    local textWidth = 0
    local keyWidth = 0

    for index, child in ipairs(self.items) do
        child.type = child.type or 'menu.item'
        root:addChild(child)
        local h = child:getHeight()
        root.height = root:getHeight() + h
        if child.type == 'menu.item' then
            local pad = child.padding or 0
            local tw = child.fontData:getAdvance(child[2].text)
                + pad * 2 + h
            local kw = child.fontData:getAdvance(child[3].text)
                + pad * 4
            textWidth = math.max(textWidth, tw)
            keyWidth = math.max(keyWidth, kw)
        end
    end

    root.width = textWidth + keyWidth + rootPad

    menuLayout:onReshape(function (event)
        menuLayout:hide()
        deactivateSiblings(self.rootMenu[1])
    end)

    menuLayout:onPressStart(function (event)
        if not event.hit then
            menuLayout:hide()
            deactivateSiblings(self.rootMenu[1])
        end
        activate(event)
    end)

    menuLayout:onEnter(activate)

    menuLayout:onPressEnter(activate)

    menuLayout:show()

    self.menuLayout = menuLayout
end

local function extractChild (self, index, child)
    self[index] = nil
    self.items[#self.items + 1] = child
    child.parentMenu = self
    child.rootMenu = self.rootMenu
    child.type = child.type or 'menu.item'
end

return function (self)
    local pad = self.padding or 0
    local isSubmenu = self.parentMenu and self.parentMenu.parentMenu
    local text, key, icon = self.text or '', self.key or '', self.icon
    local textWidth = self.fontData:getAdvance(text) + pad * 2

    self.items = self.items or {}

    for index, child in ipairs(self) do
        extractChild(self, index, child)
    end

    if isSubmenu then
        key = #self.items > 0 and '>' or key
        self.height = self.fontData:getLineHeight() + pad * 2
        self.flow = 'x'
        self:addChild({ icon = icon, width = self.height })
        self:addChild({ text = text, width = textWidth })
        self:addChild({ text = key, align = 'right', minwidth = self.height })

        self.icon = nil
        self.text = nil
    else
        self.width = textWidth
    end

    self:onPressStart(activate)

    self:onEnter(function (event)
        activate(event, true)
    end)

    self:onPressEnter(function (event)
        activate(event, true)
    end)

end
