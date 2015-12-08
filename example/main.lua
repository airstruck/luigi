local Layout = require 'luigi.layout'

local style = require 'style'

local layout = Layout(require 'layout.main')

layout:setStyle(style)

layout.slidey:onChange(function (event)
    layout.progressBar.value = event.value
end)

layout.flowToggle:onChange(function (event)
    layout.slidey.flow = event.value and 'y' or 'x'
    layout.progressBar.flow = event.value and 'y' or 'x'
    layout.stepper.flow = event.value and 'y' or 'x'
    layout.flowTest.flow = event.value and 'x' or 'y'
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

-- help dialogs

local aboutDialog = Layout(require 'layout.about')
local licenseDialog = Layout(require 'layout.license')

aboutDialog:setStyle(style)
licenseDialog:setStyle(style)

aboutDialog.closeButton:onPress(function()
    aboutDialog:hide()
end)

licenseDialog.closeButton:onPress(function()
    licenseDialog:hide()
end)

layout.license:onPress(function()
    aboutDialog:hide()
    licenseDialog:show()
end)

layout.about:onPress(function()
    licenseDialog:hide()
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
