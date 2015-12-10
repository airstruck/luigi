local ROOT = (...):gsub('[^.]*.[^.]*$', '')

local Hooker = require(ROOT .. 'hooker')

local ffi = require 'ffi'
local sdl = require((...) .. '.sdl')

local Image = require((...) .. '.image')
local Font = require((...) .. '.font')
local Keyboard = require((...) .. '.keyboard')
local Text = require((...) .. '.text')

local IntOut = ffi.typeof 'int[1]'

local stack = {}

-- create window and renderer
sdl.setHint(sdl.HINT_VIDEO_ALLOW_SCREENSAVER, '1')

local window = sdl.createWindow('', 0, 0, 800, 600,
    sdl.WINDOW_SHOWN + sdl.WINDOW_RESIZABLE)

if window == nil then
    error(ffi.string(sdl.getError()))
end

ffi.gc(window, sdl.destroyWindow)

local renderer = sdl.createRenderer(window, -1,
    sdl.RENDERER_ACCELERATED + sdl.RENDERER_PRESENTVSYNC)

if renderer == nil then
    error(ffi.string(sdl.getError()))
end

ffi.gc(renderer, sdl.destroyRenderer)

sdl.setRenderDrawBlendMode(renderer, sdl.BLENDMODE_BLEND)

local Backend = {}

Backend.sdl = sdl

local callback = {
    draw = function () end,
    resize = function () end,
    mousepressed = function () end,
    mousereleased = function () end,
    mousemoved = function () end,
    keypressed = function () end,
    keyreleased = function () end,
    textinput = function () end,
    wheelmoved = function () end,
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
                local window = event.window
                callback.resize(window.data1, window.data2)
            elseif event.type == sdl.MOUSEBUTTONDOWN then
                local button = event.button
                callback.mousepressed(button.x, button.y, button.button)
            elseif event.type == sdl.MOUSEBUTTONUP then
                local button = event.button
                callback.mousereleased(button.x, button.y, button.button)
            elseif event.type == sdl.MOUSEMOTION then
                local motion = event.motion
                callback.mousemoved(motion.x, motion.y)
            elseif event.type == sdl.KEYDOWN then
                local key = Keyboard.stringByKeycode[event.key.keysym.sym]
                callback.keypressed(key, event.key['repeat'])
            elseif event.type == sdl.KEYUP then
                local key = Keyboard.stringByKeycode[event.key.keysym.sym]
                callback.keyreleased(key, event.key['repeat'])
            elseif event.type == sdl.TEXTINPUT then
                callback.textinput(ffi.string(event.text.text))
            elseif event.type == sdl.MOUSEWHEEL then
                local wheel = event.wheel
                callback.wheelmoved(wheel.x, wheel.y)
            end
        end

        sdl.renderSetClipRect(renderer, nil)
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

Backend.Text = function (...)
    return Text(renderer, ...)
end

Backend.Quad = function (x, y, w, h)
    return { x, y, w, h }
end

Backend.SpriteBatch = require((...) .. '.spritebatch')

Backend.draw = function (drawable, x, y, sx, sy)
    if drawable.draw then
        return drawable:draw(x, y, sx, sy)
    end

    if drawable.sdlTexture == nil
    or drawable.sdlRenderer == nil
    or drawable.getWidth == nil
    or drawable.getHeight == nil
        then return
    end

    local w = drawable:getWidth() * (sx or 1)
    local h = drawable:getHeight() * (sy or 1)

    -- HACK. Somehow drawing something first prevents renderCopy from
    -- incorrectly scaling up in some cases (after rendering slices).
    -- For example http://stackoverflow.com/questions/28218906
    sdl.renderDrawPoint(drawable.sdlRenderer, -1, -1)

    -- Draw the image.
    sdl.renderCopy(drawable.sdlRenderer, drawable.sdlTexture,
        nil, sdl.Rect(x, y, w, h))
end

Backend.drawRectangle = function (mode, x, y, w, h)
    if mode == 'fill' then
        sdl.renderFillRect(renderer, sdl.Rect(x, y, w, h))
    else
        sdl.renderDrawRect(renderer, sdl.Rect(x, y, w, h))
    end
end

local currentFont = Font()

local lastColor

-- print( text, x, y, r, sx, sy, ox, oy, kx, ky )
Backend.print = function (text, x, y)
    if not text or text == '' then return end
    local font = currentFont.sdlFont
    local color = sdl.Color(lastColor or { 0, 0, 0, 255 })
    local write = Font.SDL2_ttf.TTF_RenderUTF8_Blended

    local surface = write(font, text, color)
    ffi.gc(surface, sdl.freeSurface)
    local texture = sdl.createTextureFromSurface(renderer, surface)
    ffi.gc(texture, sdl.destroyTexture)
    sdl.renderCopy(renderer, texture, nil, sdl.Rect(x, y, surface.w, surface.h))
end

Backend.printf = Backend.print

Backend.getClipboardText = function ()
    return ffi.string(sdl.getClipboardText())
end

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

Backend.getScissor = function ()
    if lastScissor ~= nil then
        return lastScissor.x, lastScissor.y, lastScissor.w, lastScissor.h
    end
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

Backend.pop = function ()
    local history = stack[#stack]
    lastColor = history.color or { 0, 0, 0, 255 }
    lastScissor = history.scissor

    sdl.setRenderDrawColor(renderer,
        lastColor[1], lastColor[2], lastColor[3], lastColor[4] or 255)
    sdl.renderSetClipRect(renderer, lastScissor) -- Backend.setScissor(history.scissor)
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
    hook(layout, 'wheelmoved', function (x, y)
        return input:handleWheelMove(layout, x, y)
    end)
end

return Backend
