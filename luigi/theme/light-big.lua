local RESOURCE = (...):gsub('%.', '/') .. '/'
local ROOT = (...):gsub('[^.]*.[^.]*$', '')

return function (config)
    local theme = require(ROOT .. 'theme.light')()
    theme.Control._defaultDimension = 44
    theme.Line._defaultDimension = 32
    theme.menu.height = 32
    theme['menu.item'].height = 32
    theme['menu.item'].padding = 8
    theme.panel.padding = 8
    return theme
end
