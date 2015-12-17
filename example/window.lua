local Layout = require 'luigi.layout'

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
}

window:show()

require 'luigi.backend'.run()

