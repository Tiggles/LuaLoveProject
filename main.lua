require "room"
require "enemies"
require "player"
require "items"
require "helper_functions"

-- Window Initialization

screen = { width = 800, height = 600, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = false, vsync = true, minwidth = 800, minheight=600, fullscreen=false })
love.window.setTitle( "Generic Planet Mover and Attractor" )
keyboard_or_controller = false
draw_with_offset = false

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

	next_block_insert = love.timer.getTime()
	next_rendering_switch = love.timer.getTime()
end

function love.focus(focus)
	in_focus = focus
end

function love.update(delta_time)

	game_speed = update_gameSpeed(game_speed, delta_time, time_rising)

	if not in_focus then return end

	if keyboard_or_controller then
		local explode, time_rising = entities.player:handleInput(delta_time, game_speed, 1)
	else 
		mouse_x, mouse_y, left_mouse_button_pressed = entities.player:handleInput(delta_time, game_speed, 3)
		entities.player.position.x = mouse_x
		entities.player.position.y = mouse_y
	end

	if left_mouse_button_pressed and next_block_insert < love.timer.getTime() then
		for i=1, #entities.blocks do
			if check_collision(entities.blocks[i], { position = { x = mouse_x, y = mouse_y }, width = 20, height = 20 }) then
				break;
			end
		end
		table.insert(entities.blocks, Block:newRock(mouse_x, mouse_y, 20, 20))
		next_block_insert = love.timer.getTime() + 1
	end

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
	entities_drawn = 0
	-- Draw Room
	love.graphics.draw(background)

	if draw_with_offset then
		render_screen_with_offset()
	else
		render_screen_without_offset()
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
	love.graphics.printf("Entities drawn " .. entities_drawn, 20, 90, 1000, "left")
	if last_memory_check + 1 < love.timer.getTime() then
		memory_usage = collectgarbage("count")
		last_memory_check = love.timer.getTime()
	end
end

function render_screen_with_offset()
	-- camera offset in regards to player
	local x_offset = (entities.player.position.x - (screen.width / 2) + entities.player.width / 2)
	local y_offset = (entities.player.position.y - (screen.height / 2) + entities.player.height / 2)

	local camera_rectangle = { 
		position =  {
			x = entities.player.position.x - screen.width / 2,
			y = entities.player.position.y - screen.height / 2
		},
		width = screen.width,
		height = screen.height
	}

	-- Draw blocks
	for i = #entities.blocks, 1, -1 do
		local block = entities.blocks[i];
		--love.graphics.draw(block.image, block.x, block.y, 0, 0, 0, 0, 0, 0, 0)
		if check_collision(camera_rectangle, camera_rectangle) then
			drawRectWithOffset(block, x_offset, y_offset)
			entities_drawn = entities_drawn + 1
		end
	end

	-- Draw Items

	-- Draw player
	love.graphics.rectangle("fill", entities.player.position.x - x_offset, entities.player.position.y - y_offset, entities.player.width, entities.player.height)
	love.graphics.draw(entities.player.sprite.sprite, entities.player.position.x - x_offset, entities.player.position.y - y_offset, 0, 0.013, 0.013, entities.player.width / 2, entities.player.height / 2, 0, 0)

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		if check_collision(enemy, camera_rectangle) then
			drawRectWithOffset(enemy, x_offset, y_offset)
			entities_drawn = entities_drawn + 1
		end
	end

	if love.mouse.isDown(2) and next_rendering_switch < love.timer.getTime() then
		draw_with_offset = not draw_with_offset
		next_rendering_switch = love.timer.getTime() + 1
		keyboard_or_controller = false
	end
end

function render_screen_without_offset()
	-- Draw blocks
	for i = #entities.blocks, 1, -1 do
		local block = entities.blocks[i];
		--love.graphics.draw(block.image, block.x, block.y, 0, 0, 0, 0, 0, 0, 0)
		drawRectWithoutOffset(block)
		entities_drawn = entities_drawn + 1
	end

	-- Draw Items

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		drawRectWithoutOffset(enemy)
		entities_drawn = entities_drawn + 1
	end

	if love.mouse.isDown(2) and next_rendering_switch < love.timer.getTime() then
		draw_with_offset = true
		next_rendering_switch = love.timer.getTime() + 1
		keyboard_or_controller = true
	end
end

function drawRectWithOffset(entity, x_offset, y_offset)
	love.graphics.rectangle("fill", entity.position.x - x_offset, entity.position.y - y_offset, entity.width, entity.height)
end

function drawRectWithoutOffset(entity)
	love.graphics.rectangle("fill", entity.position.x, entity.position.y, entity.width, entity.height)
end