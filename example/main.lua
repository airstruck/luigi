local Layout = require 'luigi.layout'

local layout = Layout(require 'layout.main')
local aboutDialog = Layout(require 'layout.about')
local licenseDialog = Layout(require 'layout.license')

layout:setStyle(require 'style')
aboutDialog:setStyle(require 'style')
licenseDialog:setStyle(require 'style')

layout.slidey:onChange(function (event)
    layout.progressBar.value = event.value
end)

layout.flowToggle:onChange(function (event)
    layout.slidey.flow = event.value and 'y' or 'x'
    layout.progressBar.flow = event.value and 'y' or 'x'
    layout.stepper.flow = event.value and 'y' or 'x'
    local height = layout.flowTest:getHeight()
    layout.flowTest.flow = event.value and 'x' or 'y'
    layout.flowTest.height = height
end)

layout.newButton:onPress(function (event)
    print('creating a new thing!')
end)

layout.mainCanvas.text = [[
This program demonstrates some features of the Luigi UI library.

Luigi is a widget toolkit that runs under Love or LuaJIT.

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]


layout.mainCanvas.align = 'top'

layout.mainCanvas.wrap = true

layout.mainCanvas.scroll = true

-- help dialogs

layout.about:onPress(function()
    licenseDialog:hide()
    aboutDialog:show()
end)

layout.license:onPress(function()
    aboutDialog:hide()
    licenseDialog:show()
end)

aboutDialog.closeButton:onPress(function()
    aboutDialog:hide()
end)

licenseDialog.closeButton:onPress(function()
    licenseDialog:hide()
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
-- uses Backend for compat with Love or LuaJIT/SDL
local Backend = require 'luigi.backend'
layout.menuQuit:onPress(Backend.quit)

layout.mono:onPress(function()
    layout.leftSideBox.font = 'font/DejaVuSansMono.ttf'
end)

layout.sans:onPress(function()
    layout.leftSideBox.font = false
end)

layout.mono2:onPress(function()
    layout.stepper.font = 'font/DejaVuSansMono.ttf'
end)

layout.sans2:onPress(function()
    layout.stepper.font = false
end)

layout.fish:onChange(function()
    layout.fishStatus.text = 'Selected: ' .. layout.fish.selected.text
end)

-- show the main layout
layout:show()

-- only needed when using LuaJIT/SDL and not using launch.lua
-- Backend.run()
