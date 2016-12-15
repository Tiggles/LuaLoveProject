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
player = Player:new(nil, 0, 0, 20, 20, nil)
enemies = {}
blocks = {}
game_speed = 1
in_focus = false
--current_room = Room:newRoom()

function love.load()
	player.image = love.graphics.newImage("Assets/BILD1321.png")
	background = love.graphics.newImage("Assets/background.jpg")
	love.graphics.setBackgroundColor( 0, 0, 25 )
	table.insert(blocks, Block:newRock(200, 200, 50, 50))
	table.insert(blocks, Block:newRock(400, 200, 50, 50))
	table.insert(blocks, Block:newRock(600, 200, 50, 50))
	for i = 1, 400 do
		table.insert(enemies, Grunt:new(10*i , 5*i))
	end
end

function love.focus(focus)
	in_focus = focus
end

function love.update(delta_time)

	game_speed = update_gameSpeed(game_speed, delta_time, time_rising)

	if not in_focus then return end

	for i = #blocks, 1, -1 do
		local block = blocks[i]
		if check_collision(block, player) then
			
		end
	end

	local explode, time_rising = player:handleInput(delta_time, game_speed)

	if explode then
		for i = #enemies, 1, -1 do
			if enemies[i].x > player.x then
				enemies[i].velocity.speedX = enemies[i].velocity.speedX + 10 * delta_time * game_speed
			else
				enemies[i].velocity.speedX = enemies[i].velocity.speedX - 10 * delta_time * game_speed
			end
			if enemies[i].y > player.y then
				enemies[i].velocity.speedY = enemies[i].velocity.speedY + 10 * delta_time * game_speed
			else
				enemies[i].velocity.speedY = enemies[i].velocity.speedY - 10 * delta_time * game_speed
			end
		end	
	end

	for i = #enemies, 1, -1 do
		enemies[i]:update(delta_time, player, game_speed)
		if check_collision(player, enemies[i]) then
			table.remove(enemies, i)
		end
	end
end

function love.draw()
	-- Draw Room
	love.graphics.draw(background)

	-- Draw blocks
	for i = #blocks, 1, -1 do
		local block = blocks[i];
		--love.graphics.draw(block.image, block.x, block.y, 0, 0, 0, 0, 0, 0, 0)
		love.graphics.rectangle("fill", block.position.x, block.position.y, block.width, block.height)
	end

	-- Draw Items

	-- Draw player
	love.graphics.rectangle("fill", player.position.x, player.position.y, player.width, player.height)
	love.graphics.draw(player.image, player.position.x, player.position.y, 0, 0.013, 0.013, player.width / 2, player.height / 2, 0, 0)

	-- Draw enemies
	for i = #enemies, 1, -1 do
		local enemy = enemies[i]
		love.graphics.rectangle("fill", enemy.position.x, enemy.position.y, enemy.width, enemy.height)
	end


	-- HUD
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 20, 10, 1000, "left" )
	love.graphics.printf("Particles: " .. #enemies, 20, 20, 1000, "left" )
	love.graphics.printf("Gamespeed: " .. game_speed, 20, 30, 1000, "left" )
	love.graphics.printf("Y speed: " .. player.velocity.speedY, 20, 40, 1000, "left")
	love.graphics.printf("X speed: " .. player.velocity.speedX, 20, 50, 1000, "left")
end
