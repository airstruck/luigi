--[[--
A progress bar.

Set the widget's `value` property to a decimal value
between 0 and 1 (inclusive) to change the width of the bar.

@widget progress
--]]--

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
        local x, y, w, h = self:getRectangle(true, true)
        local min = bar.minwidth
        x = x + min
        bar.width = self.value * w + min
    end)
end
