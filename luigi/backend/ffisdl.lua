local ROOT = (...):gsub('[^.]*.[^.]*$', '')

local Hooker = require(ROOT .. 'hooker')

local ffi = require 'ffi'
local sdl = require((...) .. '.sdl')
local Image = require((...) .. '.image')
local Font = require((...) .. '.font')
local Keyboard = require((...) .. '.keyboard')

local IntOut = ffi.typeof 'int[1]'

-- create window and renderer

local window = sdl.createWindow('', 0, 0, 800, 600,
    sdl.WINDOW_SHOWN)

if window == nil then
    io.stderr:write(ffi.string(sdl.getError()))
    sdl.quit()
    os.exit(1)
end

ffi.gc(window, sdl.destroyWindow)

local renderer = sdl.createRenderer(window, -1,
    sdl.RENDERER_ACCELERATED + sdl.RENDERER_PRESENTVSYNC)

if renderer == nil then
    io.stderr:write(ffi.string(sdl.getError()))
    sdl.quit()
    os.exit(1)
end

ffi.gc(renderer, sdl.destroyRenderer)

local Backend = {}

local callback = {
    draw = function () end,
    resize = function () end,
    mousepressed = function () end,
    mousereleased = function () end,
    mousemoved = function () end,
    keypressed = function () end,
    keyreleased = function () end,
    textinput = function () end,
}

Backend.run = function ()
    local event = sdl.Event()

    while true do
        sdl.pumpEvents()

        while sdl.pollEvent(event) ~= 0 do
            if event.type == sdl.QUIT then
                return
            elseif event.type == sdl.WINDOWEVENT
            and event.window.event == sdl.WINDOWEVENT_RESIZED then
                callback.resize(event.window.data1, event.window.data2)
            elseif event.type == sdl.MOUSEBUTTONDOWN then
                callback.mousepressed(event.button.x, event.button.y, event.button.button)
            elseif event.type == sdl.MOUSEBUTTONUP then
                callback.mousereleased(event.button.x, event.button.y, event.button.button)
            elseif event.type == sdl.MOUSEMOTION then
                callback.mousemoved(event.motion.x, event.motion.y)
            elseif event.type == sdl.KEYDOWN then
                local key = Keyboard.stringByKeycode[event.key.keysym.sym]
                callback.keypressed(key, event.key['repeat'])
            elseif event.type == sdl.KEYUP then
                local key = Keyboard.stringByKeycode[event.key.keysym.sym]
                callback.keyreleased(key, event.key['repeat'])
            elseif event.type == sdl.TEXTINPUT then
                callback.textinput(ffi.string(event.text.text))
            end
        end

        sdl.setRenderDrawColor(renderer, 0, 0, 0, 255)
        sdl.renderClear(renderer)
        callback.draw()
        sdl.renderPresent(renderer)
        sdl.delay(1)
    end
end

Backend.Cursor = function (image, x, y)
    return sdl.createColorCursor(image.sdlSurface, x, y)
end

Backend.Font = Font

Backend.Image = function (path)
    return Image(renderer, path)
end

Backend.Quad = function (x, y, w, h)
    return { x, y, w, h }
end

Backend.SpriteBatch = require((...) .. '.spritebatch')

Backend.draw = function (drawable, x, y, sx, sy)
    return drawable:draw(x, y, sx, sy)
end

Backend.drawRectangle = function (mode, x, y, w, h)
    if mode == 'fill' then
        sdl.renderFillRect(renderer, sdl.Rect(x, y, w, h))
    else
        sdl.renderDrawRect(renderer, sdl.Rect(x, y, w, h))
    end
end

local currentFont = Font()

-- print( text, x, y, r, sx, sy, ox, oy, kx, ky )
Backend.print = function (text, x, y)
    if not text or text == '' then return end
    local font = currentFont.sdlFont
    local color = sdl.Color(currentFont.color)
    local write = Font.SDL2_ttf.TTF_RenderUTF8_Blended

    local surface = write(font, text, color)
    ffi.gc(surface, sdl.freeSurface)
    local texture = sdl.createTextureFromSurface(renderer, surface)
    ffi.gc(texture, sdl.destroyTexture)
    sdl.renderCopy(renderer, texture, nil, sdl.Rect(x, y, surface.w, surface.h))
end

Backend.printf = Backend.print

Backend.getClipboardText = sdl.getClipboardText

Backend.setClipboardText = sdl.setClipboardText

Backend.getMousePosition = function ()
    local x, y = IntOut(), IntOut()
    sdl.getMouseState(x, y)
    return x[0], y[0]
end

local function SystemCursor (id)
    local cursor = sdl.createSystemCursor(id)
    ffi.gc(cursor, sdl.freeCursor)
    return cursor
end

local systemCursors = {
    arrow = SystemCursor(sdl.SYSTEM_CURSOR_ARROW),
    ibeam = SystemCursor(sdl.SYSTEM_CURSOR_IBEAM),
    wait = SystemCursor(sdl.SYSTEM_CURSOR_WAIT),
    crosshair = SystemCursor(sdl.SYSTEM_CURSOR_CROSSHAIR),
    waitarrow = SystemCursor(sdl.SYSTEM_CURSOR_WAITARROW),
    sizenwse = SystemCursor(sdl.SYSTEM_CURSOR_SIZENWSE),
    sizenesw = SystemCursor(sdl.SYSTEM_CURSOR_SIZENESW),
    sizewe = SystemCursor(sdl.SYSTEM_CURSOR_SIZEWE),
    sizens = SystemCursor(sdl.SYSTEM_CURSOR_SIZENS),
    sizeall = SystemCursor(sdl.SYSTEM_CURSOR_SIZEALL),
    no = SystemCursor(sdl.SYSTEM_CURSOR_NO),
    hand = SystemCursor(sdl.SYSTEM_CURSOR_HAND),
}

Backend.getSystemCursor = function (name)
    return systemCursors[name] or systemCursors.arrow
end

Backend.getWindowSize = function ()
    local x, y = IntOut(), IntOut()
    sdl.getWindowSize(window, x, y)
    return x[0], y[0]
end

Backend.getTime = function ()
    return sdl.getTicks() * 0.001
end

Backend.isKeyDown = function (...)
    local state = sdl.getKeyboardState(nil)

    for i = 1, select('#', ...) do
        local name = select(i, ...)
        local scan = Keyboard.scancodeByString[name]
        if scan and state[scan] ~= 0 then
            return true
        end
    end

    return false
end

Backend.isMouseDown = function ()
end

Backend.quit = function ()
    sdl.quit()
    os.exit()
end

local lastColor

Backend.setColor = function (color)
    lastColor = color
    sdl.setRenderDrawColor(renderer,
        color[1], color[2], color[3], color[4] or 255)
end

Backend.setCursor = function (cursor)
    sdl.setCursor(cursor or Backend.getSystemCursor('arrow'))
end

Backend.setFont = function (font)
    currentFont = font
end

local lastScissor

Backend.setScissor = function (x, y, w, h)
    lastScissor = x and sdl.Rect(x, y, w, h)
    sdl.renderSetClipRect(renderer, lastScissor)
end

function Backend.hide (layout)
    for _, item in ipairs(layout.hooks) do
        Hooker.unhook(item)
    end
    layout.hooks = {}
end

local function hook (layout, key, method, hookLast)
    layout.hooks[#layout.hooks + 1] = Hooker.hook(
        callback, key, method, hookLast)
end

local stack = {}

Backend.pop = function ()
    local history = stack[#stack]
    Backend.setColor(history.color or { 0, 0, 0, 255 })
    Backend.setScissor(history.scissor)
    stack[#stack] = nil
end

Backend.push = function ()
    stack[#stack + 1] = {
        color = lastColor,
        scissor = lastScissor,
    }
end

local isMouseDown = function ()
    return sdl.getMouseState(nil, nil) > 0
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
        return input:handlePressStart(layout, button, x, y)
    end)
    hook(layout, 'mousereleased', function (x, y, button)
        return input:handlePressEnd(layout, button, x, y)
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
