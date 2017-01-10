require "velocity"
require "position"

local bump = require("bump/bump")

time_rising = true
Player = {}
use_keyboard = true
top_down = true

function Player:new(x, y, height, width, path)
	newPlayer = {
		position = Position:new(x, y),
		height = height,
		width = width,
		sprite = Sprite:new(path),
		jumpheight = -2,
		is_jumping = false,
		velocity = Velocity:newPlayerVelocity(),
		nextTimeChangeAllowed = love.timer.getTime() + 1
	}
	self.__index = self
	return setmetatable(newPlayer, self)
end



function Player:handleInput(delta_time, game_speed, entities)
	if use_keyboard then
		return self:handleKeyBoardInput(delta_time, game_speed, entities)
	else 
		return self:handleControllerInput(delta_time, game_speed, entities)
	end
end

function Player:handleKeyBoardInput(delta_time, game_speed, entities)
	if top_down then
		if love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
			self.velocity.speedX = self.velocity.speedX - self.velocity.delta * delta_time * game_speed
		elseif self.velocity.speedX < 0 then 
			self.velocity.speedX = math.min(self.velocity.speedX + (self.velocity.delta * 2 * delta_time), 0)
		end
		if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
			self.velocity.speedX = self.velocity.speedX + self.velocity.delta * delta_time * game_speed
		elseif self.velocity.speedX > 0 then
			self.velocity.speedX = math.max(self.velocity.speedX - (self.velocity.delta * 2 * delta_time), 0)
		end

		--Vertical movement
		if love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
			self.velocity.speedY = self.velocity.speedY - self.velocity.delta * delta_time * game_speed
		elseif self.velocity.speedY < 0 then 
			self.velocity.speedY = math.min(self.velocity.speedY + (self.velocity.delta * 2 * delta_time), 0)
		end
		if love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
			self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed
		elseif self.velocity.speedY > 0 then 
			self.velocity.speedY = math.max(self.velocity.speedY - (self.velocity.delta * 2 * delta_time), 0)
		end
	end

	if side_ways then
		if love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
			self.velocity.speedX = self.velocity.speedX - self.velocity.delta * delta_time * game_speed
		elseif self.velocity.speedX < 0 then 
			self.velocity.speedX = math.min(self.velocity.speedX + (self.velocity.delta * 2 * delta_time), 0)
		end
		if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
			self.velocity.speedX = self.velocity.speedX + self.velocity.delta * delta_time * game_speed
		elseif self.velocity.speedX > 0 then
			self.velocity.speedX = math.max(self.velocity.speedX - (self.velocity.delta * 2 * delta_time), 0)
		end
		-- Jumping
		if love.keyboard.isDown("space") and not is_jumping then
			self.velocity.speedY = self.jumpheight
			is_jumping = true
		elseif love.keyboard.isDown("space") then
			self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed * 1.8
		else
			self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed * 2
		end
		-- Attacking
		if love.keyboard.isDown("w") then

		end
	end

	-- Other
	if love.keyboard.isDown("escape") then
		love.event.quit();
	end

	if love.keyboard.isDown("r") then
		love.event.quit("restart")
	end

	self.velocity.speedX = math.max(math.min(self.velocity.speedX, self.velocity.max), self.velocity.min)
	self.velocity.speedY = math.max(math.min(self.velocity.speedY, self.velocity.max), self.velocity.min)

	local world = bump.newWorld()

	local player = { name = "Player"}

	world:add( player, self.position.x, self.position.y, self.width, self.height)

	for i = 1, #entities.blocks, 1 do
		block = entities.blocks[i]
		world:add( { name = "block" }, block.position.x, block.position.y, block.width, block.height)
	end

	local actualX, actualY, cols, len = world:move(player, self.position.x + self.velocity.speedX * game_speed, self.position.y + self.velocity.speedY * game_speed)

	if self.position.x + self.velocity.speedX * game_speed ~= actualX then
		self.velocity.speedX = self.velocity.speedX * 0.8
	end

	if self.position.y + self.velocity.speedY * game_speed ~= actualY then
		self.velocity.speedY = self.velocity.speedY * 0.8
	end

	self.position.x = actualX
	self.position.y = actualY

	explode = false
	time_change = false

	if love.keyboard.isDown("e") then
		explode = true
	end

	if love.keyboard.isDown("q") and love.timer.getTime() > self.nextTimeChangeAllowed then
		time_rising = not time_rising
		nextTimeChangeAllowed = love.timer.getTime() + 1
	end

	return explode, time_rising
end

function Player:handleControllerInput(delta_time, game_speed)

end