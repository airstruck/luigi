local Widget = require((...):gsub('%.[^.]*$', ''))

local Slider = Widget:extend()

function Slider:constructor(layout, data)
    Widget.constructor(self, layout, data)

    local function getCenter()
        return self:getX() + self:getWidth() / 2
    end

    local position = 0.5

    self:onPressDrag(function(event)
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        position = (event.x - x1) / (x2 - x1)
        if position < 0 then position = 0 end
        if position > 1 then position = 1 end
        self:update()
    end)

    self:onDisplay(function(event)
        -- event:yield()
        local x1, y1, x2, y2 = self:getRectangle(true, true)
        local padding = self.padding or 0
        self.layout.window:fill(
            x1,
            y1 + (y2 - y1) / 2 - padding / 2,
            x2,
            y1 + (y2 - y1) / 2 + padding / 2,
            self.background, -(self.bend or 0)
        )
        self.layout.window:fill(
            x1 + position * (x2 - x1) - padding,
            y1 + padding,
            x1 + position * (x2 - x1) + padding,
            y2 - padding,
            self.background, self.bend
        )
        self.layout.window:outline(
            x1 + position * (x2 - x1) - padding,
            y1 + padding,
            x1 + position * (x2 - x1) + padding,
            y2 - padding,
            self.outline
        )
        return false
    end)

end

return Slider
