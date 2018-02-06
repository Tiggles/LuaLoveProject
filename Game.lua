Game = {}

function Game:new()

end

function game_draw(game)
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

	Score:drawTimer()
	Score:drawScoreCount()
	Score:drawMultiplier()
end