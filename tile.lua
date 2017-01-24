require "position"

TileType = {}

function TileType:newType(path, scale_x, scale_y, width, height, is_blocking)
	newTileType = {
		sprite = Sprite:new(path, scale_x, scale_y),
		scale_factor_x = scale_x,
		scale_factor_y = scale_y,
		width = width,
		height = height,
		is_blocking = is_blocking
	}
	self.__index = self
	return setmetatable(newTileType, self)
end

Tile = {}

function Tile:newTile(x, y, kind)
	new_tile = {
		position = Position:new(x, y),
		kind = kind
	}
	self.__index = self
	return setmetatable(new_tile, self)
end