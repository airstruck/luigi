--[[--
Keyboard shortcut module.
--]]--

local ROOT = (...):gsub('[^.]*$', '')

local Backend = require(ROOT .. 'backend')

local Shortcut = {}

local isMac = Backend.isMac()

local ALT = 1
local CTRL = 2
local SHIFT = 4
local GUI = 8

function Shortcut.parseKeyCombo (value)
    -- expand command- and option- aliases
    value = value
        :gsub('%f[%a]command%-', 'mac-gui-')
        :gsub('%f[%a]option%-', 'mac-alt-')

    -- exit early if shortcut is for different platform
    if isMac and value:match 'win%-' or not isMac and value:match 'mac%-' then
        return
    end

    -- expand c- alias
    if isMac then
        value = value:gsub('%f[%a]c%-', 'gui-')
    else
        value = value:gsub('%f[%a]c%-', 'ctrl-')
    end

    -- extract main key
    local mainKey = value:match '[^%-]*%-?$'

    -- extract modifiers
    local alt = value:match '%f[%a]alt%-' and ALT or 0
    local ctrl = value:match '%f[%a]ctrl%-' and CTRL or 0
    local shift = value:match '%f[%a]shift%-' and SHIFT or 0
    local gui = value:match '%f[%a]gui%-' and GUI or 0

    return mainKey, alt + ctrl + shift + gui
end

function Shortcut.getModifierFlags ()
    local alt = Backend.isKeyDown('lalt', 'ralt') and ALT or 0
    local ctrl = Backend.isKeyDown('lctrl', 'rctrl') and CTRL or 0
    local shift = Backend.isKeyDown('lshift', 'rshift') and SHIFT or 0
    local gui = Backend.isKeyDown('lgui', 'rgui') and GUI or 0
    return alt + ctrl + shift + gui
end

return Shortcut
