return function (self)

    self.value = 0.5

    self:onPressDrag(function (event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        self.value = (event.x - x1) / (x2 - x1)
        if self.value < 0 then self.value = 0 end
        if self.value > 1 then self.value = 1 end
    end)

    self:onDisplay(function (event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local padding = self.padding or 0

        local sx1 = math.floor(x1 + self.value * (x2 - x1) - padding) + 0.5
        local sy1 = math.floor(y1 + padding) + 0.5
        local sx2 = padding * 2
        local sy2 = y2 - y1 - padding

        love.graphics.push('all')

        love.graphics.setColor(self.outline)

        love.graphics.rectangle('fill',
            x1,
            y1 + ((y2 - y1) / 2),
            x2 - x1,
            padding
        )

        love.graphics.setColor(self.background)

        love.graphics.rectangle('fill', sx1, sy1, sx2, sy2)

        love.graphics.setColor(self.outline)

        love.graphics.rectangle('line', sx1, sy1, sx2, sy2)

        love.graphics.pop()

        return false
    end)

end
