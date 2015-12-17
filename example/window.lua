local Layout = require 'luigi.layout'
local Backend = require 'luigi.backend'

local window = Layout {
    type = 'window',
    icon = 'logo.png',
    title = 'Test window',
    width = 300,
    height = 200,
    minwidth = 200,
    minheight = 100,
    maxwidth = 640,
    maxheight = 480,
    { type = 'button', id = 'maximize', text = 'Maximize' },
    { type = 'button', id = 'minimize', text = 'Minimize' },
    { type = 'button', id = 'restore', text = 'Restore' },
}

window.maximize:onPress(function ()
    window.root.maximized = true
end)
window.minimize:onPress(function ()
    window.root.minimized = true
end)
window.restore:onPress(function ()
    window.root.maximized = false
end)

window:show()

Backend.run()
