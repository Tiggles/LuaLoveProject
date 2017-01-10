Sprite = {}

function Sprite:new(path)
	new_sprite = {
		sprite = love.graphics.newImage(path)
	}
	self.__index = self
	return setmetatable(new_sprite, self)
end