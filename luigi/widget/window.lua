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
--[[--
Special Attributes

@section special
--]]--

--[[--
Maximized.

@attrib maximized
--]]--
    local maximized
    
    self:defineAttribute('maximized', {
        set = function (_, value)
            if not value then return end
            maximized = value
            Backend.setWindowMaximized(maximized)
        end, 
        get = function () return maximized end
    })

--[[--
Minimized.

@attrib minimized
--]]--
    local minimized
    
    self:defineAttribute('minimized', {
        set = function (_, value)
            if not value then return end
            minimized = value
            Backend.setWindowMinimized(minimized)
        end, 
        get = function () return minimized end
    })

--[[--
Borderless.

@attrib borderless
--]]--
    local borderless
    
    self:defineAttribute('borderless', {
        set = function (_, value)
            if not value then return end
            borderless = value
            Backend.setWindowBorderless(borderless)
        end, 
        get = function () return borderless end
    })

--[[--
Fullscreen.

@attrib fullscreen
--]]--
    local fullscreen
    
    self:defineAttribute('fullscreen', {
        set = function (_, value)
            if not value then return end
            fullscreen = value
            Backend.setWindowFullscreen(fullscreen)
        end, 
        get = function () return fullscreen end
    })

--[[--
Grab mouse.

@attrib grab
--]]--
    local grab
    
    self:defineAttribute('grab', {
        set = function (_, value)
            if not value then return end
            grab = value
            Backend.setWindowGrab(grab)
        end, 
        get = function () return grab end
    })

--[[--
Icon.

@attrib icon
--]]--
    local icon
    
    self:defineAttribute('icon', {
        set = function (_, value)
            if not value then return end
            icon = value
            Backend.setWindowIcon(icon)
        end, 
        get = function () return icon end
    })

    self.attributes.icon = nil
--[[--
Maximum width.

@attrib maxwidth
--]]--
    local maxwidth

    self:defineAttribute('maxwidth', {
        set = function (_, value)
            if not value then return end
            maxwidth = value
            Backend.setWindowMaxwidth(maxwidth)
        end, 
        get = function () return maxwidth end
    })

--[[--
Maximum height.

@attrib maxheight
--]]--
    local maxheight

    self:defineAttribute('maxheight', {
        set = function (_, value)
            if not value then return end
            maxheight = value
            Backend.setWindowMaxheight(maxheight)
        end, 
        get = function () return maxheight end
    })

--[[--
Minimum width.

@attrib minwidth
--]]--
    local minwidth

    self:defineAttribute('minwidth', {
        set = function (_, value)
            if not value then return end
            minwidth = value
            Backend.setWindowMinwidth(minwidth)
        end, 
        get = function () return minwidth end
    })

--[[--
Minimum height.

@attrib minheight
--]]--
    local minheight

    self:defineAttribute('minheight', {
        set = function (_, value)
            if not value then return end
            minheight = value
            Backend.setWindowMinheight(minheight)
        end, 
        get = function () return minheight end
    })

--[[--
Top position.

@attrib top
--]]--
    local top

    self:defineAttribute('top', {
        set = function (_, value)
            if not value then return end
            top = value
            Backend.setWindowTop(top)
        end, 
        get = function () return top end
    })

--[[--
Left position.

@attrib left
--]]--
    local left

    self:defineAttribute('left', {
        set = function (_, value)
            if not value then return end
            left = value
            Backend.setWindowLeft(left)
        end, 
        get = function () return left end
    })

--[[--
Width.

@attrib width
--]]--
    local width

    self:defineAttribute('width', {
        set = function (_, value)
            if not value then return end
            width = value
            Backend.setWindowWidth(width)
        end, 
        get = function () return width end
    })

--[[--
Height.

@attrib height
--]]--
    local height

    self:defineAttribute('height', {
        set = function (_, value)
            if not value then return end
            height = value
            Backend.setWindowHeight(height)
        end, 
        get = function () return height end
    })

--[[--
Title.

@attrib title
--]]--
    local title

    self:defineAttribute('title', {
        set = function (_, value)
            if not value then return end
            title = value
            Backend.setWindowTitle(title)
        end, 
        get = function () return title end
    })

--[[--
@section end
--]]--
end
