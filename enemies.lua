require "boundingbox"


Grunt = {}

function Grunt:new(x, y)
	newGrunt = {
		x = x,
		y = y,
		boundingBox = BoundingBox:new(15, 15)
	}
	self.__index = self
	return setmetatable(newGrunt, self)
end

function Grunt:getHeight()
	return 5
end

function Grunt:getSprite()
	return texturePath;
end

function Grunt:getMovementSpeed()
	return 20
end

function Grunt:update(delta_time, player)
	Grunt:move(delta_time, self, player)
end

function Grunt:attack()

end

function Grunt:move(delta_time, grunt, player)
	if (player.x > grunt.x) then
		grunt.x = grunt.x + grunt:getMovementSpeed() * delta_time
	elseif (player.x < grunt.x) then
		grunt.x = grunt.x - grunt:getMovementSpeed() * delta_time
	end
		if (player.y > grunt.y) then
		grunt.y = grunt.y + grunt:getMovementSpeed() * delta_time
	elseif (player.y < grunt.y) then
		grunt.y = grunt.y - grunt:getMovementSpeed() * delta_time
	end
end

