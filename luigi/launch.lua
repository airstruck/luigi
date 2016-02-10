--[[--
Launcher for the LuaJIT backend.

Looks for main.lua. Launch it like this:

    luajit myapp/lib/luigi/launch.lua

If luigi isn't inside the project directory, pass
the path containing main.lua as the second argument.
The path must end with a directory separator.

    luajit /opt/luigi/launch.lua ./myapp/

If the app prefixes luigi modules with something
other then 'luigi', pass that prefix as the third
argument.

    luajit /opt/luigi/launch.lua ./myapp/ lib.luigi

--]]--
local packagePath = package.path
local libRoot = arg[0]:gsub('[^/\\]*%.lua$', '')
local appRoot, modPath = ...

local function run (appRoot, modPath)
    package.path = packagePath .. ';' .. appRoot .. '?.lua'
    rawset(_G, 'LUIGI_APP_ROOT', appRoot)
    require 'main'
    require (modPath .. '.backend').run()
end

-- expect to find main.lua in appRoot if specified
if appRoot then
    return run(appRoot, modPath or 'luigi')
end

-- try to find main.lua in a parent of this library, recursively.
local lastLibRoot = libRoot
repeat
    if io.open(libRoot .. 'main.lua') then
        return run(libRoot, modPath)
    end
    lastLibRoot = libRoot
    libRoot = libRoot:gsub('([^/\\]*).$', function (m)
        modPath = modPath and (m .. '.' .. modPath) or m
        return ''
    end)
until libRoot == lastLibRoot

error 'main.lua not found'




