return {
    short = {
        height = 48,
    },
    toolbar = {
        style = { 'short' },
    },
    toolButton = {
        align = 'center middle',
        width = 48,
    },
    toolButton_focused = {
        slices = 'defer',
    },
    toolButton_not_hovered = {
        slices = false,
    },
    statusbar = {
        style = 'panel',
        align = 'left middle',
    },
    listThing = {
        style = { 'short', 'panel' },
        align = 'left middle',
        outline = { 200, 200, 200 },
        height = 120,
        padding = 8,
        background = { 255, 255, 255 },
        icon = 'icon/32px/Box.png',
        wrap = true,
    },
    dialog = {
        type = 'submenu',
        width = 600,
        height = 400,
        float = true,
    },
    dialogHead = {
        type = 'panel',
        height = 40,
        size = 16,
        align = 'middle center',
    },
    dialogBody = {
        wrap = true,
        margin = 4,
        font = 'font/DejaVuSansMono.ttf',
    },
    dialogFoot = {
        type = 'panel',
        flow = 'x',
        height = 40,
    },
    dialogButton = {
        type = 'button',
        width = 100,
        margin = 4,
    }
}
