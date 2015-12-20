--[[--
A check box.

Check boxes toggle their @{attribute.value|value} attribute between
`true` and `false` when pressed.

Changing the value of a check box causes it to change its appearance to
indicate its value. The standard themes use the @{attribute.icon|icon}
attribute for this purpose. If a custom icon is provided when using the
standard themes, the widget's value should be indicated in some other way.

@widget check
--]]--

return function (self)
    self:onPress(function (event)
        if event.button ~= 'left' then return end
        self.value = not self.value
    end)

    self.value = not not self.value
end
