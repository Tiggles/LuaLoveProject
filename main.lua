require "room"
require "enemies"
require "player"
require "items"
require "helper_functions"

-- Window Initialization

screen = { width = 800, height = 600, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = true, vsync = true, minwidth = 800, minheight=600, fullscreen=false })
love.window.setTitle( "Generic Planet Mover and Attractor" )
keyboard_or_controller = false
draw_with_offset = false
vertical_draw_scale = 1
horisontal_draw_scale = 1

-- Value Initialization

local constants = require "constants"

entities = {
	player = Player:new(20, 20, 20, 20, "Assets/BILD1321.png", 0.013, 0.013),
	enemies = {},
	blocks = {}
}

game_speed = 1
in_focus = false

function love.load()
	--background = love.graphics.newImage("Assets/background.jpg")
	love.graphics.setBackgroundColor( 0, 0, 25 )
	--boundaries
	table.insert(entities.blocks, Block:newRock( -1, 0, 1, screen.height))
	table.insert(entities.blocks, Block:newRock( 0, -1, screen.width, 1))
	table.insert(entities.blocks, Block:newRock( 800, 0, 1, 600))
	table.insert(entities.blocks, Block:newRock( 0, 600, 800, 1))
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

	for i = 1, 400 do
		table.insert(entities.enemies, Grunt:new(10*i , 5*i))
	end

	next_block_interaction = love.timer.getTime()
	next_rendering_switch = love.timer.getTime()
end

function love.focus(focus)
	in_focus = focus
end

function love.resize(width, height)
	horisontal_draw_scale = width / screen.width
	vertical_draw_scale = height / screen.height
end

function love.update(delta_time)

	local mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed
	game_speed = update_gameSpeed(game_speed, delta_time, time_rising)

	if not in_focus then return end

	if keyboard_or_controller then
		local explode, time_rising = entities.player:handleInput(delta_time, game_speed, 1)
	else 
		mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed = entities.player:handleInput(delta_time, game_speed, 3)
		entities.player.position.x = mouse_x / horisontal_draw_scale
		entities.player.position.y = mouse_y / vertical_draw_scale
	end

	handle_mouse_editor(mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed)

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
	--love.graphics.draw(background)

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
	if keyboard_or_controller then
		love.graphics.printf("Arrow keys for movement, space to jump", screen.width - 255, 10, 1000, "left")
	else
		love.graphics.printf("Left button to add, right to remove,", screen.width - 255, 10, 1000, "left")
	end
	love.graphics.printf("'i' to swap state", screen.width - 255, 20, 1000, "left")
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
	drawRectWithOffset(entities.player, x_offset, y_offset)
	draw_sprite_with_offset(entities.player, x_offset, y_offset)

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		if check_collision(enemy, camera_rectangle) then
			drawRectWithOffset(enemy, x_offset, y_offset)
			entities_drawn = entities_drawn + 1
		end
	end

	if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() then
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

	if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() then
		draw_with_offset = true
		next_rendering_switch = love.timer.getTime() + 1
		keyboard_or_controller = true
	end
end

function handle_mouse_editor(x, y, left, right)
	if left and next_block_interaction < love.timer.getTime() then
		local occupied_space = false
		for i = 1, #entities.blocks do
			if check_collision(entities.blocks[i], { position = { x = (x - (x % 10)) / horisontal_draw_scale, y = (y - (y % 10)) / vertical_draw_scale }, width = 20, height = 20 }) then
				occupied_space = true
			end
		end
		if not occupied_space then
			table.insert(entities.blocks, Block:newRock((x - (x % 10)) / horisontal_draw_scale, (y - (y % 10)) / vertical_draw_scale, 20, 20))
			next_block_interaction = love.timer.getTime() + .1
		end
	end

	if right and next_block_interaction < love.timer.getTime() then
		for i = #entities.blocks, 1, -1 do
			if check_collision(entities.blocks[i], { position = { x = (x - (x % 10)) / horisontal_draw_scale, y = (y - (y % 10)) / vertical_draw_scale }, width = 1, height = 1 }) then
				table.remove(entities.blocks, i)
			end
		end
	end
end

function draw_sprite_with_offset(entity, x_offset, y_offset)
	love.graphics.draw(entity.sprite.sprite, (entities.player.position.x - x_offset) * horisontal_draw_scale, (entities.player.position.y - y_offset) * vertical_draw_scale, 0, 0.013, 0.013, entity.width / 2, entity.height / 2, 0, 0)
end

function drawRectWithOffset(entity, x_offset, y_offset)
	love.graphics.rectangle("fill", (entity.position.x - x_offset) * horisontal_draw_scale, vertical_draw_scale * (entity.position.y - y_offset), entity.width * horisontal_draw_scale, entity.height * vertical_draw_scale)
end

function drawRectWithoutOffset(entity)
	love.graphics.rectangle("fill", entity.position.x * horisontal_draw_scale, vertical_draw_scale * entity.position.y, entity.width * horisontal_draw_scale, entity.height * vertical_draw_scale)
end