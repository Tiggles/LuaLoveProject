Player = {}

function Player:new(old, x, y, height, width, sprite)
	newPlayer = {
		x = x,
		y = y,
		height = height,
		width = width,
		sprite = sprite,
		acceleration = {
			speedX = 0,
			speedY = 0,
			delta = 5,
			min = -20,
			max = 20
		}
	}
	self.__index = self
	return setmetatable(newPlayer, self)
end

function Player:handleInput(delta_time)
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

	if love.keyboard.isDown("escape") then
		love.event.quit();
	end

	if love.keyboard.isDown("r") then
		love.event.quit("restart")
	end

	self.acceleration.speedX = math.max(math.min(self.acceleration.speedX, self.acceleration.max), self.acceleration.min)
	
	self.x = math.min(math.max(self.x + self.acceleration.speedX, 0 + self.width / 2), screen.width - self.width / 2)
	--self.y = math.min(math.max(self.y + self.acceleration.speedY, 0 + self.height / 2), screen.height - player.height / 2)
end