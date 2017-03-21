require "room"
require "enemies"
require "player"
require "items"
require "helper_functions"
require "tile"
require "event"
local constants = require "constants"
local anim8 = require "anim8/anim8"
require "scoring"

-- Window Initialization

screen = { width = 800, height = 480, flags = nil}
love.window.setMode( screen.width, screen.height, { resizable = true, vsync = true, minwidth = 800, minheight= 480 , fullscreen = false })
love.window.setTitle( "Generic Planet Mover and Attractor" )
keyboard_or_controller = false
editor_mode = true
last_tile_change = love.timer.getTime()
vertical_draw_scale = 1
horisontal_draw_scale = 1
LUA_INDEX_OFFSET = 1
tile_index = 0 -- Start at first index
debug = true

-- Value Initialization

entities = {
	player = Player:new(20, 20, 20, 20, "Assets/BILD1321.png", 0.013, 0.013),
	enemies = {},
	blocks = {},
	animations = {},
	editorTypes = {},
	tiles = {},
	collectibles = {},
	event_tiles = {}
}

game_speed = 1
in_focus = false
tile_frame = TileType:newType("Assets/tileframe.png", 0.8, 0.8, 70, 70, false)

function hide_cursor()
	cursor = love.mouse.newCursor("Assets/empty_cursor.png")
	love.mouse.setCursor(cursor)
end

function love.load()
	--background = love.graphics.newImage("Assets/background.jpg")

	Score:setupTimer(0)
    Score:setupScoreCount(0)
    Score:setupMultiplier()

	hide_cursor()
	table.insert(entities.editorTypes, TileType:newType("Assets/grass2.png", 1, 1, 32, 32, true))
	table.insert(entities.editorTypes, TileType:newType("Assets/BILD1321.png", 0.02, 0.02, 32, 32, false))
	table.insert(entities.editorTypes, CollectibleType:newType("Assets/coin.png", 0.5, 0.5, 32, 32, false))
	table.insert(entities.editorTypes, EventType:newType("Assets/start.png", 0.5, 0.5, 32, 32, false, kinds.start))
	table.insert(entities.editorTypes, EventType:newType("Assets/end.png", 0.5, 0.5, 32, 32, false, kinds.finish))

	entities.player.collected_coins = 0

	love.graphics.setBackgroundColor( 0, 0, 25 )
	--boundaries
	for i = 0, 24, 1 do
		table.insert(entities.tiles, Tile:newTile(32 * i, -32, 1))
		table.insert(entities.tiles, Tile:newTile(32 * i, screen.height, 1))
	end

	for i = 0, 14, 1 do
		table.insert(entities.tiles, Tile:newTile(-32, 32 * i, 1))
		table.insert(entities.tiles, Tile:newTile(screen.width, 32 * i, 1))
	end
	-- highest level

	init_tiles_frame(entities.tiles)

	for i = 1, 400 do
		table.insert(entities.enemies, Grunt:new(10*i , 5*i))
	end

	cursor_image = love.graphics.newImage("Assets/Cursor.png")
	local g = anim8.newGrid(32, 32, cursor_image:getWidth(), cursor_image:getHeight())
	table.insert(entities.animations, anim8.newAnimation(g('1-2', 1), 0.5))

	coin_image = love.graphics.newImage("Assets/coin.png")
	local h = anim8.newGrid(64, 64, coin_image:getWidth(), coin_image:getHeight())
	table.insert(entities.animations, anim8.newAnimation(h('1-64', 1), 0.02))

	exit_image = love.graphics.newImage("Assets/exit_portal.png")
	local ep = anim8.newGrid(64, 64, exit_image:getWidth(), exit_image:getHeight())
	table.insert(entities.animations, anim8.newAnimation(ep('1-13', 1), 0.2))


	current_item = entities.editorTypes[tile_index + LUA_INDEX_OFFSET]
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

    Score:updateTimer(delta_time)
    Score:updateScoreCount(delta_time)
	local mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed
	game_speed = update_gameSpeed(game_speed, delta_time, time_rising)

	if not in_focus then return end

	if keyboard_or_controller then
		local exploding, time_rising = entities.player:handleInput(delta_time, game_speed, 0)
	else 
		mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed, q, e = entities.player:handleInput(delta_time, game_speed, 2)
		entities.player.position.x = mouse_x / horisontal_draw_scale
		entities.player.position.y = mouse_y / vertical_draw_scale
	end

	handle_mouse_editor(mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed)

	entities.player:handleMovementLogic(entities)

	if q and love.timer.getTime() > last_tile_change + 0.2 then
		last_tile_change = love.timer.getTime()
		tile_index = (tile_index - 1) % #entities.editorTypes;
	end
	if e and love.timer.getTime() > last_tile_change + 0.2 then
		last_tile_change = love.timer.getTime()
		tile_index = (tile_index + 1) % #entities.editorTypes;
	end

	current_item = entities.editorTypes[ tile_index + LUA_INDEX_OFFSET ]

	for i = #entities.enemies, 1, -1 do
		entities.enemies[i]:update(delta_time, entities.player, game_speed)
		if check_collision(entities.enemies[i], entities.player) then
			table.remove(entities.enemies, i)
		end
	end

	if editor_mode == false then
		for i = #game_coins, 1, -1 do
			local collectible = game_coins[i]
			local kind = entities.editorTypes[collectible.kind]
			if (check_collision( { position = collectible.position, width = kind.width, height = kind.height }, entities.player)) then
				table.remove(game_coins, i)
				entities.player.collected_coins = entities.player.collected_coins + 1
				Score:addToMultiplier(1)
				Score:pushScore(100)
			end
		end
		local exit = entities.event_tiles[2]
		if check_collision( { position = exit.position, width = entities.editorTypes[exit.kind].width, height = entities.editorTypes[exit.kind].height }, entities.player) then
			editor_mode = true
		end
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
		render_screen_editor()
	else
		render_screen()
	end

	love.graphics.translate(0,0)

	Score:drawTimer()
    Score:drawScoreCount()
	Score:drawMultiplier()
	-- HUD
	-- print_DEBUG()
end

function render_screen()
	-- camera offset in regards to player
	local x_offset = (entities.player.position.x - (screen.width / 2))
	local y_offset = (entities.player.position.y - (screen.height / 2))

	love.graphics.translate(-x_offset * horisontal_draw_scale, -y_offset * vertical_draw_scale)

	local camera_rectangle = { 
		position =  {
			x = x_offset,
			y = y_offset
		},
		width = screen.width,
		height = screen.height
	}

	-- Draw tiles
	for i = #entities.tiles, 1, -1 do
		local tile = entities.tiles[i];
		local kind = entities.editorTypes[tile.kind]
		local collision_block = { position = tile.position, width = tile_kind.width, height = tile_kind.height }
		if check_collision(collision_block, camera_rectangle) then
			draw_tile(tile)
			entities_drawn = entities_drawn + 1
		end
	end

	-- Draw objects

	-- Draw Items
	for i = #game_coins, 1, -1 do
		local collectible = game_coins[i]
		local kind = entities.editorTypes[collectible.kind]
		local collision_block = { position = collectible.position, width = kind.width, height = kind.height }
		if check_collision(collision_block, camera_rectangle) then
			entities.animations[2]:draw(coin_image, collectible.position.x * horisontal_draw_scale, collectible.position.y * vertical_draw_scale, 0, horisontal_draw_scale * kind.scale_x, vertical_draw_scale * kind.scale_y)
			entities_drawn = entities_drawn + 1
		end
	end

	-- Render exit

	entities.animations[3]:draw(exit_image, entities.event_tiles[2].position.x * horisontal_draw_scale, entities.event_tiles[2].position.y * vertical_draw_scale, 0, entities.editorTypes[5].scale_x * horisontal_draw_scale, entities.editorTypes[5].scale_y * vertical_draw_scale)

	-- Draw player
	draw_rect(entities.player)
	draw_sprite(entities.player)

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		if check_collision(enemy, camera_rectangle) then
			draw_rect(enemy)
			entities_drawn = entities_drawn + 1
		end
	end

	if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() then
		editor_mode = not editor_mode
		next_rendering_switch = love.timer.getTime() + 1
		keyboard_or_controller = false
	end

	love.graphics.translate(x_offset * horisontal_draw_scale, y_offset * vertical_draw_scale)	
end

function render_screen_editor()
	-- Draw blocks
	for i = #entities.tiles, 1, -1 do
		local tile = entities.tiles[i];
		draw_tile(tile)
		entities_drawn = entities_drawn + 1
	end

	for i = #entities.collectibles, 1, -1 do
		local collectible = entities.collectibles[i];
		local kind = entities.editorTypes[collectible.kind]
		entities.animations[2]:draw(coin_image, collectible.position.x * horisontal_draw_scale, collectible.position.y * vertical_draw_scale, 0, horisontal_draw_scale * kind.scale_x, vertical_draw_scale * kind.scale_y)
		entities_drawn = entities_drawn + 1
	end

	for i = #entities.event_tiles, 1, -1 do
		local event = entities.event_tiles[i];
		draw_tile(event)
		entities_drawn = entities_drawn + 1
	end

	-- Draw cursor

	-- Draw Items

	-- Draw enemies
	for i = #entities.enemies, 1, -1 do
		local enemy = entities.enemies[i]
		draw_rect(enemy)
		entities_drawn = entities_drawn + 1
	end



	-- Render current block
	love.graphics.draw(tile_frame.sprite.sprite, 10 * horisontal_draw_scale, 170 * vertical_draw_scale, 0, tile_frame.scale_x * horisontal_draw_scale, tile_frame.scale_y * vertical_draw_scale)
	love.graphics.draw(entities.editorTypes[tile_index + LUA_INDEX_OFFSET].sprite.sprite, 22 * horisontal_draw_scale, 182 * vertical_draw_scale, 0, entities.editorTypes[tile_index + LUA_INDEX_OFFSET].scale_x * horisontal_draw_scale, entities.editorTypes[tile_index + LUA_INDEX_OFFSET].scale_y * vertical_draw_scale)

	draw_rect( { position = { x = love.mouse.getX() / horisontal_draw_scale, y = love.mouse.getY() / vertical_draw_scale}, width = 5, height = 5  })
	
	if love.keyboard.isDown("escape") then
		love.event.quit();
	end
	
	if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() and #entities.event_tiles == 2 then
		editor_mode = not editor_mode
		next_rendering_switch = love.timer.getTime() + 1
		entities.player.position.x = entities.event_tiles[1].position.x
		entities.player.position.y = entities.event_tiles[1].position.y
		game_coins = table_clone(entities.collectibles)
		keyboard_or_controller = true
	end

	if #entities.tiles > 108 then
		for i = 1, #entities.tiles do
			print("x: " .. entities.tiles[i].position.x .. ", y: " .. entities.tiles[i].position.y )
			love.event.quit()
		end
	end
end

function handle_mouse_editor(x, y, left, right)
	local x, y = love.mouse.getX() / horisontal_draw_scale, love.mouse.getY() / vertical_draw_scale
	if left and next_block_interaction < love.timer.getTime() then
		local occupied_space = false
		for i = 1, #entities.tiles do
			local tile = entities.tiles[i]
			local kind = entities.editorTypes[tile.kind]
			local collision_block = { position = tile.position, width = kind.width, height = kind.height }
			if check_collision(collision_block, { position = { x = x, y = y }, width = 1, height = 1 }) then
				occupied_space = true
			end
		end

		for i = 1, #entities.collectibles do
			local collectible = entities.collectibles[i]
			local kind = entities.editorTypes[collectible.kind]
			local collision_block = { position = collectible.position, width = kind.width, height = kind.height }
			if check_collision(collision_block, { position = { x = x, y = y }, width = 1, height = 1 }) then
				occupied_space = true
			end
		end
		if not occupied_space then
			local editor_type = entities.editorTypes[ tile_index + LUA_INDEX_OFFSET ]
			if editor_type.kind_type == constants.editor_constants.tile then
				table.insert(entities.tiles, Tile:newTile((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET))
				table.sort( entities.tiles, compare )
			elseif editor_type.kind_type == constants.editor_constants.collectible then
				table.insert(entities.collectibles, Collectible:newCollectible((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET))
			elseif editor_type.kind_type == constants.editor_constants.event then
				if editor_type.event_type == kinds.start then
					entities.event_tiles[kinds.start] = Event:newEvent((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET)
				elseif editor_type.event_type == kinds.finish then
					entities.event_tiles[kinds.finish] = Event:newEvent((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET)
				end
			end
			next_block_interaction = love.timer.getTime() + .1
		end
	end

	if right and next_block_interaction < love.timer.getTime() then
		for i = #entities.tiles, 1, -1 do
			local tile = entities.tiles[i]
			local kind = entities.editorTypes[tile.kind]
			if check_collision({ position = tile.position, width = kind.width, height = kind.height }, { position = { x = x, y = y }, width = 1, height = 1 }) then
				table.remove(entities.tiles, i)
				return
			end
		end
		for i = #entities.collectibles, 1, -1 do
			local collectible = entities.collectibles[i]
			local kind = entities.editorTypes[collectible.kind]
			if check_collision({ position = collectible.position, width = kind.width, height = kind.height }, { position = { x = x, y = y }, width = 1, height = 1 }) then
				table.remove(entities.collectibles, i)
				return
			end
		end
	end
end

function draw_tile(tile)
	love.graphics.draw(entities.editorTypes[tile.kind].sprite.sprite, (tile.position.x) * horisontal_draw_scale, (tile.position.y) * vertical_draw_scale, 0, entities.editorTypes[tile.kind].scale_x * horisontal_draw_scale, entities.editorTypes[tile.kind].scale_y * vertical_draw_scale)
end

function draw_sprite(entity)
	love.graphics.draw(entity.sprite.sprite, (entities.player.position.x) * horisontal_draw_scale, (entities.player.position.y) * vertical_draw_scale, 0, entity.sprite.scale_factor_x * horisontal_draw_scale, entity.sprite.scale_factor_y * vertical_draw_scale)
end

function draw_rect(entity, x_offset, y_offset)
	love.graphics.rectangle("fill", (entity.position.x) * horisontal_draw_scale, vertical_draw_scale * (entity.position.y), entity.width * horisontal_draw_scale, entity.height * vertical_draw_scale)
end

function print_DEBUG()
	--love.graphics.translate(entities.player.position.x, entities.player.position.y)
	if not debug then return end
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
	love.graphics.printf("Collected coins " .. entities.player.collected_coins, 20, 100, 1000, "left")
	love.graphics.printf("Current multiplier: " .. entities.player.currentMultiplier, 20, 110, 1000, "left")
end

function compare(a, b)
	if a.position.y < b.position.y then return true end
	if a.position.y > b.position.y then return false end
	return a.position.x < b.position.x
	 
end

