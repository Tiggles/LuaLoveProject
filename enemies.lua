require "velocity"
require "position"
require "sprite"
constants = require "constants"

enemy_counter = 0

Grunt = {}

function Grunt:new(x, y)
	newGrunt = {
		position = Position:new(x, y),
		height = 2,
		width = 2,
		weight = 1 + (love.math.random() / 2),
		name = "grunt" .. enemy_counter,
		velocity = Velocity:newGruntVelocity()
	}
	enemy_counter = enemy_counter + 1
	self.__index = self
	return setmetatable(newGrunt, self)
end

function Grunt:getSprite()
	return self.texturePath;
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

CannonFodder = {}

function CannonFodder:new(x, y)
	new_cannon_fodder = {
		sprite = Sprite:new("Assets/cannonfodder.png", 0.5, 0.5),
		position = Position:new(x, y),
		height = 32,
		width = 32,
		name = "cannonfodder" .. enemy_counter,
		velocity = Velocity:newCannonFodderVelocity()
	}
	enemy_counter = enemy_counter + 1
	self.__index = self
	return setmetatable(new_cannon_fodder, self)

end

function CannonFodder:attack()

end

function CannonFodder:update(delta_time, player, game_speed)
	
end

EnemyType = {}

function EnemyType:newType(path, scale_x, scale_y, width, height)
	new_enemyType = {
		sprite = Sprite:new(path, scale_x, scale_y),
		scale_x = scale_x,
		scale_y = scale_y,
		width = width,
		height = height,
		kind_type = constants.editor_constants.asd
	}
	self.__index = self
	return setmetatable(new_enemyType, self)
end

ActorType = {}

function ActorType:newType(spritePath, scale_x, scale_y, width, height)
	new_actorType = {
		sprite = Sprite:new(spritePath, scale_x, scale_y),
		scale_x = scale_x,
		scale_y = scale_y,
		width = width,
		height = height,
		kind_type = constants.editor_constants.actor
	}
	self.__index = self
	return setmetatable(new_actorType, self)
end