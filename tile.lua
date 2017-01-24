require "position"

Tile = {}

function Tile:newType(path, scale_x, scale_y, blocks)
	newTile = {
		sprite = Sprite:new(path, scale_x, scale_y),
		scale_factor_x = scale_x,
		scale_factor_y = scale_y,
		blocks = blocks
	}
	self.__index = self
	return setmetatable(newTile, self)
end

function Tile:newTile(x, y, width, height, kind)
	new_tile = {
		position = Position:new(x, y),
		width = width,
		height = height,
		kind = kind
	}
	self.__index = self
	return setmetatable(new_tile, self)
end