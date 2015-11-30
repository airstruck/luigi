--[[--
A radio button.

@widget radio
--]]--

-- TODO: make `group` a first-class attribute
local groups = {}

return function (self)
    local groupName = self.group or 'default'

    if not groups[groupName] then
        groups[groupName] = {}
    end

    local group = groups[groupName]

    group[#group + 1] = self

    self:onPress(function ()
        for _, widget in ipairs(group) do
            widget.value = widget == self
        end
    end)

    self:onChange(function ()
        local subtype = self.value and 'radio.checked' or 'radio.unchecked'
        self.type = { 'radio', subtype }
    end)

    self.value = not not self.value
end
