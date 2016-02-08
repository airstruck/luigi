local ROOT = (...):gsub('[^.]*.[^.]*$', '')

local Base = require(ROOT .. 'base')
local Hooker = require(ROOT .. 'hooker')

local Backend = {}

Backend.isMac = function ()
    return love.system.getOS() == 'OS X'
end

Backend.run = function () end

Backend.Cursor = love.mouse.newCursor

Backend.Font = require(ROOT .. 'backend.love.font')

Backend.Text = require(ROOT .. 'backend.love.text')

Backend.Image = love.graphics.newImage

Backend.Quad = love.graphics.newQuad

Backend.SpriteBatch = love.graphics.newSpriteBatch

-- love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
Backend.draw = function (drawable, ...)
    if drawable.typeOf and drawable:typeOf 'Drawable' then
        return love.graphics.draw(drawable, ...)
    end
    return drawable:draw(...)
end

Backend.drawRectangle = love.graphics.rectangle

Backend.print = love.graphics.print

Backend.getClipboardText = love.system.getClipboardText

Backend.setClipboardText = love.system.setClipboardText

Backend.getMousePosition = love.mouse.getPosition

Backend.setMousePosition = love.mouse.setPosition

Backend.getSystemCursor = love.mouse.getSystemCursor

Backend.getWindowSize = function ()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

Backend.getTime = love.timer.getTime

Backend.isKeyDown = love.keyboard.isDown

Backend.isMouseDown = love.mouse.isDown

Backend.pop = love.graphics.pop

local push = love.graphics.push

Backend.push = function ()
     return push 'all'
end

Backend.quit = love.event.quit

Backend.setColor = love.graphics.setColor

Backend.setCursor = love.mouse.setCursor

Backend.setFont = function (font)
    return love.graphics.setFont(font.loveFont)
end

Backend.setScissor = love.graphics.setScissor

Backend.getScissor = love.graphics.getScissor

Backend.intersectScissor = love.graphics.intersectScissor

function Backend.hide (layout)
    for _, item in ipairs(layout.hooks) do
        Hooker.unhook(item)
    end
    layout.hooks = {}
end

local function hook (layout, key, method, hookLast)
    layout.hooks[#layout.hooks + 1] = Hooker.hook(love, key, method, hookLast)
end

local getMouseButtonId, isMouseDown

if love._version_minor < 10 then
    getMouseButtonId = function (value)
        return value == 'l' and 'left'
            or value == 'r' and 'right'
            or value == 'm' and 'middle'
            or value == 'x1' and 4
            or value == 'x2' and 5
            or value
    end
    isMouseDown = function ()
        return love.mouse.isDown('l', 'r', 'm')
    end
else
    getMouseButtonId = function (value)
        return value == 1 and 'left'
            or value == 2 and 'right'
            or value == 3 and 'middle'
            or value
    end
    isMouseDown = function ()
        return love.mouse.isDown(1, 2, 3)
    end
end

function Backend.show (layout)

    local input = layout.input

    hook(layout, 'draw', function ()
        input:handleDisplay(layout)
    end, true)
    hook(layout, 'resize', function (width, height)
        return input:handleReshape(layout, width, height)
    end)
    hook(layout, 'mousepressed', function (x, y, button)
        if button == 'wu' or button == 'wd' then
            return input:handleWheelMove(layout, 0, button == 'wu' and 1 or -1)
        end
        return input:handlePressStart(layout, getMouseButtonId(button), x, y)
    end)
    hook(layout, 'mousereleased', function (x, y, button)
        return input:handlePressEnd(layout, getMouseButtonId(button), x, y)
    end)
    hook(layout, 'mousemoved', function (x, y, dx, dy)
        if isMouseDown() then
            return input:handlePressedMove(layout, x, y)
        else
            return input:handleMove(layout, x, y)
        end
    end)
    hook(layout, 'keypressed', function (key, isRepeat)
        if key == ' ' then key = 'space' end
        return input:handleKeyPress(layout, key, Backend.getMousePosition())
    end)
    hook(layout, 'keyreleased', function (key)
        if key == ' ' then key = 'space' end
        return input:handleKeyRelease(layout, key, Backend.getMousePosition())
    end)
    hook(layout, 'textinput', function (text)
        return input:handleTextInput(layout, text, Backend.getMousePosition())
    end)
    if love._version_minor > 9 then
        hook(layout, 'wheelmoved', function (x, y)
            return input:handleWheelMove(layout, x, y)
        end)
    end
end

return Backend
