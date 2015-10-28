return function (self)

    self.value = 0
    self.flow = 'x' -- TODO: support vertical progress?

    local bar = self:addChild {
        type = 'progressInner',
        width = 0,
    }

    self:onReshape(function (event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        bar.width = self.value * (x2 - x1)
    end)
end
