local boundary = { }
boundary.__index = boundary
boundary.__tostring = "boundary"

boundary.new = function(self)
	return setmetatable({
		_index = 0,
		stack = {
			--[[
				[i] = {
					boundary → string,
				}
			]]
		}
	}, self)
end

boundary.push = function(self, char)
	self._index = self._index + 1
	self.stack[self._index] = {
		boundary = char
	}

	return self
end

boundary.get = function(self)
	return self.stack[self._index]
end

return boundary