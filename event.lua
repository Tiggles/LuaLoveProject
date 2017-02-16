local constants = require("constants")

EventType = {}

kinds = {
	start = 1,
	finish = 2
}

function EventType:newType(path, scale_x, scale_y, width, height, is_blocking, type)
	newEventType = {
		sprite = Sprite:new(path, scale_x, scale_y),
		scale_x = scale_x,
		scale_y = scale_y,
		width = width,
		height = height,
		is_blocking = is_blocking,
		kind_type = constants.editor_constants.event,
		event_type = type
	}
	self.__index = self
	return setmetatable(newEventType, self)
end


Event = {}

function Event:newEvent(x, y, kind)
	new_event = {
		position = Position:new(x, y),
		kind = kind
	}
	self.__index = self
	return setmetatable(new_event, self)
end