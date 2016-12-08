Acceleration = {}

function Acceleration:newGruntAcceleration()
	newAcceleration = {
		speedX = 0,
		speedY = 0,
		delta = 7.5,
		min = -5,
		max = 5
	}
	self.__index = self
	return setmetatable(newAcceleration, self)
end

function Acceleration:newPlayerAcceleration()
	newAcceleration = {
		speedX = 0,
		speedY = 0,
		delta = 5,
		min = -20,
		max = 20
	}
	self.__index = self
	return setmetatable(newAcceleration, self)
end