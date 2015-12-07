--[[--
A radio button.

Radio buttons change their @{attribute.value|value} attribute to
`true` when pressed. Radio buttons should also have a `group`
attribute. When a radio button is pressed, other radio buttons
in the same layout with the same `group` attribute change their values
to `false`.

Changing the value of a radio button causes it to change its appearance to
indicate its value. The standard themes use the @{attribute.icon|icon}
attribute for this purpose. If a custom icon is provided when using the
standard themes, the widget's value should be indicated in some other way.

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

    self.value = not not self.value
end
