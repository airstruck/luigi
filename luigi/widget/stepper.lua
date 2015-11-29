--[[--
A stepper.

This widget is composed of two buttons and a content area.
Upon creation, this widget's children are moved into an
`items` property. The items are displayed one at a time in
the content area. Pressing the buttons cycles through the
item displayed in the content area.

@widget stepper
--]]--

return function (self)
    self.items = {}
    self.index = 1
    self.flow = 'x' -- TODO: support vertical stepper

    for index, child in ipairs(self) do
        child.type = child.type or 'stepper.item'
        self.items[index] = child
        self[index] = nil
    end

    local decrement = self:addChild { type = 'stepper.left' }
    local view = self:addChild()
    local increment = self:addChild { type = 'stepper.right' }

    self:onReshape(function (event)
        decrement.width = decrement:getHeight()
        increment.width = increment:getHeight()
    end)

    local function updateValue ()
        local item = self.items[self.index]
        self.value = item.value
        view[1] = nil
        view:addChild(item)
        item:reshape()
    end

    decrement:onPress(function (event)
        if not self.items then return end
        self.index = self.index - 1
        if self.index < 1 then
            self.index = #self.items
        end
        updateValue()
    end)

    increment:onPress(function (event)
        if not self.items then return end
        self.index = self.index + 1
        if self.index > #self.items then
            self.index = 1
        end
        updateValue()
    end)

    updateValue()
end
