local Widget = require((...):gsub('%.[^.]*$', ''))

local Text = Widget:extend()

function Text:constructor(layout, data)
    Widget.constructor(self, layout, data)
end

return Text
