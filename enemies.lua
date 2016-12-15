require "velocity"
require "position"


Grunt = {}

function Grunt:new(x, y)
	newGrunt = {
		position = Position:new(x, y),
		height = 2,
		width = 2,
		weight = 1 + (love.math.random() / 2),
		velocity = Velocity:newGruntVelocity()
	}
	self.__index = self
	return setmetatable(newGrunt, self)
end

function Grunt:getSprite()
	return texturePath;
end

function Grunt:update(delta_time, player, game_speed)
	self:move(delta_time, player, game_speed)
end

function Grunt:attack()

end

function Grunt:move(delta_time, player, game_speed)
	if (player.position.x < self.position.x) then
		self.velocity.speedX = self.velocity.speedX - self.velocity.delta * delta_time * game_speed
	elseif (player.position.x > self.position.x) then
		self.velocity.speedX = self.velocity.speedX + self.velocity.delta * delta_time * game_speed
	end
	if (player.position.y > self.position.y) then
		self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed
	elseif (player.position.y < self.position.y) then
		self.velocity.speedY = self.velocity.speedY - self.velocity.delta * delta_time * game_speed
	end

	self.velocity.speedX = math.max(math.min(self.velocity.speedX, self.velocity.max), self.velocity.min)
	self.velocity.speedY = math.max(math.min(self.velocity.speedY, self.velocity.max), self.velocity.min)

	self.position.x = self.position.x + (self.velocity.speedX * self.weight * game_speed)
	self.position.y = self.position.y + (self.velocity.speedY * self.weight * game_speed)
end
