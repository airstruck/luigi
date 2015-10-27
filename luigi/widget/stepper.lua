return function (self)

    self.flow = 'x'
    self.index = 1

    local left = self:addChild {
        type = 'button',
        text = '<',
        align = 'middle center',
        margin = 0,
    }

    local view = self:addChild {
        align = 'middle center',
        margin = 0,
    }

    local right = self:addChild {
        type = 'button',
        text = '>',
        align = 'middle center',
        margin = 0,
    }

    self:onReshape(function (event)
        left.width = left:getHeight()
        right.width = right:getHeight()
    end)

    local function updateValue ()
        if not self.options then return end
        local option = self.options[self.index]
        self.value = option.value
        view.text = option.text
    end

    left:onPress(function (event)
        if not self.options then return end
        self.index = self.index - 1
        if self.index < 1 then
            self.index = #self.options
        end
        updateValue()
    end)

    right:onPress(function (event)
        if not self.options then return end
        self.index = self.index + 1
        if self.index > #self.options then
            self.index = 1
        end
        updateValue()
    end)

    updateValue()

end
