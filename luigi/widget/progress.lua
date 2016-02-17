--[[--
A progress bar.

Set the widget's `value` property to a decimal value
between 0 and 1 (inclusive) to change the width of the bar.

@widget progress
--]]--

return function (self)
    local pad = self:addChild {
        width = 0,
    }
    local bar = self:addChild {
        type = 'progress.bar',
    }

    self:onChange(function ()
        self:reshape()
    end)

    self:onReshape(function ()
        local x1, y1, w, h = self:getRectangle(true, true)
        local x2, y2 = x1 + w, y1 + h
        local value = self.value or 0
        if self.flow == 'x' then
            local min = bar.minwidth or 0
            x1 = x1 + min
            bar.width = value * (x2 - x1) + min
            bar.height = false
            pad.height = 0
        else
            local min = bar.minheight or 0
            y1 = y1 + min
            bar.width = false
            bar.height = false
            pad.height = math.ceil(h - (value * (y2 - y1) + min))
        end
    end)
end
