local RESOURCE = (...):gsub('%.', '/') .. '/'

return function (config)
    config = config or {}
    local resources = config.resources or RESOURCE
    local backColor = config.backColor or { 240, 240, 240 }
    local lineColor = config.lineColor or { 220, 220, 220 }
    local textColor = config.textColor or { 0, 0, 0 }
    local highlight = config.highlight or { 0x19, 0xAE, 0xFF }

    local function getButtonSlices (self)
        return self.pressed and resources .. 'button_pressed.png'
            or self.focused and resources .. 'button_focused.png'
            or self.hovered and resources .. 'button_hovered.png'
            or resources .. 'button.png'
    end

    local function getCheckOrRadioIcon (self)
        local prefix = resources .. self.type
        if self.pressed then
            if self.value then
                return prefix .. '_checked_pressed.png'
            else
                return prefix .. '_unchecked_pressed.png'
            end
        elseif self.focused then
            if self.value then
                return prefix .. '_checked_focused.png'
            else
                return prefix .. '_unchecked_focused.png'
            end
        else
            if self.value then
                return prefix .. '_checked.png'
            else
                return prefix .. '_unchecked.png'
            end
        end
    end

    local function getMenuItemBackground (self)
        return self.active and highlight
    end

    local function getSashBackground (self)
        return self.hovered and highlight or lineColor
    end

    local function getTextSlices (self)
        return self.focused and resources .. 'text_focused.png'
            or resources .. 'text.png'
    end

    return {
        button = {
            align = 'center middle',
            padding = 6,
            slices = getButtonSlices,
            minwidth = 24,
            minheight = 24,
            focusable = true,
            color = textColor,
        },

        ['stepper.left'] = {
            type = 'button',
            icon = resources .. 'triangle_left.png',
        },

        ['stepper.right'] = {
            type = 'button',
            icon = resources .. 'triangle_right.png',
        },
        menu = {
            height = 24,
        },
        ['menu.item'] = {
            padding = 4,
            align = 'left middle',
            color = textColor,
            background = getMenuItemBackground,
        },
        ['menu.expander'] = {
            icon = resources .. 'triangle_right.png',
        },
        submenu = {
            padding = 10,
            margin = -10,
            slices = resources .. 'submenu.png',
            color = textColor,
        },
        sash = {
            background = getSashBackground
        },
        slider = {
            slices = resources .. 'button_pressed.png',
            padding = 0,
            minwidth = 24,
            minheight = 24
        },
        panel = {
            background = backColor,
            color = textColor,
        },
        progress = {
            slices = resources .. 'button_pressed.png',
            padding = 0,
            minwidth = 24,
            minheight = 24
        },
        ['progress.bar'] = {
            slices = resources .. 'progress.png',
            padding = 0,
            minwidth = 12,
        },
        stepper = {
            slices = resources .. 'button_pressed.png',
        },
        ['stepper.item'] = {
            align = 'center middle',
            color = textColor,
        },
        status = {
            type = 'panel',
        },
        text = {
            align = 'left middle',
            slices = getTextSlices,
            padding = 6,
            minwidth = 24,
            minheight = 24,
            focusable = true,
            cursor = 'ibeam',
            highlight = highlight,
            color = textColor,
        },
        check = {
            focusable = true,
            color = textColor,
            icon = getCheckOrRadioIcon
        },
        radio = {
            focusable = true,
            color = textColor,
            icon = getCheckOrRadioIcon
        },
    }

end
