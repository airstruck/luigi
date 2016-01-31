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

function Shortcut.appliesToPlatform (value)
    if isMac and value:match '%f[%a]win%-'
    or not isMac and value:match '%f[%a]mac%-' then
        return false
    end
    return true
end

function Shortcut.expandAliases (value)
    return value
        :gsub('%f[%a]cmd%-', 'mac-gui-')
        :gsub('%f[%a]command%-', 'mac-gui-')
        :gsub('%f[%a]option%-', 'mac-alt-')
end

function Shortcut.parseKeyCombo (value)
    -- expand command- and option- aliases
    value = Shortcut.expandAliases(value)

    -- exit early if shortcut is for different platform
    if not Shortcut.appliesToPlatform(value) then return end

    -- expand c- special modifier
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

function Shortcut.stringify (shortcut)
    if type(shortcut) ~= 'table' then
        shortcut = { shortcut }
    end
    for _, value in ipairs(shortcut) do
        value = Shortcut.expandAliases(value)
        if Shortcut.appliesToPlatform(value) then
            if isMac then
                value = value
                    :gsub('%f[%a]c%-', 'cmd-')
                    :gsub('%f[%a]gui%-', 'cmd-')
                    :gsub('%f[%a]alt%-', 'option-')
                    -- Have Love backend default to DejaVuSans
                    -- so we can use these instead of the above
                    --[[
                    :gsub('%f[%a]c%-', '⌘')
                    :gsub('%f[%a]gui%-', '⌘')
                    :gsub('%f[%a]alt%-', '⌥')
                    :gsub('%f[%a]shift%-', '⇧')
                    ]]
            else
                value = value
                    :gsub('%f[%a]c%-', 'ctrl-')
                    :gsub('%f[%a]gui%-', 'windows-')
            end
            value = value:gsub('%f[%a]win%-', ''):gsub('%f[%a]mac%-', '')
            value = value:gsub('%f[%w].', string.upper)
            return value
        end
    end
end

return Shortcut
