require "constants"

Room = {}

function Room:new(height, width, leftBoundary, rightBoundary)
	newRoom = {
		height = height,
		width = width,
		leftBoundary = leftBoundary,
		rightBoundary = rightBoundary
	}
	self.__index = self
	return setmetatable(newRoom, room)
end