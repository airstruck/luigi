local RESOURCE = (...):gsub('%.', '/') .. '/'

return function (config)
    config = config or {}

    local backColor = config.backColor or { 40, 40, 40 }
    local lineColor = config.lineColor or { 60, 60, 60 }
    local textColor = config.textColor or { 240, 240, 240 }
    local highlight = config.highlight or { 0xFF, 0x66, 0x00 }

    return {
        button = {
            align = 'center middle',
            padding = 6,
            slices = RESOURCE .. 'button.png',
            minwidth = 24,
            minheight = 24,
            canFocus = true,
            color = textColor,
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
            color = { 0, 0, 0 },
            color = textColor,
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
            color = textColor,
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
            color = textColor,
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
            color = textColor,
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
            color = textColor,
        },
        text_focused = {
            slices = RESOURCE .. 'text_focused.png',
        },
        check = {
            canFocus = true,
            color = textColor,
        },
        ['check.unchecked'] = {
            icon = RESOURCE .. 'check_unchecked.png',
        },
        ['check.checked'] = {
            icon = RESOURCE .. 'check_checked.png',
        },
        ['check.unchecked_pressed'] = {
            icon = RESOURCE .. 'check_unchecked_pressed.png',
        },
        ['check.checked_pressed'] = {
            icon = RESOURCE .. 'check_checked_pressed.png',
        },
        ['check.unchecked_focused'] = {
            icon = RESOURCE .. 'check_unchecked_focused.png',
        },
        ['check.checked_focused'] = {
            icon = RESOURCE .. 'check_checked_focused.png',
        },
        radio = {
            canFocus = true,
            color = textColor,
        },
        ['radio.unchecked'] = {
            icon = RESOURCE .. 'radio_unchecked.png',
        },
        ['radio.checked'] = {
            icon = RESOURCE .. 'radio_checked.png',
        },
        ['radio.unchecked_pressed'] = {
            icon = RESOURCE .. 'radio_unchecked_pressed.png',
        },
        ['radio.checked_pressed'] = {
            icon = RESOURCE .. 'radio_checked_pressed.png',
        },
        ['radio.unchecked_focused'] = {
            icon = RESOURCE .. 'radio_unchecked_focused.png',
        },
        ['radio.checked_focused'] = {
            icon = RESOURCE .. 'radio_checked_focused.png',
        },
    }

end
