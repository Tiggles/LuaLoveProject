require "velocity"

Grunt = {}

function Grunt:new(x, y)
	newGrunt = {
		x = x,
		y = y,
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
	if (player.x < self.x) then
		self.velocity.speedX = self.velocity.speedX - self.velocity.delta * delta_time * game_speed
	elseif (player.x > self.x) then
		self.velocity.speedX = self.velocity.speedX + self.velocity.delta * delta_time * game_speed
	end
	if (player.y > self.y) then
		self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed
	elseif (player.y < self.y) then
		self.velocity.speedY = self.velocity.speedY - self.velocity.delta * delta_time * game_speed
	end

	self.velocity.speedX = math.max(math.min(self.velocity.speedX, self.velocity.max), self.velocity.min)
	self.velocity.speedY = math.max(math.min(self.velocity.speedY, self.velocity.max), self.velocity.min)

	self.x = self.x + (self.velocity.speedX * self.weight * game_speed)
	self.y = self.y + (self.velocity.speedY * self.weight * game_speed)
end
