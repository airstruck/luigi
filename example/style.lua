return {
    toolbar = {
        type = 'panel',
        margin = 0,
        padding = 0,
        height = 'auto',
        flow = 'x',
    },
    toolButton = {
        type = 'button',
        align = 'center middle',
        width = 48,
        height = 48,
        slices = function (self)
            if self.focused or self.hovered or self.pressed.left then
                return nil -- fall back to theme default
            end
            return false -- no slices
        end
    },
    statusbar = {
        align = 'left middle',
    },
    listThing = {
        align = 'left middle',
        outline = { 128, 128, 128, 128 },
        background = { 128, 128, 128, 64 },
        height = 120,
        padding = 8,
        margin = 2,
        icon = 'icon/32px/Box.png',
        wrap = true,
    },
    -- dialog styles
    dialog = {
        type = 'submenu',
        width = 600,
        height = 400,
    },
    dialogHead = {
        align = 'middle center',
        height = 36,
        size = 16,
        type = 'panel',
    },
    dialogBody = {
        align = 'left middle',
        font = 'font/DejaVuSansMono.ttf',
        padding = 4,
        wrap = true,
    },
    dialogFoot = {
        flow = 'x',
        height = 'auto',
        type = 'panel',
    },
    dialogButton = {
        type = 'button',
        width = 100,
    }
}
