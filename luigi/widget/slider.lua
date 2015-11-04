return function (self)

    local function clamp (value)
        return value < 0 and 0 or value > 1 and 1 or value
    end

    self:setValue(clamp(self.value or 0.5))
    self.step = self.step or 0.01
    self.flow = 'x' -- TODO: support vertical slider

    local spacer = self:addChild()

    local thumb = self:addChild {
        type = 'button',
        align = 'middle center',
        width = 0,
        margin = 0,
    }

    local function unpress ()
        thumb.pressed = false -- don't make the thumb appear pushed in
        return false -- don't press thumb on focused keyboard activation
    end

    thumb:onPressStart(unpress)
    thumb:onPressEnter(unpress)

    thumb:onKeyPress(function (event)
        local key = event.key
        if key == 'left' or key == 'down' then
            self:setValue(clamp(self.value - self.step))
        elseif event.key == 'right' or key == 'up' then
            self:setValue(clamp(self.value + self.step))
        end
    end)

    local function press (event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local halfThumb = thumb:getWidth() / 2
        x1, x2 = x1 + halfThumb, x2 - halfThumb
        self:setValue(clamp((event.x - x1) / (x2 - x1)))
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
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local halfThumb = thumb:getWidth() / 2
        x1, x2 = x1 + halfThumb, x2 - halfThumb
        spacer.width = self.value * (x2 - x1)
    end)
end
