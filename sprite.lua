Sprite = {}

function Sprite:new(path, scale_x, scale_y)
	new_sprite = {
		sprite = love.graphics.newImage(path),
		scale_factor_x = scale_x,
		scale_factor_y = scale_y
	}
	self.__index = self
	return setmetatable(new_sprite, self)
end