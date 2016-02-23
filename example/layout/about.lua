return { style = 'dialog',
    { style = 'dialogHead', text = 'About LUIGI' },
    { style = 'dialogBody', padding = 24, icon = 'logo.png', align = 'middle right',
        textOffset = { -250, 0 },
        text = [[
Lovely User Interfaces for Game Inventors

Copyright (c) 2015 airstruck
]]
    },
    { style = 'dialogFoot',
        {}, -- spacer
        { style = 'dialogButton', id = 'closeButton', text = 'Close' }
    }
}
