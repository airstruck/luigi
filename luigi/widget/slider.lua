return function (self)

    self.value = 0.5
    self.flow = 'x' -- TODO: support vertical slider

    local spacer = self:addChild()

    local thumb = self:addChild {
        type = 'button',
        align = 'middle center',
        width = 0,
        margin = 0,
    }

    local function unpress ()
        thumb.pressed = false
    end

    thumb:onPressStart(unpress)
    thumb:onPressEnter(unpress)

    self:onPressDrag(function (event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        self.value = (event.x - x1) / (x2 - x1)
        if self.value < 0 then self.value = 0 end
        if self.value > 1 then self.value = 1 end
        self:reflow()
    end)

    self:onReshape(function (event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        spacer.width = self.value * (x2 - x1 - thumb:getWidth())
    end)
end
