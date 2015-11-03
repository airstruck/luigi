return function (self)
    self.value = 0
    self.flow = 'x' -- TODO: support vertical progress?

    local bar = self:addChild {
        type = 'progressInner',
        width = 0,
    }

    self:onChange(function ()
        self:reshape()
    end)

    self:onReshape(function ()
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local min = bar.minimumWidth
        x1 = x1 + min
        bar.width = self.value * (x2 - x1) + min
    end)
end
