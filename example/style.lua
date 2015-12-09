return {
    short = {
        height = 48,
    },
    toolbar = {
        style = 'short',
    },
    toolButton = {
        type = 'button',
        align = 'center middle',
        width = 48,
        height = 48,
        slices = function (self)
            if self.focused or self.hovered or self.pressed then
                return nil -- fall back to theme default
            end
            return false -- no slices
        end
    },
    statusbar = {
        align = 'left middle',
    },
    listThing = {
        style = 'short',
        align = 'left middle',
        outline = { 200, 200, 200 },
        height = 120,
        padding = 8,
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
        height = 22,
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
        padding = 4,
    },
    dialogButton = {
        type = 'button',
        width = 100,
    }
}
