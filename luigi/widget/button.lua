--[[--
A button.

Buttons have no special behavior beyond that of generic widgets,
but themes should give buttons an appropriate appearance.

@usage
-- create a layout containing only a button
local layout = Layout {
    type = 'button',
    id = 'exampleButton',
    text = 'Press me',
    width = 100,
    height = 32,
}

-- handle Press events
layout.exampleButton:onPress(function (event)
    print 'You pressed the button.'
end)

-- show the layout
layout:show()

@widget button
--]]--

return function (self)

end
