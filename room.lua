require "constants"

kinds = {
	rock = 0
}

Room = {}

function Room:new(height, width, left_boundary, right_boundary, top_boundary, bottom_boundary)
	newRoom = {
		height = height,
		width = width,
		left_boundary = left_boundary,
		right_boundary = right_boundary,
		top_boundary = top_boundary,
		bottom_boundary = bottom_boundary
	}
	self.__index = self
	return setmetatable(newRoom, self)
end

function Room:newBlock(x, y, width, height, kind)
	if kind == kinds.rock then
		return Block:newRock(x, y, width, height)
	end
end

Block = {}

function Block:newRock(x, y, width, height)
	newRock = {
		x = x,
		y = y,
		width = width,
		height = height
	}
	self.__index = self
	return setmetatable(newRock, self)
end