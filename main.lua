require "room"
require "enemies"
require "player"
require "items"
require "helper_functions"

-- Window Initialization

screen = { width = 800, height = 600, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = false, vsync = true, minwidth = 800, minheight=600, fullscreen=false })
love.window.setTitle( "Generic Planet Mover and Attractor" )

-- Value Initialization

local constants = require "constants"

entities = {
	player = Player:new(20, 20, 20, 20, "Assets/BILD1321.png"),
	enemies = {},
	blocks = {}
}

game_speed = 1
in_focus = false

function love.load()
	background = love.graphics.newImage("Assets/background.jpg")
	love.graphics.setBackgroundColor( 0, 0, 25 )
	--boundaries
	table.insert(entities.blocks, Block:newRock( -1, 0, 1, screen.height))
	table.insert(entities.blocks, Block:newRock( 0, -1, screen.width, 1))
	table.insert(entities.blocks, Block:newRock( screen.width, 0, 1, screen.height))
	-- highest level

	table.insert(entities.blocks, Block:newRock( 150, 280, 20, 20))
	table.insert(entities.blocks, Block:newRock( 250, 280, 20, 20))
	table.insert(entities.blocks, Block:newRock( 350, 280, 20, 20))
	table.insert(entities.blocks, Block:newRock( 450, 280, 20, 20))
	table.insert(entities.blocks, Block:newRock( 550, 280, 20, 20))
	table.insert(entities.blocks, Block:newRock( 650, 280, 20, 20))


	table.insert(entities.blocks, Block:newRock( 100, 350, 20, 20))
	table.insert(entities.blocks, Block:newRock( 200, 350, 20, 20))
	table.insert(entities.blocks, Block:newRock( 300, 350, 20, 20))
	table.insert(entities.blocks, Block:newRock( 400, 350, 20, 20))
	table.insert(entities.blocks, Block:newRock( 500, 350, 20, 20))
	table.insert(entities.blocks, Block:newRock( 600, 350, 20, 20))


	-- lowest level
	table.insert(entities.blocks, Block:newRock( 150, 420, 20, 20))
	table.insert(entities.blocks, Block:newRock( 250, 420, 20, 20))
	table.insert(entities.blocks, Block:newRock( 350, 420, 20, 20))
	table.insert(entities.blocks, Block:newRock( 450, 420, 20, 20))
	table.insert(entities.blocks, Block:newRock( 550, 420, 20, 20))
	table.insert(entities.blocks, Block:newRock( 650, 420, 20, 20))
	-- bottom
	table.insert(entities.blocks, Block:newRock( 0, 480, 800, 600))
	for i = 1, 400 do
		table.insert(entities.enemies, Grunt:new(10*i , 5*i))
	end
end

function love.focus(focus)
	in_focus = focus
end

function love.update(delta_time)

	game_speed = update_gameSpeed(game_speed, delta_time, time_rising)

	if not in_focus then return end

	local explode, time_rising = entities.player:handleInput(delta_time, game_speed, entities)
	entities.player:handleMovementLogic(entities)

	if explode then
		for i = #entities.enemies, 1, -1 do
			if entities.enemies[i].position.x > entities.player.position.x then
				entities.enemies[i].velocity.speedX = entities.enemies[i].velocity.speedX + 10 * delta_time * game_speed
			else
				entities.enemies[i].velocity.speedX = entities.enemies[i].velocity.speedX - 10 * delta_time * game_speed
			end
			if entities.enemies[i].position.y > entities.player.position.y then
				entities.enemies[i].velocity.speedY = entities.enemies[i].velocity.speedY + 10 * delta_time * game_speed
			else
				entities.enemies[i].velocity.speedY = entities.enemies[i].velocity.speedY - 10 * delta_time * game_speed
			end
		end	
	end

	for i = #entities.enemies, 1, -1 do
		entities.enemies[i]:update(delta_time, entities.player, game_speed)
		--if check_collision(entities.player, entities.enemies[i]) then
		--	table.remove(entities.enemies, i)
		--end
	end
end

memory_usage = 0
last_memory_check = love.timer.getTime()

function love.draw()
	-- Draw Room
	love.graphics.draw(background)

	-- Draw blocks
	for i = #entities.blocks, 1, -1 do
		local block = entities.blocks[i];
		--love.graphics.draw(block.image, block.x, block.y, 0, 0, 0, 0, 0, 0, 0)
		love.graphics.rectangle("fill", block.position.x, block.position.y, block.width, block.height)
	end

	-- Draw Items

	-- Draw player
	love.graphics.rectangle("fill", entities.player.position.x, entities.player.position.y, entities.player.width, entities.player.height)
	love.graphics.draw(entities.player.sprite.sprite, entities.player.position.x, entities.player.position.y, 0, 0.013, 0.013, entities.player.width / 2, entities.player.height / 2, 0, 0)

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		love.graphics.rectangle("fill", enemy.position.x, enemy.position.y, enemy.width, enemy.height)
	end


	-- HUD
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 20, 10, 1000, "left" )
	love.graphics.printf("Particles: " .. #entities.enemies, 20, 20, 1000, "left" )
	love.graphics.printf("Gamespeed: " .. game_speed, 20, 30, 1000, "left" )
	love.graphics.printf("Y speed: " .. entities.player.velocity.speedY, 20, 40, 1000, "left")
	love.graphics.printf("X speed: " .. entities.player.velocity.speedX, 20, 50, 1000, "left")
	love.graphics.printf("can jump: " .. tostring(entities.player.can_jump), 20, 60, 1000, "left")
	love.graphics.printf("is jumping: " .. tostring(entities.player.is_jumping), 20, 70, 1000, "left")
	love.graphics.printf("Memory actually used (in kB): " .. memory_usage, 20, 80, 1000, "left")
	if last_memory_check + 1 < love.timer.getTime() then
		memory_usage = collectgarbage("count")
		last_memory_check = love.timer.getTime()
	end
end
