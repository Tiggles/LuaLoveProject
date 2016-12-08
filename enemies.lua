require "acceleration"

Grunt = {}

function Grunt:new(x, y)
	newGrunt = {
		x = x,
		y = y,
		height = 25,
		width = 25,
		acceleration = Acceleration:newGruntAcceleration()
	}
	self.__index = self
	return setmetatable(newGrunt, self)
end

function Grunt:getSprite()
	return texturePath;
end

function Grunt:update(delta_time, player)
	Grunt:move(delta_time, self, player)
end

function Grunt:attack()

end

function Grunt:move(delta_time, grunt, player)
	if (player.x < grunt.x) then
		grunt.acceleration.speedX = grunt.acceleration.speedX - grunt.acceleration.delta * delta_time
	elseif (player.x > grunt.x) then
		grunt.acceleration.speedX = grunt.acceleration.speedX + grunt.acceleration.delta * delta_time
	end
	if (player.y > grunt.y) then
		grunt.acceleration.speedY = grunt.acceleration.speedY + grunt.acceleration.delta * delta_time
	elseif (player.y < grunt.y) then
		grunt.acceleration.speedY = grunt.acceleration.speedY - grunt.acceleration.delta * delta_time
	end

	grunt.acceleration.speedX = math.max(math.min(grunt.acceleration.speedX, grunt.acceleration.max), grunt.acceleration.min)
	grunt.acceleration.speedY = math.max(math.min(grunt.acceleration.speedY, grunt.acceleration.max), grunt.acceleration.min)
	
	grunt.x = grunt.x + grunt.acceleration.speedX
	grunt.y = grunt.y + grunt.acceleration.speedY
end