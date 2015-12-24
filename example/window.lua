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
    left = 400,
    top = 400,
    { type = 'panel',
        {
            text = 'This is an example of the "window" widget type.',
            align = 'middle center', wrap = true,
        },
        { flow = 'x', height = 'auto',
            { type = 'button', id = 'maximize', text = 'Maximize' },
            { type = 'button', id = 'minimize', text = 'Minimize' },
            { type = 'button', id = 'restore', text = 'Restore' },
        },
        { flow = 'x', height = 'auto',
            {
                { type = 'label', text = 'Left' },
                { type = 'text', id = 'left' },
            },
            {
                { type = 'label', text = 'Top' },
                { type = 'text', id = 'top' },
            },
            {
                { type = 'label', text = 'Width' },
                { type = 'text', id = 'width' },
            },
            {
                { type = 'label', text = 'Height' },
                { type = 'text', id = 'height' },
            },
        },
    }
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
window:onReshape(function (event)
    -- local w, h = Backend:getWindowSize()
    -- use widget.attributes to do a raw update, avoid firing onChange
    window.width.attributes.value = tostring(event.width)
    window.height.attributes.value = tostring(event.height)
end)
window:onChange(function (event)
    local target = event.target
    if target.type ~= 'text' then return end
    local id = target.id
    if id and window.root.attributeDescriptors[id] then
        window.root[id] = tonumber(event.value)
    end
end)

window:show()

Backend.run()
