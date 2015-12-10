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
        return self.parent and self.parent.flow ~= 'x' and 4
    end

    local function getSashWidth (self)
        return self.parent and self.parent.flow == 'x' and 4
    end

    local function getStepperBeforeIcon (self)
        return self.parent.flow == 'x' and resources .. 'triangle_left.png'
            or resources .. 'triangle_up.png'
    end

    local function getStepperAfterIcon (self)
        return self.parent.flow == 'x' and resources .. 'triangle_right.png'
            or resources .. 'triangle_down.png'
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
            minheight = 36,
            minwidth = 36,
            align = 'center middle',
            margin = 2,
            color = textColor,
        },
        button = {
            type = 'control',
            padding = 6,
            slices = getButtonSlices,
            focusable = true,
        },
        check = {
            type = 'control',
            focusable = true,
            icon = getCheckOrRadioIcon,
            margin = 0,
            padding = 4,
            align = 'left middle',
            minheight = 24,
        },
        label = {
            type = 'control',
            align = 'left bottom',
            margin = 0,
            padding = 4,
            minheight = 24,
            height = 24,
        },
        menu = {
            flow = 'x',
            height = 24,
            background = backColor,
            color = textColor,
        },
        ['menu.expander'] = {
            icon = resources .. 'triangle_right.png',
        },
        ['menu.item'] = {
            padding = 4,
            align = 'left middle',
            background = getMenuItemBackground,
        },
        panel = {
            padding = 2,
            background = backColor,
            color = textColor,
        },
        progress = {
            type = 'control',
            slices = resources .. 'button_pressed.png',
        },
        ['progress.bar'] = {
            slices = resources .. 'progress.png',
            minwidth = 12,
            minheight= 22,
        },
        radio = {
            type = 'control',
            focusable = true,
            color = textColor,
            icon = getCheckOrRadioIcon,
            margin = 0,
            padding = 4,
            align = 'left middle',
            minheight = 24,
        },
        sash = {
            background = getSashBackground,
            height = getSashHeight,
            width = getSashWidth,
        },
        slider = {
            type = 'control',
            slices = resources .. 'button_pressed.png',
        },
        ['slider.thumb'] = {
            type = 'button',
            align = 'middle center',
            margin = 0,
            minwidth = 32,
            minheight = 32,
        },
        status = {
            background = backColor,
            color = textColor,
            align = 'left middle',
            padding = 4,
            height = 22,
        },
        stepper = {
            type = 'control',
            slices = resources .. 'button_pressed.png',
        },
        ['stepper.after'] = {
            type = 'button',
            icon = getStepperAfterIcon,
            margin = 0,
            minwidth = 32,
            minheight = 32,
        },
        ['stepper.before'] = {
            type = 'button',
            icon = getStepperBeforeIcon,
            margin = 0,
            minwidth = 32,
            minheight = 32,
        },
        ['stepper.item'] = {
            align = 'center middle',
            color = textColor,
        },
        ['stepper.view'] = {
            margin = 4,
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
