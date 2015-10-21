local backColor = { 240, 240, 240 }
local lineColor = { 220, 220, 220 }
local highlightColor = { 220, 220, 240 }

return {
    panel = {
        background = backColor,
        padding = 4,
    },
    button = {
        type = 'panel',
        align = 'center middle',
        outline = lineColor,
        bend = 0.1,
        margin = 4,
    },
    button_hovered = {
        bend = 0.2,
    },
    button_pressed = {
        bend = -0.1,
    },
    text = {
        align = 'left middle',
        background = { 255, 255, 255 },
        outline = lineColor,
        bend = -0.1,
        margin = 4,
        padding = 4,
    },
    sash = {
        background = highlightColor
    },
    slider = {
        type = 'panel',
        outline = lineColor,
        bend = 0.1,
    },
}
