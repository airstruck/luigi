--[[--
A radio widget.

When pressed, a radio widget's @{attribute.value|value} changes to
`true`, and the values of other radio widgets in the same `group`
change to `false`.

Changing the value of a radio button causes it to change its appearance to
indicate its value. The standard themes use the @{attribute.icon|icon}
attribute for this purpose. If a custom icon is provided when using the
standard themes, the widget's value should be indicated in some other way.

@widget radio
--]]--

local groups = {}

local function remove (t, value)
    for i, v in t do
        if v == value then return table.remove(t, i) end
    end
end

local function setGroup (self, value)
    -- remove the widget from the old group
    local oldValue = self.attributes.group
    local oldGroup = oldValue and groups[oldValue]
    if oldGroup then
        remove(oldGroup, self)
        -- TODO: is it safe to remove these?
        if #oldGroup < 1 then groups[oldValue] = nil end
    end
    -- add the widget to the new group, or 'defaultGroup' if no group specified
    value = value or 'defaultGroup'
    if not groups[value] then
        groups[value] = {}
    end
    local group = groups[value]
    group[#group + 1] = self
    self.attributes.group = value
    local layout = self:getMasterLayout()
    if not layout[value] then
        layout:createWidget { id = value, items = group }
    end
    self.groupWidget = layout[value]
end

return function (self)

--[[--
Special Attributes

@section special
--]]--

--[[--
Widget group.

Should contain a string identifying the widget's group.
If not defined, defaults to the string `'default'`.

When a radio widget is pressed, the values of other radio widgets
in the same group change to `false`.

@attrib group
--]]--
    self:defineAttribute('group', { set = setGroup })
--[[--
@section end
--]]--

    -- when we bubble events, send them to the group widget
    local bubbleEvent = self.bubbleEvent
    function self:bubbleEvent (...)
        local result = bubbleEvent(self, ...)
        if result ~= nil then return result end
        return self.groupWidget:bubbleEvent(...)
    end

    self:onPress(function (event)
        if event.button ~= 'left' then return end
        for _, widget in ipairs(groups[self.group]) do
            widget.value = widget == self
        end
    end)

    self:onChange(function (event)
         -- change event is only sent to group widget once.
        if not self.value then return false end
        self.groupWidget.selected = self
    end)

    self.value = not not self.value
end
