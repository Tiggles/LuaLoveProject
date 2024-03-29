require "constants"

kinds = {
	rock = 0
}

Room = {}

function Room:new(height, width)
	newRoom = {
		height = height,
		width = width,
		items = {},
		blocks = {},
		enemies = {}
	}
	self.__index = self
	return setmetatable(newRoom, self)
end

function Room:newBlock(x, y, width, height, kind)
	if kind == kinds.rock then
		return Block:newRock(x, y, width, height)
	end
end