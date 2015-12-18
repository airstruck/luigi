local ROOT = (...):gsub('[^.]*$', '')

if _G.love and _G.love._version_minor > 8 then
    return require(ROOT .. 'backend.love')
else
    return require(ROOT .. 'backend.ffisdl')
end

