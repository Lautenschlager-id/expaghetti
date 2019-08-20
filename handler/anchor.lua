local anchor = { }
anchor.__index = anchor
anchor.__tostring = "anchor"

anchor.new = function(self)
	return setmetatable({
		_index = 0,
		stack = {
			--[[
				[i] = {
					anchor → string,
				}
			]]
		}
	}, self)
end

anchor.push = function(self, char)
	self._index = self._index + 1
	self.stack[self._index] = {
		anchor = char
	}

	return self
end

anchor.get = function(self)
	return self.stack[self._index]
end

return anchor