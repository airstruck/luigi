local RESOURCE = (...):gsub('%.', '/') .. '/'

return function (config)
    config = config or {}

    local backColor = config.backColor or { 240, 240, 240 }
    local lineColor = config.lineColor or { 220, 220, 220 }
    local highlight = config.highlight or { 0x19, 0xAE, 0xFF }

    return {
        button = {
            align = 'center middle',
            padding = 6,
            slices = RESOURCE .. 'button.png',
            minwidth = 24,
            minheight = 24,
            canFocus = true
        },
        button_hovered = {
            slices = RESOURCE .. 'button_hovered.png'
        },
        button_focused = {
            slices = RESOURCE .. 'button_focused.png',
        },
        button_pressed = {
            slices = RESOURCE .. 'button_pressed.png',
        },

        ['stepper.left'] = {
            type = 'button',
            icon = RESOURCE .. 'triangle_left.png',
        },

        ['stepper.right'] = {
            type = 'button',
            icon = RESOURCE .. 'triangle_right.png',
        },
        menu = {
            height = 24,
        },
        ['menu.item'] = {
            padding = 4,
            align = 'left middle',
            textColor = { 0, 0, 0 }
        },
        ['menu.item_active'] = {
            background = highlight,
        },
        ['menu.expander'] = {
            icon = RESOURCE .. 'triangle_right.png',
        },
        submenu = {
            padding = 10,
            margin = -10,
            slices = RESOURCE .. 'submenu.png',
        },
        sash = {
            background = lineColor
        },
        sash_hovered = {
            background = highlight
        },
        slider = {
            slices = RESOURCE .. 'button_pressed.png',
            padding = 0,
            minwidth = 24,
            minheight = 24
        },
        panel = {
            background = backColor,
        },
        progress = {
            slices = RESOURCE .. 'button_pressed.png',
            padding = 0,
            minwidth = 24,
            minheight = 24
        },
        ['progress.bar'] = {
            slices = RESOURCE .. 'progress.png',
            padding = 0,
            minwidth = 12,
        },
        slider_hovered = {
        },
        stepper = {
            slices = RESOURCE .. 'button_pressed.png',
        },
        ['stepper.item'] = {
            align = 'center middle',
        },
        text = {
            align = 'left middle',
            slices = RESOURCE .. 'text.png',
            padding = 6,
            minwidth = 24,
            minheight = 24,
            canFocus = true,
            cursor = 'ibeam',
            highlight = highlight,
        },
        text_focused = {
            slices = RESOURCE .. 'text_focused.png',
        },
    }

end
