local RESOURCE = (...):gsub('%.', '/') .. '/'
local ROOT = (...):gsub('[^.]*.[^.]*$', '')

return function (config)
    config = config or {}
    config.resources = config.resources or RESOURCE
    config.backColor = config.backColor or { 240, 240, 240 }
    config.lineColor = config.lineColor or { 220, 220, 220 }
    config.textColor = config.textColor or { 0, 0, 0 }
    config.highlight = config.highlight or { 0x19, 0xAE, 0xFF }
    return require(ROOT .. 'engine.alpha')(config)
end
