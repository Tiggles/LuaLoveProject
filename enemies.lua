require "acceleration"

Grunt = {}

function Grunt:new(x, y)
	newGrunt = {
		x = x,
		y = y,
		height = 2,
		width = 2,
		weight = 1 + (love.math.random() / 2),
		acceleration = Acceleration:newGruntAcceleration()
	}
	self.__index = self
	return setmetatable(newGrunt, self)
end

function Grunt:getSprite()
	return texturePath;
end

function Grunt:update(delta_time, player, game_speed)
	Grunt:move(delta_time, self, player, game_speed)
end

function Grunt:attack()

end

function Grunt:move(delta_time, grunt, player, game_speed)
	if (player.x < grunt.x) then
		grunt.acceleration.speedX = grunt.acceleration.speedX - grunt.acceleration.delta * delta_time * game_speed
	elseif (player.x > grunt.x) then
		grunt.acceleration.speedX = grunt.acceleration.speedX + grunt.acceleration.delta * delta_time * game_speed
	end
	if (player.y > grunt.y) then
		grunt.acceleration.speedY = grunt.acceleration.speedY + grunt.acceleration.delta * delta_time * game_speed
	elseif (player.y < grunt.y) then
		grunt.acceleration.speedY = grunt.acceleration.speedY - grunt.acceleration.delta * delta_time * game_speed
	end

	grunt.acceleration.speedX = math.max(math.min(grunt.acceleration.speedX, grunt.acceleration.max), grunt.acceleration.min)
	grunt.acceleration.speedY = math.max(math.min(grunt.acceleration.speedY, grunt.acceleration.max), grunt.acceleration.min)

	grunt.x = grunt.x + (grunt.acceleration.speedX * grunt.weight * game_speed)
	grunt.y = grunt.y + (grunt.acceleration.speedY * grunt.weight * game_speed)
end