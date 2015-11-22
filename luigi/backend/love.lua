local ROOT = (...):gsub('[^.]*.[^.]*$', '')

local Base = require(ROOT .. 'base')
local Hooker = require(ROOT .. 'hooker')

local Backend = {}

Backend.run = function () end

Backend.Cursor = love.mouse.newCursor

Backend.Font = require(ROOT .. 'backend.love.font')

Backend.Image = love.graphics.newImage

Backend.Quad = love.graphics.newQuad

Backend.SpriteBatch = love.graphics.newSpriteBatch

Backend.draw = love.graphics.draw

Backend.drawRectangle = love.graphics.rectangle

Backend.print = love.graphics.print

Backend.printf = love.graphics.printf

Backend.getClipboardText = love.system.getClipboardText

Backend.setClipboardText = love.system.setClipboardText

Backend.getMousePosition = love.mouse.getPosition

Backend.getMousePosition = love.mouse.getPosition

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
        return value == 'l' and 1
            or value == 'r' and 2
            or value == 'm' and 3
    end
    isMouseDown = function ()
        return love.mouse.isDown('l', 'r', 'm')
    end
else
    getMouseButtonId = function (value)
        return value
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
        return input:handleKeyPress(layout, key, Backend.getMousePosition())
    end)
    hook(layout, 'keyreleased', function (key)
        return input:handleKeyRelease(layout, key, Backend.getMousePosition())
    end)
    hook(layout, 'textinput', function (text)
        return input:handleTextInput(layout, text, Backend.getMousePosition())
    end)
end

return Backend
