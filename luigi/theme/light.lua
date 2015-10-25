return function (config)
    config = config or {}

    local backColor = config.backColor or { 240, 240, 240 }
    local lineColor = config.lineColor or { 220, 220, 220 }
    local white = config.white or { 255, 255, 255 }
    local highlight = config.highlight or { 180, 180, 255 }

    return {
        panel = {
            background = backColor,
        },
        button = {
            type = 'panel',
            align = 'center middle',
            outline = lineColor,
            bend = 0.1,
            margin = 2,
        },
        button_hovered = {
            background = white,
            outline = highlight,
        },
        button_pressed = {
            background = highlight,
            outline = highlight,
        },
        text = {
            align = 'left middle',
            background = { 255, 255, 255 },
            outline = lineColor,
            margin = 2,
            padding = 2,
        },
        sash = {
            background = lineColor
        },
        sash_hovered = {
            background = highlight
        },
        slider = {
            type = 'panel',
            outline = lineColor,
            background = white,
        },
        stepper = {
            type = 'panel',
        },
        slider_hovered = {
            outline = highlight,
        },
    }

end
