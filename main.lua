require "room"
require "enemies"
require "player"
require "items"
local constants = require "constants"
require "helperFunctions"
-- Window Initialization

screen = { width = 1440, height = 900, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = false, vsync = true, minwidth = 800, minheight=600, fullscreen=false })
love.window.setTitle( "Generic Space Shooter" )

-- Character Initialization

player = Player:new(nil, 0, 0, 20, 20, nil)
enemies = {}

function love.load()
	love.graphics.setBackgroundColor( 0, 0, 25 )
	table.insert(enemies, Grunt:new(50, 50, 25, 25))
end

function love.update(delta_time)
	player:handleInput(delta_time)
	for i = #enemies, 1, -1 do
		enemies[i]:update(delta_time, player)
		local hit = checkCollision(enemies[i], player)
		print(hit)
	end 
end

function love.draw()
	-- Draw Room
	-- Draw Items
	-- Draw player
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
	-- Draw enemies
	for i = #enemies, 1, -1 do
		local enemy = enemies[i]
		love.graphics.rectangle("fill", enemy.x, enemy.y, 25, 25)
	end 
end