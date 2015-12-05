local Layout = require 'luigi.layout'

local style = require 'style'

local layout = Layout(require 'layout.main')

layout:setStyle(style)
-- layout:setTheme(require 'luigi.theme.light')

layout.leftSideBox:addChild {
    text = 'Alright man this is a great song\nwith a really long title...',
    style = 'listThing',
    align = 'middle right'
}

layout.slidey:onChange(function (event)
    layout.progressBar.value = event.value
end)

layout:onMove(function (event)
    local w = event.target
    layout.statusbar.text = (tostring(w.type)) .. ' ' ..
        (w.id or '(unnamed)') .. ' ' ..
        w:getX() .. ', ' .. w:getY() .. ' | ' ..
        w:getWidth() .. 'x' .. w:getHeight()
end)

layout.newButton:onMove(function (event)
    layout.statusbar.text = 'Create a new thing'
    return false
end)

layout.newButton:onPress(function (event)
    print('creating a new thing!')
end)

layout.mainCanvas.font = 'font/DejaVuSansMono.ttf'

layout.mainCanvas.text = [[
    Lorem ipsum dolor sit amet, consectetur adipisicing elit.

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
   Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

Excepteur sint         occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

One
two
Three
four

five
six
seven
eight
]]

layout.mainCanvas.align = 'top'

layout.mainCanvas.wrap = true

-- license dialog

local licenseDialog = Layout(require 'layout.license')

licenseDialog:setStyle(style)

licenseDialog.closeButton:onPress(function()
    licenseDialog:hide()
end)

layout.license:onPress(function()
    licenseDialog:show()
end)

-- about dialog

local aboutDialog = Layout(require 'layout.about')

aboutDialog:setStyle(style)

aboutDialog.closeButton:onPress(function()
    aboutDialog:hide()
end)

layout.about:onPress(function()
    aboutDialog:show()
end)

-- menu/view/theme

layout.themeLight:onPress(function (event)
    local light = require 'luigi.theme.light'
    layout:setTheme(light)
    licenseDialog:setTheme(light)
    aboutDialog:setTheme(light)
end)

layout.themeDark:onPress(function (event)
    local dark = require 'luigi.theme.dark'
    layout:setTheme(dark)
    licenseDialog:setTheme(dark)
    aboutDialog:setTheme(dark)
end)

-- menu/file/quit
-- uses Backend for compat with love or ffisdl
local Backend = require 'luigi.backend'
layout.menuQuit:onPress(function (event) Backend.quit() end)

-- show the main layout
layout:show()

-- only needed when using ffisdl backend
Backend.run()
