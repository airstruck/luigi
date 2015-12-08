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

    local function getControlHeight (self)
        return self.flow == 'x' and 32
    end

    local function getControlWidth (self)
        return self.flow ~= 'x' and 32
    end

    local function getMenuItemBackground (self)
        return self.active and highlight
    end

    local function getSashBackground (self)
        return self.hovered and highlight or lineColor
    end

    local function getSashHeight (self)
        return self.parent.flow ~= 'x' and 4
    end

    local function getSashWidth (self)
        return self.parent.flow == 'x' and 4
    end

    local function getTextSlices (self)
        return self.focused and resources .. 'text_focused.png'
            or resources .. 'text.png'
    end

    return {
        control = {
            flow = 'x',
            height = getControlHeight,
            width = getControlWidth,
            color = textColor,
            minheight = 28,
            minwidth = 28,
        },
        button = {
            type = 'control',
            align = 'center middle',
            padding = 6,
            slices = getButtonSlices,
            minwidth = 24,
            minheight = 24,
            focusable = true,
            color = textColor,
        },
        check = {
            type = 'control',
            focusable = true,
            color = textColor,
            icon = getCheckOrRadioIcon,
            padding = 4,
        },
        label = {
            type = 'control',
            background = backColor,
            padding = 4,
        },
        menu = {
            height = 24,
        },
        ['menu.expander'] = {
            icon = resources .. 'triangle_right.png',
        },
        ['menu.item'] = {
            padding = 4,
            align = 'left middle',
            color = textColor,
            background = getMenuItemBackground,
        },
        panel = {
            background = backColor,
            color = textColor,
        },
        progress = {
            type = 'control',
            slices = resources .. 'button_pressed.png',
            padding = 0,
        },
        ['progress.bar'] = {
            type = 'control',
            slices = resources .. 'progress.png',
            padding = 0,
            minwidth = 12,
        },
        radio = {
            type = 'control',
            focusable = true,
            color = textColor,
            icon = getCheckOrRadioIcon,
            padding = 4,
        },
        sash = {
            background = getSashBackground,
            height = getSashHeight,
            width = getSashWidth,
        },
        slider = {
            type = 'control',
            slices = resources .. 'button_pressed.png',
            padding = 0,
        },
        status = {
            type = 'panel',
            align = 'left middle',
            padding = 4,
            height = 22,
        },
        stepper = {
            type = 'control',
            slices = resources .. 'button_pressed.png',
        },
        ['stepper.item'] = {
            type = 'control',
            align = 'center middle',
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
        submenu = {
            padding = 10,
            margin = -10,
            slices = resources .. 'submenu.png',
            color = textColor,
        },
        text = {
            type = 'control',
            align = 'left middle',
            slices = getTextSlices,
            padding = 6,
            focusable = true,
            cursor = 'ibeam',
            highlight = highlight,
        },
    }

end
