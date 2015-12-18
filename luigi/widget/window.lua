--[[--
Window widget.

Set properties of the window with this widget's attributes.
This widget should only be used as the root widget of a layout.

@usage
-- create a new window
local window = Layout {
    type = 'window',
    icon = 'logo.png',
    text = 'Window Example',
    width = 800,
    height = 600,
    { icon = 'logo.png', text = 'Window Example', align = 'middle center' },
    { type = 'panel', flow = 'x', height = 'auto',
        {}, -- spacer
        { type = 'button', id = 'quitButton', text = 'Quit' }
    }
}

-- handle quit button
window.quitButton:onPress(function ()
    os.exit()
end)

-- show the window
window:show()

@widget window
--]]--

local ROOT = (...):gsub('[^.]*.[^.]*$', '')

local Backend = require(ROOT .. 'backend')

return function (self)

    function self:calculateRootPosition (axis)
        self.position[axis] = 0
        return 0
    end

    function self.painter:paintIconAndText () end

--[[--
Special Attributes

@section special
--]]--

--[[--
Maximized. Set to `true` to make the window as large as possible.
Set to `false` to restore the size and position.

@attrib maximized
--]]--
    self:defineAttribute('maximized', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowMaximized(value)
            self.layout.root:reshape()
        end,
        get = Backend.getWindowMaximized
    })

--[[--
Minimized. Set to `true` to minimize the window to an iconic representation.
Set to `false` to restore the size and position.

@attrib minimized
--]]--
    self:defineAttribute('minimized', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowMinimized(value)
        end,
        get = Backend.getWindowMinimized
    })

--[[--
Borderless. Set to `true` or `false` to change the border state of the window.
You can't change the border state of a fullscreen window.

@attrib borderless
--]]--
    self:defineAttribute('borderless', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowBorderless(value)
            self.layout.root:reshape()
        end,
        get = Backend.getWindowBorderless
    })

--[[--
Fullscreen. Set to `true` or `false` to change the fullscreen state
of the window.

@attrib fullscreen
--]]--
    self:defineAttribute('fullscreen', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowFullscreen(value)
            self.layout.root:reshape()
        end,
        get = Backend.getWindowFullscreen
    })

--[[--
Mouse grab. Set to `true` or `false` to change the window's input grab mode.
When input is grabbed the mouse is confined to the window.

If the caller enables a grab while another window is currently grabbed,
the other window loses its grab in favor of the caller's window.

@attrib grab
--]]--
    self:defineAttribute('grab', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowGrab(value)
        end,
        get = Backend.getWindowGrab
    })

--[[--
Window icon. Should be a string containing a path to an image.

@attrib icon
--]]--
    local icon

    self:defineAttribute('icon', {
        set = function (_, value)
            if value == nil then return end
            icon = value
            Backend.setWindowIcon(value)
        end,
        get = function () return icon end
    })
--[[--
Maximum width of the window's client area.

@attrib maxwidth
--]]--
    self:defineAttribute('maxwidth', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowMaxwidth(value)
        end,
        get = Backend.getWindowMaxwidth
    })

--[[--
Maximum height of the window's client area.

@attrib maxheight
--]]--
    self:defineAttribute('maxheight', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowMaxheight(value)
        end,
        get = Backend.getWindowMaxheight
    })

--[[--
Minimum width of the window's client area.

@attrib minwidth
--]]--
    self:defineAttribute('minwidth', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowMinwidth(value)
        end,
        get = Backend.getWindowMinwidth
    })

--[[--
Minimum height of the window's client area.

@attrib minheight
--]]--
    self:defineAttribute('minheight', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowMinheight(value)
        end,
        get = Backend.getWindowMinheight
    })

--[[--
Position of the window's top edge.

@attrib top
--]]--
    self:defineAttribute('top', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowTop(value)
        end,
        get = Backend.getWindowTop
    })

--[[--
Position of the window's left edge.

@attrib left
--]]--
    self:defineAttribute('left', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowLeft(value)
        end,
        get = Backend.getWindowLeft
    })

--[[--
Width of the window's content area.

@attrib width
--]]--
    self:defineAttribute('width', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowWidth(value)
            self.layout.root:reshape()
        end,
        get = Backend.getWindowWidth
    })

--[[--
Height of the window's content area.

@attrib height
--]]--
    self:defineAttribute('height', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowHeight(value)
            self.layout.root:reshape()
        end,
        get = Backend.getWindowHeight
    })

--[[--
Title of the window.

@attrib title
--]]--
    self:defineAttribute('title', {
        set = function (_, value)
            if value == nil then return end
            Backend.setWindowTitle(value)
        end,
        get = Backend.getWindowTitle
    })

--[[--
@section end
--]]--
end
