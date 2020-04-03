local match = { }
match.__index = match

match.new = function(self)
	return setmetatable({
		_index = 0,
		stack = { }
	}, self)
end

match.push = function(self, char)
	self._index = self._index + 1
	self.stack[self._index] = char

	return self
end

match.get = function(self, index)
	if index then
		return self.stack[index]
	end
	return self.stack
end

return match