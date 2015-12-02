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
    layout.statusbar.text = (tostring(w.type)) ..
        (w.id or '(unnamed)') .. ' ' ..
        w:getX() .. ', ' .. w:getY() .. ' | ' ..
        w:getWidth() .. 'x' .. w:getHeight()
end)

layout.newButton:onMove(function (event)
    layout.statusbar.text = 'Create a new thing'
    return false
end)

local foo = Layout { float = true, height = 100,
    text = 'hello', align = 'center middle', background = {255,0,0}
}

foo:onReshape(function (event)
    foo:hide()
end)

layout.newButton:onPress(function (event)
    print('creating a new thing!')
end)

layout.aButton:onPress(function (event)
    layout.aButton.font = nil
    layout.aButton.width = layout.aButton.width + 10
    local w = layout.aButton:getWidth()
    foo.root.width = w * 2
    foo.root.left = layout.aButton:getX() - w
    foo.root.top = layout.aButton:getY() - foo.root.height
    foo:show()
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

local Backend = require 'luigi.backend'

layout.menuQuit:onPress(function (event) Backend.quit() end)

layout.themeLight:onPress(function (event) Backend.quit() end)

-- license dialog

local licenseDialog = Layout(require 'layout.license')

licenseDialog:setStyle(style)

licenseDialog.closeButton:onPress(function()
    licenseDialog:hide()
end)

layout.license:onPress(function()
    licenseDialog:show()
end)


-- show the main layout

layout:show()

Backend.run() -- only needed when using ffisdl backend
