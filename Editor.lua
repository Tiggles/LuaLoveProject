Editor = {}
local LUA_INDEX_OFFSET = 1
local TYPE_COUNT = 4
-- Types:
-- -- 0. tiles
-- -- 1. collectibles
-- -- 2. events
-- -- 3. actors

function Editor:new()
    local editor = {
        currentIndex = 0,
        currentType = 0,
        tiles = {},
        collectibles = {},
        events = {},
        actors = {},
        nextAllowedChange = love.timer.getTime()
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
    print("fault")
    return "FAULT"
end

function Editor:update()

end