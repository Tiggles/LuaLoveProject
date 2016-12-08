function checkCollision(self, other)
	local self_left = self.x
    local self_right = self.x + self.width
    local self_top = self.y
    local self_bottom = self.y + self.height

    local other_left = other.x
    local other_right = other.x + other.width
    local other_top = other.y
    local other_bottom = other.y + other.height

    if self_right > other_left and
    self_left < other_right and
    self_bottom > other_top and
    self_top < other_bottom then
        return true
    else
        return false
    end
end