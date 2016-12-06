BoundingBox = {}

function BoundingBox:new(x, y, height, width)
	newBoundingBox = {
		x = x, y = y, height = height, width = width 
	}
	self.__index = self
	return setmetatable(newBoundingBox, self)
end