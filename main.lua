require "room"
require "enemies"
require "player"
require "items"
require "helper_functions"
require "tile"
local constants = require "constants"
local anim8 = require "anim8/anim8"

-- Window Initialization

screen = { width = 800, height = 480, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = true, vsync = true, minwidth = 800, minheight= 480 , fullscreen=false })
love.window.setTitle( "Generic Planet Mover and Attractor" )
keyboard_or_controller = false
editor_mode = true
vertical_draw_scale = 1
horisontal_draw_scale = 1

-- Value Initialization

tileTypes = {}

entities = {
	player = Player:new(20, 20, 20, 20, "Assets/BILD1321.png", 0.013, 0.013),
	enemies = {},
	blocks = {},
	animations = {},
	tileTypes = {},
	tiles = {}
}

game_speed = 1
in_focus = false

function hide_cursor()
	cursor = love.mouse.newCursor("Assets/empty_cursor.png")
	love.mouse.setCursor(cursor)
end

function love.load()
	--background = love.graphics.newImage("Assets/background.jpg")
	hide_cursor()
	table.insert(tileTypes, Tile:newType("Assets/grass2.png", 1, 1, true))
	love.graphics.setBackgroundColor( 0, 0, 25 )
	--boundaries
	table.insert(entities.tiles, Tile:newTile( -1, 0, 1, screen.height, 1))
	table.insert(entities.tiles, Tile:newTile( 0, -1, screen.width, 1, 1))
	table.insert(entities.tiles, Tile:newTile( screen.width, 0, 1, screen.height, 1))
	table.insert(entities.tiles, Tile:newTile( 0, screen.height, screen.width, 1, 1))
	-- highest level

	table.insert(entities.tiles, Tile:newTile( 150, 280, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 250, 280, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 350, 280, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 450, 280, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 550, 280, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 650, 280, 32, 32, 1))


	table.insert(entities.tiles, Tile:newTile( 100, 350, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 200, 350, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 300, 350, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 400, 350, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 500, 350, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 600, 350, 32, 32, 1))


	-- lowest level
	table.insert(entities.tiles, Tile:newTile( 150, 420, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 250, 420, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 350, 420, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 450, 420, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 550, 420, 32, 32, 1))
	table.insert(entities.tiles, Tile:newTile( 650, 420, 32, 32, 1))

	for i = 1, 400 do
		table.insert(entities.enemies, Grunt:new(10*i , 5*i))
	end

	cursor_image = love.graphics.newImage("Assets/Cursor.png")
	local g = anim8.newGrid(32, 32, cursor_image:getWidth(), cursor_image:getHeight())
	table.insert(entities.animations, anim8.newAnimation(g('1-2',1), 0.5))

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
		local exploding, time_rising = entities.player:handleInput(delta_time, game_speed, 1)
	else 
		mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed = entities.player:handleInput(delta_time, game_speed, 3)
		entities.player.position.x = mouse_x / horisontal_draw_scale
		entities.player.position.y = mouse_y / vertical_draw_scale
	end

	handle_mouse_editor(mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed)

	entities.player:handleMovementLogic(entities)

	for i = #entities.enemies, 1, -1 do
		entities.enemies[i]:update(delta_time, entities.player, game_speed)
		--if check_collision(entities.player, entities.enemies[i]) then
		--	table.remove(entities.enemies, i)
		--end
	end

	for i = 1, #entities.animations, 1 do
		entities.animations[i]:update(delta_time)
	end
end

memory_usage = 0
last_memory_check = love.timer.getTime()

function love.draw()
	entities_drawn = 0
	-- Draw Room
	--love.graphics.draw(background)
	if editor_mode then
		print("Editor mode")
		render_screen_editor()
	else
		print("Play mode")
		render_screen()
	end
	-- HUD
	print_HUD()
end

function render_screen()
	-- camera offset in regards to player
	local x_offset = (entities.player.position.x - (screen.width / 2))
	local y_offset = (entities.player.position.y - (screen.height / 2))

	local camera_rectangle = { 
		position =  {
			x = x_offset,
			y = y_offset
		},
		width = screen.width,
		height = screen.height
	}

	-- Draw blocks
	for i = #entities.tiles, 1, -1 do
		local tile = entities.tiles[i];
		--love.graphics.draw(block.image, block.x, block.y, 0, 0, 0, 0, 0, 0, 0)
		if check_collision(tile, camera_rectangle) then
			draw_tile(tile, x_offset, y_offset)
			entities_drawn = entities_drawn + 1
		end
	end

	-- Draw Items

	-- Draw player
	drawRect(entities.player, x_offset, y_offset)
	draw_sprite(entities.player, x_offset, y_offset)

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		if check_collision(enemy, camera_rectangle) then
			drawRect(enemy, x_offset, y_offset)
			entities_drawn = entities_drawn + 1
		end
	end

	if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() then
		editor_mode = not editor_mode
		next_rendering_switch = love.timer.getTime() + 1
		keyboard_or_controller = false
	end
end

function render_screen_editor()
	-- Draw blocks
	for i = #entities.tiles, 1, -1 do
		local tile = entities.tiles[i];
		draw_tile(tile, 0, 0)
		entities_drawn = entities_drawn + 1
	end

	-- Draw cursor

	local x, y = love.mouse.getX(), love.mouse.getY()
	x = x - (x % 32)
	y = y - (y % 32)

	for i = 1, #entities.animations, 1 do
		entities.animations[i]:draw(cursor_image, x, y, 0, horisontal_draw_scale, vertical_draw_scale)
	end 
	-- Draw Items

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		drawRect(enemy, 0, 0)
		entities_drawn = entities_drawn + 1
		drawRect( { position = { x = love.mouse.getX() / horisontal_draw_scale, y = love.mouse.getY() / vertical_draw_scale }, width = 5, height = 5 }, 0, 0)
	end

	if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() then
		editor_mode = not editor_mode
		next_rendering_switch = love.timer.getTime() + 1
		keyboard_or_controller = true
	end
end

function handle_mouse_editor(x, y, left, right)
	if left and next_block_interaction < love.timer.getTime() then
		local occupied_space = false
		for i = 1, #entities.tiles do
			if check_collision(entities.tiles[i], { position = { x = (x - (x % 32)), y = (y - (y % 32)) }, width = 32, height = 32 }) then
				occupied_space = true
			end
		end
		if not occupied_space then
			table.insert(entities.tiles, Tile:newTile((x - (x % 32)), (y - (y % 32)), 32, 32, 1))
			next_block_interaction = love.timer.getTime() + .1
		end
	end

	if right and next_block_interaction < love.timer.getTime() then
		for i = #entities.tiles, 1, -1 do
			if check_collision(entities.tiles[i], { position = { x = (x - (x % 32)), y = (y - (y % 32)) }, width = 1, height = 1 }) then
				table.remove(entities.tiles, i)
			end
		end
	end
end

function draw_tile(tile, x_offset, y_offset)
	love.graphics.draw(tileTypes[tile.kind].sprite.sprite, (tile.position.x - x_offset) * horisontal_draw_scale, (tile.position.y - y_offset) * vertical_draw_scale, 0, 1, 1)
end

function draw_sprite(entity, x_offset, y_offset)
	love.graphics.draw(entity.sprite.sprite, (entities.player.position.x - x_offset) * horisontal_draw_scale, (entities.player.position.y - y_offset) * vertical_draw_scale, 0, 0.013, 0.013)
end

function drawRect(entity, x_offset, y_offset)
	love.graphics.rectangle("fill", (entity.position.x - x_offset) * horisontal_draw_scale, vertical_draw_scale * (entity.position.y - y_offset), entity.width * horisontal_draw_scale, entity.height * vertical_draw_scale)
end

function print_HUD()
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
