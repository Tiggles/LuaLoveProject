Editor = {}

function Editor:new()
    local editor = {
        tiles = {},
        collectibles = {},
        events = {},
        actors = {}
    }
	self.__index = self
	return setmetatable(editor, self)
end

function Editor:addTileType(path, scale_x, scale_y, width, height, is_blocking)
    table.insert(self.tiles, TileType:newType(path, scale_x, scale_y, width, height, is_blocking))
end

function Editor:addCollectibleType(path, scale_x, scale_y, width, height, is_blocking)
    table.insert(self.collectibles, CollectibleType:newType(path, scale_x, scale_y, height, is_blocking))
end

function Editor:addEventType(path, scale_x, scale_y, width, height, is_blocking)
    table.insert(self.events, EventType:newType(path, scale_x, scale_y, width, height, is_blocking))
end

function Editor:addActorType(path, scale_x, scale_y, width, height, is_friendly)

end