require("room")
require("enemies")
require("player")
require("items")

-- Window Initialization

player = Player:new(nil, 0, 0, 20, 20, nil)

screen = { width = 1440, height = 900, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = false, vsync = true, minwidth = 800, minheight=600, fullscreen=false })
love.window.setTitle( "Generic Space Shooter" )

function love.load()
	love.graphics.setBackgroundColor( 0, 0, 25 )
end

function love.update(delta_time)
	player:handleInput(delta_time)
end

function love.draw()
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end