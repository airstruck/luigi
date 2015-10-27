local RESOURCE = (...):gsub('%.', '/') .. '/'

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
            padding = 6,
            slices = RESOURCE .. 'button.png',
            minimumWidth = 24,
            minimumHeight = 24
        },
        button_hovered = {
        slices = RESOURCE .. 'button_hovered.png'
        },
        button_pressed = {
            slices = RESOURCE .. 'button_pressed.png',
        },
        text = {
            align = 'left middle',
            slices = RESOURCE .. 'text.png',
            padding = 6,
            minimumWidth = 24,
            minimumHeight = 24
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
