function check_collision(self, other)
	local self_left = self.position.x
    local self_right = self.position.x + self.width
    local self_top = self.position.y
    local self_bottom = self.position.y + self.height

    local other_left = other.position.x
    local other_right = other.position.x + other.width
    local other_top = other.position.y
    local other_bottom = other.position.y + other.height

    if self_right >= other_left and
    self_left <= other_right and
    self_bottom >= other_top and
    self_top <= other_bottom then
        return true
    else
        return false
    end
end

function update_gameSpeed(game_speed, delta_time, time_rising)
    if time_rising then
        return math.min(game_speed + delta_time, 1)
    else
        return math.max(game_speed - delta_time, 0.5)
    end
end

function table_clone(old)
    new = {}
    for k, v in ipairs(old) do
        new[k] = v
    end
    return new
end

function init_tiles_frame(tiles)
    table.insert(tiles, Tile:newTile( 160, 288, 1))
    table.insert(tiles, Tile:newTile( 256, 288, 1))
    table.insert(tiles, Tile:newTile( 352, 288, 1))
    table.insert(tiles, Tile:newTile( 448, 288, 1))
    table.insert(tiles, Tile:newTile( 544, 288, 1))
    table.insert(tiles, Tile:newTile( 640, 288, 1))

    table.insert(tiles, Tile:newTile( 96, 352, 1))
    table.insert(tiles, Tile:newTile( 192, 352, 1))
    table.insert(tiles, Tile:newTile( 288, 352, 1))
    table.insert(tiles, Tile:newTile( 384, 352, 1))
    table.insert(tiles, Tile:newTile( 512, 352, 1))
    table.insert(tiles, Tile:newTile( 608, 352, 1))

    table.insert(tiles, Tile:newTile( 160, 416, 1))
    table.insert(tiles, Tile:newTile( 256, 416, 1))
    table.insert(tiles, Tile:newTile( 352, 416, 1))
    table.insert(tiles, Tile:newTile( 448, 416, 1))
    table.insert(tiles, Tile:newTile( 544, 416, 1))
    table.insert(tiles, Tile:newTile( 640, 416, 1))
end

function init_boundaries(tiles)
    for i = 0, 24, 1 do
        table.insert(tiles, Tile:newTile(32 * i, -32, 1))
        table.insert(tiles, Tile:newTile(32 * i, screen.height, 1))
    end

    for i = 0, 14, 1 do
        table.insert(tiles, Tile:newTile(-32, 32 * i, 1))
        table.insert(tiles, Tile:newTile(screen.width, 32 * i, 1))
    end

    init_tiles_frame(tiles)

    for i = 1, 400 do
        table.insert(enemies, Grunt:new(10*i , 5*i))
    end
end

function init_entities()
    entities = {
        player = Player:new(20, 20, 20, 20, "Assets/Character1.png", 0.5, 0.25),
        enemies = {},
        blocks = {},
        animations = {},
        editorTypes = {},
        tiles = {},
        collectibles = {},
        generators = {},
        event_tiles = {}
    }
    return entities
end

function compare(a, b)
    if a.position.y < b.position.y then return true end
    if a.position.y > b.position.y then return false end
    return a.position.x < b.position.x
end

function save_level(filename)
    file = io.open(filename, "w")
    for i = 1, #entities.tiles do
        local tile = entities.tiles[i]
        print(tile.kind)
        file:write("t;" .. tile.position.x .. ";" .. tile.position.y .. ";" .. tile.kind .. ";")
    end
    for i = 1, #entities.collectibles do
        local collectible = entities.collectibles[i]
        print(collectible.kind)
        file:write("c;" .. collectible.position.x .. ";" .. collectible.position.y .. ";" .. collectible.kind .. ";")
    end
    file:close()
end

function read_level(filename)
    if filename == nil then return end
    local level = {}
    local content = love.filesystem.read(filename)
    i = 1
    for word in string.gmatch(content, '([^;]+)') do
        level[i] = word
        i = i + 1
    end
    j = 1
    for j = 1, #level, 4 do
        if (level[j] == "t") then
            table.insert(entities.tiles, Tile:newTile(tonumber(level[j + 1]), tonumber(level[j + 2]), tonumber(level[j + 3])))
        elseif (level[j] == "c") then
            table.insert(entities.collectibles, Collectible:newCollectible(level[j + 1], level[j + 2], level[j + 3]))
        end
    end
end