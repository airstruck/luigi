return function (self)

    self:onPressDrag(function (event)
        local axis = self.parent.flow
        if axis == 'x' then
            dimension = 'width'
        else
            axis = 'y'
            dimension = 'height'
        end
        local prevSibling = self:getPrevious()
        local nextSibling = self:getNext()
        local prevSize = prevSibling and prevSibling[dimension]
        local nextSize = nextSibling and nextSibling[dimension]
        if prevSize then
            prevSibling:setDimension(dimension,
                    event[axis] - prevSibling:calculatePosition(axis))
        end
        if nextSize then
            nextSibling:setDimension(dimension,
                    nextSibling:calculatePosition(axis) +
                    nextSibling[dimension] - event[axis])
        end

        prevSibling:reshape()
        nextSibling:reshape()
        self:reshape()
    end)

end
