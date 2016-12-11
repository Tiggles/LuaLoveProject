require "room"
require "enemies"
require "player"
require "items"
local constants = require "constants"
require "helperFunctions"
-- Window Initialization

screen = { width = 800, height = 600, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = false, vsync = true, minwidth = 800, minheight=600, fullscreen=false })
love.window.setTitle( "Generic Planet Mover" )

-- Value Initialization

player = Player:new(nil, 0, 0, 20, 20, nil)
enemies = {}
game_speed = 1

function love.load()
	player.image = love.graphics.newImage("BILD1321.png")
	background = love.graphics.newImage("background.jpg")
	love.graphics.setBackgroundColor( 0, 0, 25 )
	for i=1,400 do
		table.insert(enemies, Grunt:new(10*i , 5*i))
	end
end

function love.update(delta_time)
	local explode, time_rising = player:handleInput(delta_time)
	table.insert(enemies, Grunt:new(400, 1500))
	game_speed = updateGameSpeed(game_speed, delta_time, time_rising)
	if explode then
		for i = #enemies, 1, -1 do
			if enemies[i].x > player.x then
				enemies[i].acceleration.speedX = enemies[i].acceleration.speedX + 10 * delta_time * game_speed
			else
				enemies[i].acceleration.speedX = enemies[i].acceleration.speedX - 10 * delta_time * game_speed
			end
			if enemies[i].y > player.y then
				enemies[i].acceleration.speedY = enemies[i].acceleration.speedY + 10 * delta_time * game_speed
			else
				enemies[i].acceleration.speedY = enemies[i].acceleration.speedY - 10 * delta_time * game_speed
			end
		end	
	end
	for i = #enemies, 1, -1 do
		enemies[i]:update(delta_time, player, game_speed)
	end 
end

function love.draw()
	-- Draw Room
	love.graphics.draw(background)
	-- Draw Items
	-- Draw player
	love.graphics.draw(player.image, player.x, player.y, 0, 0.01, 0.01, player.width / 2, player.height / 2, 0, 0)
	--love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
	-- Draw enemies
	for i = #enemies, 1, -1 do
		local enemy = enemies[i]
		love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
	end

	-- HUD
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 20, 10, 1000, "left" )
	love.graphics.printf("Particles: " .. #enemies, 20, 20, 1000, "left" )
	love.graphics.printf("Time: " .. game_speed, 20, 30, 1000, "left" )
end