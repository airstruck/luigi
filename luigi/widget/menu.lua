--[[--
A menu bar.

@widget menu
--]]--

return function (self)

    for index, child in ipairs(self) do
        child.type = child.type or 'menu.item'
        child.parentMenu = self
        child.rootMenu = self
    end

end
