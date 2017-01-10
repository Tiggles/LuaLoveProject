Position = {}

function Position:new(x, y)
	new_position = {
		x = x,
		y = y
	}
	self.__index = self
	return setmetatable(new_position, self)
end
