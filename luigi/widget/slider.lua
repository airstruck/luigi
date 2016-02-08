--[[--
A slider.

Dragging this widget changes its `value` property to a
number between 0 and 1, inclusive.

@widget slider
--]]--

return function (self)
    local function clamp (value)
        return value < 0 and 0 or value > 1 and 1 or value
    end

    self.value = clamp(self.value or 0)
    self.step = self.step or 0.01

    local spacer = self:addChild()

    local thumb = self:addChild {
        type = 'slider.thumb',
    }

    local function unpress (event)
        if event.button ~= 'left' then return end
        thumb.pressed.left = nil -- don't make the thumb appear pushed in
        return false -- don't press thumb on focused keyboard activation
    end

    thumb:onPressStart(unpress)
    thumb:onPressEnter(unpress)

    thumb:onKeyPress(function (event)
        local key = event.key
        if key == 'left' or key == 'down' then
            self.value = clamp(self.value - self.step)
        elseif key == 'right' or key == 'up' then
            self.value = clamp(self.value + self.step)
        end
    end)

    local function press (event)
        if event.button ~= 'left' then return end
        local x1, y1, w, h = self:getRectangle(true, true)
        local x2, y2 = x1 + w, y1 + h
        if self.flow == 'x' then
            local halfThumb = thumb:getWidth() / 2
            x1, x2 = x1 + halfThumb, x2 - halfThumb
            self.value = clamp((event.x - x1) / (x2 - x1))
        else
            local halfThumb = thumb:getHeight() / 2
            y1, y2 = y1 + halfThumb, y2 - halfThumb
            self.value = 1 - clamp((event.y - y1) / (y2 - y1))
        end
        thumb:focus()
    end

    self:onPressStart(press)
    self:onPressDrag(press)

    self:onEnter(function (event)
        thumb.hovered = true
    end)

    self:onLeave(function (event)
        thumb.hovered = false
    end)

    self:onChange(function (event)
        self:reshape()
    end)

    self:onReshape(function (event)
        local x1, y1, w, h = self:getRectangle(true, true)
        local x2, y2 = x1 + w, y1 + h
        if self.flow == 'x' then
            local halfThumb = thumb:getWidth() / 2
            x1, x2 = x1 + halfThumb, x2 - halfThumb
            spacer.width = self.value * (x2 - x1)
            spacer.height = false
        else
            local halfThumb = thumb:getHeight() / 2
            y1, y2 = y1 + halfThumb, y2 - halfThumb
            spacer.width = false
            spacer.height = (1 - self.value) * (y2 - y1)
        end
    end)
end
