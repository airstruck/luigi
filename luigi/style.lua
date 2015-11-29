local ROOT = (...):gsub('[^.]*$', '')

local Base = require(ROOT .. 'base')

local Style = Base:extend()

function Style:constructor (rules, lookupNames)
    self.rules = rules
    self.lookupNames = lookupNames
end

function Style:getProperty (object, property, original)
    local value = rawget(object, property)
    if value ~= nil then return value end

    original = original or object

    for _, lookupName in ipairs(self.lookupNames) do
        local lookup = rawget(object, lookupName)
            or object.attributes and rawget(object.attributes, lookupName)
        if lookup then
            if type(lookup) ~= 'table' then
                lookup = { lookup }
            end
            for _, lookupValue in ipairs(lookup) do
                for _, rule in ipairs(self:getRules(original, lookupValue)) do
                    local value = self:getProperty(rule, property, original)
                    if value ~= nil then return value end
                end
            end -- lookup values
        end -- if lookup
    end -- lookup names
end

function Style:getRules (object, lookupValue)
    local rules = self.rules
    local result = {}

    for _, flag in ipairs { 'pressed', 'focused', 'hovered', 'active' } do
        if rawget(object, flag) then
            result[#result + 1] = rules[lookupValue .. '_' .. flag]
        else
            result[#result + 1] = rules[lookupValue .. '_not_' .. flag]
        end
    end

    result[#result + 1] = rules[lookupValue]

    return result
end

return Style
