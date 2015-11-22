local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')

return Backend.Font
