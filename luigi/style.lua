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

    local rules = self.rules
    original = original or object

    for _, lookupName in ipairs(self.lookupNames) do
        local lookup = rawget(object, lookupName)
            or object.attributes and rawget(object.attributes, lookupName)
        if lookup then
            if type(lookup) ~= 'table' then
                lookup = { lookup }
            end
            for _, lookupValue in ipairs(lookup) do
                local rule = rules[lookupValue]
                if rule then
                    local value = self:getProperty(rule, property, original)
                    if type(value) == 'function' then
                        value = value(original)
                    end
                    if value ~= nil then return value end
                end
            end -- lookup values
        end -- if lookup
    end -- lookup names
end

return Style
