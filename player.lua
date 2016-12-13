require "velocity"

nextTimeChangeAllowed = love.timer.getTime() + 1
time_rising = true
Player = {}
is_jumping = false

function Player:new(old, x, y, height, width, sprite)
	newPlayer = {
		x = x,
		y = y,
		height = height,
		width = width,
		sprite = sprite,
		jumpheight = -2,
		velocity = Velocity:newPlayerVelocity()
	}
	self.__index = self
	return setmetatable(newPlayer, self)
end



function Player:handleInput(delta_time, game_speed)
	-- Horizontal movement
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

	-- Vertical movement
	--[[if love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
		self.velocity.speedY = self.velocity.speedY - self.velocity.delta * delta_time * game_speed
	elseif self.velocity.speedY < 0 then 
		self.velocity.speedY = math.min(self.velocity.speedY + (self.velocity.delta * 2 * delta_time), 0)
	end
	if love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
		self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed
	elseif self.velocity.speedY > 0 then 
		self.velocity.speedY = math.max(self.velocity.speedY - (self.velocity.delta * 2 * delta_time), 0)
	end]]--

	-- Jumping
	if love.keyboard.isDown("space") and not is_jumping then
		self.velocity.speedY = self.jumpheight
		is_jumping = true
	elseif love.keyboard.isDown("space") then
		self.velocity.speedY = self.velocity.speedY + delta_time * game_speed * 0.8
	else
		self.velocity.speedY = self.velocity.speedY + delta_time * game_speed
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

	self.x = math.min(math.max(self.x + self.velocity.speedX * game_speed, 0), screen.width  - self.width)
	self.y = math.min(math.max(self.y + self.velocity.speedY * game_speed, 0), screen.height - self.height)

	explode = false
	time_change = false

	if love.keyboard.isDown("e") then
		explode = true
	end

	if love.keyboard.isDown("q") and love.timer.getTime() > nextTimeChangeAllowed then
		time_rising = not time_rising
		nextTimeChangeAllowed = love.timer.getTime() + 1
	end 

	return explode, time_rising
end