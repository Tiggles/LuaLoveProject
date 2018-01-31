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