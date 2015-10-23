local Layout = require 'luigi.layout'

local style = {
    mainWindow = {
        width = 600,
        height = 400,
    },
    short = {
        height = 36,
    },
    toolbar = {
        style = { 'short' },
    },
    toolButton = {
        align = 'center middle',
        width = 36,
        margin = 4,
    },
    toolButton_not_hovered = {
        background = false,
        outline =  { 200, 200, 200 },
    },
    statusbar = {
        style = 'panel',
        align = 'left middle',
    },
    listThing = {
        style = { 'short', 'panel' },
        align = 'left middle',
        outline = { 200, 200, 200 },
        height = 120,
        padding = 8,
        background = { 255, 255, 255 },
        icon = 'icon/emblem-system.png',
    },
}

local mainForm = { title = "Test window", id = 'mainWindow', type = 'panel',
    { type = 'panel', id = 'toolbar', flow = 'x',
        { type = 'button', id = 'newButton', style = 'toolButton',
            icon = 'icon/emblem-default.png' },
        { type = 'button', id = 'loadButton', style = 'toolButton',
            icon = 'icon/emblem-documents.png' },
        { type = 'button', id = 'saveButton', style = 'toolButton',
            icon = 'icon/emblem-downloads.png' },
    },
    { flow = 'x',
        { id = 'leftSideBox',    width = 200,
            { text = 'Hi, I\'m centered middle. ', style = 'listThing',
                align = 'middle center' },
            { text = 'Hi, I\'m centered bottom. ', style = 'listThing',
                align = 'bottom center' },
            { text = 'Hi, I\'m centered top. ', style = 'listThing',
                align = 'top center' },
            { text = 'A man, a plan, a canal: Panama!', style = 'listThing' },
        },
        { type = 'sash', width = 4, },
        { id = 'mainCanvas' },
        { type = 'sash', width = 4, },
        { type = 'panel', id = 'rightSideBox', width = 200,
            { type = 'panel', text = 'A slider', align = 'bottom', height = 24 },
            { type = 'slider', height = 48, },
        },
    },
    { type = 'sash', height = 4, },
    { type = 'panel', flow = 'x', height = 48,
        { type = 'text', id = 'aTextField', text = 'a text field',
            font = 'font/liberation/LiberationMono-Regular.ttf' },
        { type = 'button', width = 80, id = 'aButton', text = 'Styling!' },
    },
    { type = 'panel', height = 24, id = 'statusbar', textColor = { 255, 0, 0 } },
}

local layout = Layout(mainForm)

layout:setStyle(style)
layout:setTheme(require 'luigi.theme.light' { highlight = { 150, 255, 150 } })

layout.leftSideBox:addChild {
    text = 'Alright man this is a great song\nwith a really long title...',
    style = 'listThing',
    align = 'middle right'
}

--[[
local KEY_ESCAPE = 27

layout:onKeyboard(function(event)
    if event.key == KEY_ESCAPE then
        layout.window:destroy()
        os.exit(0)
    end
    if key == GLUT_KEY_F11 then
        glutFullScreen()
    end
    if key == GLUT_KEY_F12 then
        glutPositionWindow(-1, -1)
    end
end)
]]

layout:onMotion(function(event)
    local w = event.target
    layout.statusbar.text = (w.id or '(unnamed)') .. ' ' ..
        w:getX() .. ', ' .. w:getY() .. ' | ' ..
        w:getWidth() .. 'x' .. w:getHeight()
    layout.statusbar:update()
end)

layout.newButton:onMotion(function(event)
    layout.statusbar.text = 'Create a new thing'
    layout.statusbar:update()
    return false
end)

layout.newButton:onPress(function(event)
    print('creating a new thing!')
end)

layout.mainCanvas.text = [[Abedede sdfsdf asfdsdfdsfs sdfsdfsdf
sfsdfdfbv db er erg rth tryj ty j fgh dfgv
wefwef    rgh erh rth e rgs dvg eh tyj rt h erg
erge rg eg erg er ergs erg er ge rh erh rth]]

layout.mainCanvas.align = 'top'

layout:show()
