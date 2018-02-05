require "room"
require "enemies"
require "editor"
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
love.window.setTitle( "Editor" )
keyboard_or_controller = false
editor_mode = true
last_tile_change = love.timer.getTime()
vertical_draw_scale = 1
horisontal_draw_scale = 1
LUA_INDEX_OFFSET = 1
tile_index = 0
debug = true
editor = Editor:new()

-- Value Initialization
game_speed = 1.0
in_focus = false
tile_frame = TileType:newType("Assets/tileframe.png", 0.8, 0.8, 70, 70, false)

function love.load(args)
    entities = init_entities()
    read_level(args[2])

	
	editor:addTileType("Assets/grass1.png", 1, 1, 32, 32, false)
	editor:addTileType("Assets/grass2.png", 1, 1, 32, 32, false)
	editor:addTileType("Assets/bricksred.png", 1, 1, 32, 32, true)
	editor:addTileType("Assets/bricksgray.png", 1, 1, 32, 32, true)
	editor:addTileType("Assets/BILD1321.png", 0.02, 0.02, 32, 32, false)
	editor:addCollectibleType("Assets/coin.png", 0.5, 0.5, 32, 32, false)
	editor:addEventType("Assets/start.png", 0.5, 0.5, 32, 32, false, kinds.start)
	editor:addEventType("Assets/end.png", 0.5, 0.5, 32, 32, false, kinds.finish)
	editor:addActorType("Assets/cannonfodder.png", 0.5, 0.5, 32, 32)

	love.graphics.setBackgroundColor( 65, 75, 25 )

	coin_image = love.graphics.newImage("Assets/coin.png")
	local h = anim8.newGrid(64, 64, coin_image:getWidth(), coin_image:getHeight())
	table.insert(entities.animations, anim8.newAnimation(h('1-64', 1), 0.02))

	exit_image = love.graphics.newImage("Assets/exit_portal.png")
	local ep = anim8.newGrid(64, 64, exit_image:getWidth(), exit_image:getHeight())
	table.insert(entities.animations, anim8.newAnimation(ep('1-13', 1), 0.2))



	cannonfodder_image = love.graphics.newImage("Assets/cannonfodder.png")

	current_item = entities.editorTypes[tile_index + LUA_INDEX_OFFSET]
	next_block_interaction = love.timer.getTime()
	next_rendering_switch = love.timer.getTime()
	--save_level("level.example")
end

function love.focus(focus)
	in_focus = focus
end

function love.resize(width, height)
	horisontal_draw_scale = width / screen.width
	vertical_draw_scale = height / screen.height
end

function love.update(delta_time)
	if not in_focus then return end
	editor_update(delta_time, editor)
	game_speed = update_gameSpeed(game_speed, delta_time, time_rising)
	
	if keyboard_or_controller then
		local exploding, time_rising = entities.player:handleInput(delta_time, game_speed, 0)
		Score:updateTimer(delta_time)
		Score:updateScoreCount()
	else
		mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed, q, e = entities.player:handleInput(delta_time, game_speed, 2)
		entities.player.position.x = mouse_x / horisontal_draw_scale
		entities.player.position.y = mouse_y / vertical_draw_scale
	end

	entities.player:handleMovementLogic(entities)

	local direction = 0
	if q then direction = direction - 1	end
	if e then direction = direction + 1 end
	editor:changeIndex(direction)

	current_item = entities.editorTypes[ tile_index + LUA_INDEX_OFFSET ]

	if editor_mode == false then
		for i = #game_coins, 1, -1 do
		local collectible = game_coins[i]
		local kind = entities.editorTypes[collectible.kind]
			if (check_collision( { position = collectible.position, width = kind.width, height = kind.height }, entities.player)) then
				table.remove(game_coins, i)
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
	if editor_mode then
		editor_draw(editor)
	else
		render_screen()
	end
	if editor_mode == false then
		Score:drawTimer()
    	Score:drawScoreCount()
		Score:drawMultiplier()
	end
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
		end
	end

	-- Render exit

	entities.animations[3]:draw(exit_image, entities.event_tiles[2].position.x * horisontal_draw_scale, entities.event_tiles[2].position.y * vertical_draw_scale, 0, entities.editorTypes[8].scale_x * horisontal_draw_scale, entities.editorTypes[8].scale_y * vertical_draw_scale)

	-- Draw player
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


function draw_tile(tile)
	love.graphics.draw(entities.editorTypes[tile.kind].sprite.sprite, (tile.position.x) * horisontal_draw_scale, (tile.position.y) * vertical_draw_scale, 0, entities.editorTypes[tile.kind].scale_x * horisontal_draw_scale, entities.editorTypes[tile.kind].scale_y * vertical_draw_scale)
end

function draw_sprite(entity)
	love.graphics.draw(entity.sprite.sprite, entity.position.x * horisontal_draw_scale, entity.position.y * vertical_draw_scale, 0, entity.sprite.scale_factor_x * horisontal_draw_scale, entity.sprite.scale_factor_y * vertical_draw_scale)
end

function draw_rect(entity, x_offset, y_offset)
	love.graphics.rectangle("fill", (entity.position.x) * horisontal_draw_scale, vertical_draw_scale * (entity.position.y), entity.width * horisontal_draw_scale, entity.height * vertical_draw_scale)
end

function print_DEBUG()
	love.graphics.printf("y: " .. entities.player.position.y, 20, 10, 1000, "left" )
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
	love.graphics.printf("Current multiplier: " .. entities.player.currentMultiplier, 20, 110, 1000, "left")
end
