--[[--
A stepper.

This widget is composed of two buttons and a content area.
Upon creation, this widget's children are moved into the
`items` attribute. The items are displayed one at a time in
the content area. Pressing the buttons cycles through the
item displayed in the content area.

@widget stepper
--]]--

return function (self)

--[[--
Special Attributes

@section special
--]]--

--[[--
Content items.

Contains an array of child widgets to be displayed.

@attrib items
--]]--
    self:defineAttribute('items', {})

--[[--
Child item index.

Contains the index in `items` of the item being displayed.

@attrib index
--]]--
    self:defineAttribute('index', {})
--[[--
@section end
--]]--

    self.items = {}
    self.index = 1

    for index, child in ipairs(self) do
        child.type = child.type or 'stepper.item'
        self.items[index] = child
        self[index] = nil
    end

    local before = self:addChild { type = 'stepper.before' }
    local view = self:addChild { type = 'stepper.view' }
    local after = self:addChild { type = 'stepper.after' }

    self:onReshape(function (event)
        if self.flow == 'x' then
            before.height = false
            after.height = false
            before.width = 0
            after.width = 0
        else
            before.width = false
            after.width = false
            before.height = 0
            after.height = 0
        end
    end)

    local function updateValue ()
        local item = self.items[self.index]
        self.value = item.value
        view[1] = nil
        view:addChild(item)
        view:reshape()
    end

    local function decrement ()
        if not self.items then return end
        self.index = self.index - 1
        if self.index < 1 then
            self.index = #self.items
        end
        updateValue()
    end

    local function increment ()
        if not self.items then return end
        self.index = self.index + 1
        if self.index > #self.items then
            self.index = 1
        end
        updateValue()
    end

    before:onPress(function (event)
        if event.button ~= 'left' then return end
        if self.flow == 'x' then decrement() else increment() end
    end)

    after:onPress(function (event)
        if event.button ~= 'left' then return end
        if self.flow == 'x' then increment() else decrement() end
    end)

    updateValue()
end
