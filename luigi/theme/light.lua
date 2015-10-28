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
            slices = RESOURCE .. 'button_pressed.png',
            padding = 0,
        },
        progress = {
            slices = RESOURCE .. 'button_pressed.png',
            padding = 0,
        },
        progressInner = {
            slices = RESOURCE .. 'progress.png',
            padding = 0,
            minimumWidth = 12,
        },
        slider_hovered = {
        },
        stepper = {
        },
    }

end
