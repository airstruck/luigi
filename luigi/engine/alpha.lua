local RESOURCE = (...):gsub('%.', '/') .. '/'

return function (config)
    config = config or {}
    local resources = assert(config.resources, 'missing config.resources')
    local backColor = config.backColor or { 240, 240, 240 }
    local lineColor = config.lineColor or { 220, 220, 220 }
    local textColor = config.textColor or { 0, 0, 0 }
    local highlight = config.highlight or { 0x19, 0xAE, 0xFF }

    local button_pressed = resources .. 'button_pressed.png'
    local button_focused = resources .. 'button_focused.png'
    local button_hovered = resources .. 'button_hovered.png'
    local button = resources .. 'button.png'

    local check_checked_pressed = resources .. 'check_checked_pressed.png'
    local check_unchecked_pressed = resources .. 'check_unchecked_pressed.png'
    local check_checked_focused = resources .. 'check_checked_focused.png'
    local check_unchecked_focused = resources .. 'check_unchecked_focused.png'
    local check_checked = resources .. 'check_checked.png'
    local check_unchecked = resources .. 'check_unchecked.png'

    local radio_checked_pressed = resources .. 'radio_checked_pressed.png'
    local radio_unchecked_pressed = resources .. 'radio_unchecked_pressed.png'
    local radio_checked_focused = resources .. 'radio_checked_focused.png'
    local radio_unchecked_focused = resources .. 'radio_unchecked_focused.png'
    local radio_checked = resources .. 'radio_checked.png'
    local radio_unchecked = resources .. 'radio_unchecked.png'

    local triangle_left = resources .. 'triangle_left.png'
    local triangle_up = resources .. 'triangle_up.png'
    local triangle_right = resources .. 'triangle_right.png'
    local triangle_down = resources .. 'triangle_down.png'

    local text_focused = resources .. 'text_focused.png'
    local text = resources .. 'text.png'

    local function getButtonSlices (self)
        return self.pressed.left and button_pressed
            or self.focused and button_focused
            or self.hovered and button_hovered
            or button
    end

    local function getCheckIcon (self)
        if self.pressed.left then
            return self.value and check_checked_pressed
                or check_unchecked_pressed
        end
        if self.focused then
            return self.value and check_checked_focused
                or check_unchecked_focused
        end
        return self.value and check_checked or check_unchecked
    end

    local function getControlHeight (self)
        return self.flow == 'x' and self._defaultDimension
    end

    local function getControlWidth (self)
        return self.flow ~= 'x' and self._defaultDimension
    end

    local function getMenuItemBackground (self)
        return self.active and highlight
    end

    local function getRadioIcon (self)
        if self.pressed.left then
            return self.value and radio_checked_pressed
                or radio_unchecked_pressed
        end
        if self.focused then
            return self.value and radio_checked_focused
                or radio_unchecked_focused
        end
        return self.value and radio_checked or radio_unchecked
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

    local function getSliderThumbWidth (self)
        return self.parent.flow == 'x' and 32 or false
    end

    local function getSliderThumbHeight (self)
        return self.parent.flow ~= 'x' and 32 or false
    end

    local function getStepperBeforeIcon (self)
        return self.parent.flow == 'x' and triangle_left or triangle_up
    end

    local function getStepperAfterIcon (self)
        return self.parent.flow == 'x' and triangle_right or triangle_down
    end

    local function getTextSlices (self)
        return self.focused and text_focused or text
    end

    return {

        -- generic types for widgets to inherit

        Control = {
            flow = 'x',
            height = getControlHeight,
            width = getControlWidth,
            color = textColor,
            align = 'center middle',
            margin = 2,
            color = textColor,
            solid = true,
            _defaultDimension = 36,
        },

        Line = {
            margin = 0,
            padding = 4,
            align = 'left middle',
            _defaultDimension = 24,
        },

        -- widget types

        button = {
            type = { 'Control' },
            padding = 6,
            slices = getButtonSlices,
            focusable = true,
        },
        check = {
            type = { 'Line', 'Control' },
            focusable = true,
            icon = getCheckIcon,
        },
        label = {
            type = { 'Line', 'Control' },
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
            height = 24,
            align = 'left middle',
            background = getMenuItemBackground,
        },
        panel = {
            padding = 2,
            background = backColor,
            color = textColor,
            solid = true,
        },
        progress = {
            type = { 'Control' },
            slices = resources .. 'button_pressed.png',
        },
        ['progress.bar'] = {
            slices = resources .. 'progress.png',
            minwidth = 12,
            minheight = 22,
        },
        radio = {
            type = { 'Line', 'Control' },
            focusable = true,
            icon = getRadioIcon,
        },
        sash = {
            background = getSashBackground,
            height = getSashHeight,
            width = getSashWidth,
        },
        slider = {
            type = { 'Control' },
            slices = resources .. 'button_pressed.png',
        },
        ['slider.thumb'] = {
            type = { 'button' },
            align = 'middle center',
            margin = 0,
            width = getSliderThumbWidth,
            height = getSliderThumbHeight,
        },
        status = {
            type = { 'Line', 'Control' },
            background = backColor,
            color = textColor,
        },
        stepper = {
            type = { 'Control' },
            slices = resources .. 'button_pressed.png',
        },
        ['stepper.after'] = {
            type = { 'button' },
            icon = getStepperAfterIcon,
            margin = 0,
            minwidth = 32,
            minheight = 32,
        },
        ['stepper.before'] = {
            type = { 'button' },
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
            solid = true,
        },
        text = {
            type = { 'Control' },
            align = 'left middle',
            slices = getTextSlices,
            padding = 6,
            focusable = true,
            cursor = 'ibeam',
            highlight = highlight,
        },
    }

end
