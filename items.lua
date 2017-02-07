require("position")
local constants = require "constants"


CollectibleType = {}

function CollectibleType:newType(path, scale_x, scale_y, width, height)
	newCollectibleType = {
		sprite = Sprite:new(path, scale_x, scale_y),
		scale_x = scale_x,
		scale_y = scale_y,
		width = width,
		height = height,
		type_kind = constants.editor_constants.collectible
	}
	self.__index = self
	return setmetatable(newCollectibleType, self)
end

Collectible = {}

function Collectible:newCollectible(x, y, kind)
	new_collectible = {
		position = Position:new(x, y),
		kind = kind
	}
	self.__index = self
	return setmetatable(new_collectible, self)
end