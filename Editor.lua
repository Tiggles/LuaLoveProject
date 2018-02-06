local anim8 = require "anim8/anim8"

Editor = {}
local LUA_INDEX_OFFSET = 1
local TYPE_COUNT = 4
-- Types:
-- -- 0. tiles
-- -- 1. collectibles
-- -- 2. events
-- -- 3. actors

function hide_cursor()
	cursor = love.mouse.newCursor("Assets/empty_cursor.png")
	love.mouse.setCursor(cursor)
end

function Editor:new()
    hide_cursor()
    cursor_image = love.graphics.newImage("Assets/Cursor.png")
	local g = anim8.newGrid(32, 32, cursor_image:getWidth(), cursor_image:getHeight())
    local editor = {
        cursorAnimation = anim8.newAnimation(g('1-2', 1), 0.5),
        currentIndex = 0,
        currentType = 0,
        tiles = {},
        collectibles = {},
        events = {},
        actors = {},
        nextAllowedChange = love.timer.getTime(),
        level = {
            tiles = {},
            collectibles = {},
            events = {},
            actors = {}
        },
    }
	self.__index = self
	return setmetatable(editor, self)
end

function Editor:addTileType(spritePath, scale_x, scale_y, width, height, is_blocking)
    table.insert(self.tiles, TileType:newType(spritePath, scale_x, scale_y, width, height, is_blocking))
end

function Editor:addCollectibleType(spritePath, scale_x, scale_y, width, height, is_blocking)
    table.insert(self.collectibles, CollectibleType:newType(spritePath, scale_x, scale_y, height, is_blocking))
end

function Editor:addEventType(spritePath, scale_x, scale_y, width, height, is_blocking)
    table.insert(self.events, EventType:newType(spritePath, scale_x, scale_y, width, height, is_blocking))
end

function Editor:addActorType(spritePath, scale_x, scale_y, width, height, is_friendly)
    table.insert(self.actors, ActorType:newType(spritePath, scale_x, scale_y, width, height, is_friendly))
end

function Editor:getCurrentTile()
    if 0 == self.currentType then
        return self.tiles[self.currentIndex + LUA_INDEX_OFFSET]
    elseif 1 == self.currentType then
        return self.collectibles[self.currentIndex + LUA_INDEX_OFFSET]
    elseif 2 == self.currentType then
        return self.events[self.currentIndex + LUA_INDEX_OFFSET]
    elseif 3 == self.currentType then
        return self.actors[self.currentIndex + LUA_INDEX_OFFSET]
    end
end

function Editor:changeType(direction)
    if not self:allowedChange() then return end
    self.currentType = self.currentType + direction % TYPE_COUNT
    self:updateAllowedChange()
end

function Editor:changeIndex(direction)
    if not self:allowedChange() then return end
    self.currentIndex = (self.currentIndex + direction) % self:getTypeCount()
    self:updateAllowedChange()
end

function Editor:allowedChange()
    return self.nextAllowedChange < love.timer.getTime()
end

function Editor:updateAllowedChange()
    self.nextAllowedChange = love.timer.getTime() + 0.2
end

function Editor:getTypeCount()
    if 0 == self.currentType then
        return #self.tiles
    elseif 1 == self.currentType then
        return #self.collectibles
    elseif 2 == self.currentType then
        return #self.events
    elseif 3 == self.currentType then
        return #self.actors
    end
    return "FAULT"
end

function editor_update(dt, editor)
    editor.cursorAnimation:update(dt)
    local mouse_x, mouse_y, left_mouse_button_pressed, right_mouse_button_pressed
    editor:handleMouseEditor()
end

function Editor:checkIfTileIsOccupied()
    local tile = self:getCurrentTile()
    for i = 1, #self.level.tiles do
        local tile = self.level.tiles[i]
        local collision_block = { position = tile.position, width = kind.width, height = kind.height }
        if check_collision(collision_block, { position = { x = x, y = y }, width = 1, height = 1 }) then
            return true
        end
    end

    local kind = entities.editorTypes[collectible.kind]
    for i = 1, #entities.collectibles do
        local collectible = editor.level.collectibles[i]
        local collision_block = { position = collectible.position, width = kind.width, height = kind.height }
        if check_collision(collision_block, { position = { x = x, y = y }, width = 1, height = 1 }) then
            return true
        end
    end
end

function Editor:insertBlock(x,y)
    local editor_type = editor:getCurrentTile()
    if editor_type.kind_type == constants.editor_constants.tile then
        table.insert(entities.tiles, Tile:newTile((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET))
        table.sort( entities.tiles, compare )
    elseif editor_type.kind_type == constants.editor_constants.collectible then
        table.insert(entities.collectibles, Collectible:newCollectible((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET))
        table.sort( entities.collectibles, compare )
    elseif editor_type.kind_type == constants.editor_constants.event then
        if editor_type.event_type == kinds.start then
            entities.event_tiles[kinds.start] = Event:newEvent((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET)
        elseif editor_type.event_type == kinds.finish then
            entities.event_tiles[kinds.finish] = Event:newEvent((x - (x % editor_type.width)), (y - (y % editor_type.width)), tile_index + LUA_INDEX_OFFSET)
        end
    end
    self.nextAllowedChange = love.timer.getTime() + .1
end

function Editor:handleMouseEditor()
    local x, y = love.mouse.getX() / horisontal_draw_scale, love.mouse.getY() / vertical_draw_scale
    local left, right = love.mouse.isDown(1), love.mouse.isDown(2)
    if left and next_block_interaction < love.timer.getTime() then
        local occupied_space = self:checkIfTileIsOccupied()
        if not occupied_space then
            self:insertBlock(x, y)
        end
    end

    if right and next_block_interaction < love.timer.getTime() then
        self:removeBlock(x,y)
    end
end

function Editor:removeBlock(x,y)
    for i = #entities.tiles, 1, -1 do
        local tile = self.tiles[i]
        local kind = self.editorTypes[tile.kind]
        if check_collision({ position = tile.position, width = kind.width, height = kind.height }, { position = { x = x, y = y }, width = 1, height = 1 }) then
            table.remove(self.level.tiles, i)
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

function editor_draw(editor)
    -- Draw blocks
    for i = #editor.level.tiles, 1, -1 do
        local tile = entities.tiles[i];
        draw_tile(tile)
    end

    for i = #editor.level.collectibles, 1, -1 do
        local collectible = entities.collectibles[i];
        local kind = entities.editorTypes[collectible.kind]
        entities.animations[2]:draw(coin_image, collectible.position.x * horisontal_draw_scale, collectible.position.y * vertical_draw_scale, 0, horisontal_draw_scale * kind.scale_x, vertical_draw_scale * kind.scale_y)
    end

    for i = #editor.level.events, 1, -1 do
        if entities.event_tiles[i] ~= nil then -- HACK
            local event = entities.event_tiles[i];
            draw_tile(event)
        end
    end
    -- Draw cursors
    local x, y = love.mouse.getX() / horisontal_draw_scale, love.mouse.getY() / vertical_draw_scale
    draw_rect( { position = { x = x, y = y}, width = 5, height = 5  })
    editor.cursorAnimation:draw(cursor_image, (x - (x % 32)) * horisontal_draw_scale, (y - (y % 32)) * vertical_draw_scale, 0, horisontal_draw_scale, vertical_draw_scale)


    -- Draw Items
    -- Draw enemies

    -- Render currently selected block
    local currentEditorTile = editor:getCurrentTile()
    love.graphics.draw(tile_frame.sprite.sprite, 10 * horisontal_draw_scale, 170 * vertical_draw_scale, 0, tile_frame.scale_x * horisontal_draw_scale, tile_frame.scale_y * vertical_draw_scale)
    love.graphics.draw(currentEditorTile.sprite.sprite, 22 * horisontal_draw_scale, 182 * vertical_draw_scale, 0, currentEditorTile.scale_x * horisontal_draw_scale, currentEditorTile.scale_y * vertical_draw_scale)

    if love.keyboard.isDown("escape") then
        save_level("with_collectibles.lvl")
        love.event.quit();
    end

    if love.keyboard.isDown("i") and next_rendering_switch < love.timer.getTime() and #entities.event_tiles == 2 then
        editor_mode = not editor_mode
        next_rendering_switch = love.timer.getTime() + 1
        entities.player.position.x = entities.event_tiles[1].position.x
        entities.player.position.y = entities.event_tiles[1].position.y
        game_coins = table_clone(entities.collectibles)
        Score:initialize()
        keyboard_or_controller = true
    end
end