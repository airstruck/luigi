local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')

local Style = Base:extend()

function Style:constructor (rules, ...)
    self.rules = rules
    self.lookupNames = { ... }
end

function Style:getProperty (object, property)
    local ownProperty = rawget(object, property)
    if ownProperty ~= nil then return ownProperty end
    for styleDef in self:each(object) do
        local result = self:getProperty(styleDef, property)
        if result ~= nil then return result end
    end
end

function Style:each (object)
    local rules = self.rules
    local nextStyleName = self:eachName(object)
    return function ()
        local styleName = nextStyleName()
        while styleName do
            local styleDef = rules[styleName]
            if styleDef then return styleDef end
            styleName = nextStyleName()
        end
    end
end

function Style:eachName (object)
    local lookupNames = self.lookupNames
    local lookupNameIndex = 0
    local lookupPropIndex = 0
    local lookupProp

    local returnedSpecialName = {}

    local function checkLookupProp()
        if type(lookupProp) == 'table' and lookupPropIndex >= #lookupProp then
            lookupProp = nil
        end
        while not lookupProp do
            returnedSpecialName = {}
            lookupPropIndex = 0
            lookupNameIndex = lookupNameIndex + 1
            if lookupNameIndex > #lookupNames then return end
            lookupProp = rawget(object, lookupNames[lookupNameIndex])
            if type(lookupProp) == 'string' then
                lookupProp = { lookupProp }
            end
        end
        return true
    end
    local function getSpecialName (...)
        for k, name in ipairs({ ... }) do
            if not returnedSpecialName[name] then
                returnedSpecialName[name] = true
                if rawget(object, name) then
                    return lookupProp[lookupPropIndex + 1] .. '_' .. name
                else
                    return lookupProp[lookupPropIndex + 1] .. '_not_' .. name
                end
            end
        end
    end
    return function ()
        if not checkLookupProp() then return end
        local specialName = getSpecialName('pressed', 'hovered')
        if specialName then return specialName end
        lookupPropIndex = lookupPropIndex + 1
        return lookupProp[lookupPropIndex]
    end
end

return Style
