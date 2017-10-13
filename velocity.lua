Velocity = {}

function Velocity:newGruntVelocity()
	newVelocity = {
		speedX = 0,
		speedY = 0,
		delta = 7.5,
		min = -5,
		max = 5
	}
	self.__index = self
	return setmetatable(newVelocity, self)
end

function Velocity:newCannonFodderVelocity()
	newVelocity = {
		speedX = 0,
		speedY = 0,
		delta = 2,
		min = -2,
		max = 2
	}
	self.__index = self
	return setmetatable(newVelocity, self)
end

function Velocity:newPlayerVelocity()
	newVelocity = {
		speedX = 0,
		speedY = 0,
		delta = 5,
		min = -20,
		max = 20
	}
	self.__index = self
	return setmetatable(newVelocity, self)
end
