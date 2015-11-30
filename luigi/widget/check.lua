--[[--
A check box.

@widget check
--]]--

return function (self)
    self:onPress(function ()
        self.value = not self.value
    end)

    self:onChange(function ()
        local subtype = self.value and 'check.checked' or 'check.unchecked'
        self.type = { 'check', subtype }
    end)

    self.value = not not self.value
end
