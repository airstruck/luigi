return function (self)
    self.value = 0
    self.flow = 'x' -- TODO: support vertical progress?

    local bar = self:addChild {
        type = 'progress.bar',
        width = 0,
    }

    self:onChange(function ()
        self:reshape()
    end)

    self:onReshape(function ()
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local min = bar.minwidth
        x1 = x1 + min
        bar.width = self.value * (x2 - x1) + min
    end)
end
