require "velocity"
require "position"
require "sprite"

local bump = require("bump/bump")
local constants = require "constants"


time_rising = true
use_keyboard = 0
use_controller = 1
use_mouse = 2

game_view_state = constants.world_constants.side_ways

Player = {}

function set_game_view_state(state)
	game_view_state = state
end

function Player:new(x, y, height, width, path, scale_x, scale_y)
	newPlayer = {
		position = Position:new(x, y),
		height = height,
		width = width,
		sprite = Sprite:new(path, scale_x, scale_y),
		jumpheight = -4,
		can_jump = false,
		is_jumping = false,
		velocity = Velocity:newPlayerVelocity(),
		nextTimeChangeAllowed = love.timer.getTime(),
		nextJumpAllowed = love.timer.getTime()
	}
	self.__index = self
	return setmetatable(newPlayer, self)
end

function Player:handleInput(delta_time, game_speed, control_type)
	if use_keyboard == control_type then
		return self:handleKeyBoardInput(delta_time, game_speed)
	elseif use_controller == control_type then
		return self:handleControllerInput(delta_time, game_speed)
	elseif use_mouse == control_type then
		return self:handleIsometricMouseControls(delta_time, game_speed)
	end 
end

function Player:handleKeyBoardInput(delta_time, game_speed)
	if constants.world_constants.top_down == game_view_state then
		self:handleTopdownKeyboard(delta_time, game_speed)
	elseif constants.world_constants.side_ways == game_view_state then
		self:handleSidewaysKeyboard(delta_time, game_speed)
	elseif constants.world_constants.isometric == game_view_state then

	end

	-- Other
	if love.keyboard.isDown("escape") then
		love.event.quit();
	end

	if love.keyboard.isDown("r") then
		love.event.quit("restart")
	end

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

function Player:handleMovementLogic(entities)
	self.velocity.speedX = math.max(math.min(self.velocity.speedX, self.velocity.max), self.velocity.min)
	self.velocity.speedY = math.max(math.min(self.velocity.speedY, self.velocity.max), self.velocity.min)

	local world = bump.newWorld()

	local player = { name = "Player"}

	world:add( player, self.position.x, self.position.y, self.width, self.height)

	for i = 1, #entities.tiles, 1 do
		tile = entities.tiles[i]
		tile_kind = entities.editorTypes[tile.kind]
		if tile_kind.is_blocking then
			world:add( { name = "blocking_tile" }, tile.position.x, tile.position.y, tile_kind.width, tile_kind.height)
		end
	end

	local intendedX = self.position.x + self.velocity.speedX * game_speed
	local intendedY = self.position.y + self.velocity.speedY * game_speed

	local actualX, actualY, cols, len = world:move(player, intendedX, intendedY)

	if intendedX ~= actualX then
		self.velocity.speedX = self.velocity.speedX * 0.8
		if constants.world_constants.side_ways then
			self.can_jump = true
		end
		if intendedX > actualX and self.is_jumping then
			self.velocity.speedX = -3
		elseif intendedX < actualX and self.is_jumping then
			self.velocity.speedX = 3
		end
	end
	self.is_jumping = false
	if intendedY ~= actualY then
		self.velocity.speedY = self.velocity.speedY * 0.8
		if constants.world_constants.side_ways and intendedY > actualY then
			self.can_jump = true
		end
	end

	if intendedY == actualY and intendedX == actualX then
		self.can_jump = false
	end

	self.position.x = actualX
	self.position.y = actualY
end

function Player:handleIsometricMouseControls(delta_time, game_speed)
	self.position.x = love.mouse.getX()
	self.position.y = love.mouse.getY()
	return love.mouse.getX(), love.mouse.getY(), love.mouse.isDown(1), love.mouse.isDown(2), love.keyboard.isDown("q"), love.keyboard.isDown("e")
end

function Player:handleTopdownKeyboard(delta_time, game_speed)
	-- Horizontal
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

function Player:handleSidewaysKeyboard(delta_time, game_speed)
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
	if love.keyboard.isDown("space") and self.can_jump and self.nextJumpAllowed + 0.3 < love.timer.getTime() then
		self.velocity.speedY = self.jumpheight
		self.nextJumpAllowed = love.timer.getTime()
		self.is_jumping = true
		self.can_jump = false
	elseif love.keyboard.isDown("space") then
		self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed * 1.8
	else
		self.velocity.speedY = self.velocity.speedY + self.velocity.delta * delta_time * game_speed * 2
	end
	-- Attacking
	if love.keyboard.isDown("w") then

	end
end

function Player:handleControllerInput(delta_time, game_speed)

end