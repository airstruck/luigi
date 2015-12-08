--[[--
A status bar.

This widget will display the @{attribute.status|status} attribute of the
hovered widget. Only one status widget should exist per layout. If multiple
status widgets exist in the same layout, only the last one created will
display status messages.

@usage
-- create a layout containing some buttons and a status bar
local layout = Layout {
    { type = 'panel', flow = 'x',
        { text = 'Do stuff', status = 'Press to do stuff' },
        { text = 'Quit', status = 'Press to quit' },
    },
    { type = 'status', height = 24 },
}

-- show the layout
layout:show()

@widget status
--]]--
return function (self)
    self.layout.statusWidget = self
end
