require "acceleration"

nextTimeChangeAllowed = love.timer.getTime() + 1
time_rising = true
Player = {}

function Player:new(old, x, y, height, width, sprite)
	newPlayer = {
		x = x,
		y = y,
		height = height,
		width = width,
		sprite = sprite,
		acceleration = Acceleration:newPlayerAcceleration()
	}
	self.__index = self
	return setmetatable(newPlayer, self)
end



function Player:handleInput(delta_time)
	-- Horizontal movement
	if love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
		self.acceleration.speedX = self.acceleration.speedX - self.acceleration.delta * delta_time
	elseif self.acceleration.speedX < 0 then 
		self.acceleration.speedX = math.min(self.acceleration.speedX + (self.acceleration.delta * 2 * delta_time), 0)
	end
	if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
		self.acceleration.speedX = self.acceleration.speedX + (self.acceleration.delta * delta_time) 
	elseif self.acceleration.speedX > 0 then 
		self.acceleration.speedX = math.max(self.acceleration.speedX - (self.acceleration.delta * 2 * delta_time), 0)
	end

	-- Vertical movement
	if love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
		self.acceleration.speedY = self.acceleration.speedY - self.acceleration.delta * delta_time
	elseif self.acceleration.speedY < 0 then 
		self.acceleration.speedY = math.min(self.acceleration.speedY + (self.acceleration.delta * 2 * delta_time), 0)
	end
	if love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
		self.acceleration.speedY = self.acceleration.speedY + (self.acceleration.delta * delta_time) 
	elseif self.acceleration.speedY > 0 then 
		self.acceleration.speedY = math.max(self.acceleration.speedY - (self.acceleration.delta * 2 * delta_time), 0)
	end

	-- Other
	if love.keyboard.isDown("escape") then
		love.event.quit();
	end

	if love.keyboard.isDown("r") then
		love.event.quit("restart")
	end

	self.acceleration.speedX = math.max(math.min(self.acceleration.speedX, self.acceleration.max), self.acceleration.min)
	self.acceleration.speedY = math.max(math.min(self.acceleration.speedY, self.acceleration.max), self.acceleration.min)

	self.x = math.min(math.max(self.x + self.acceleration.speedX, 0), screen.width - self.width)
	self.y = math.min(math.max(self.y + self.acceleration.speedY, 0), screen.height - self.height)

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