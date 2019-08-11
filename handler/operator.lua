local operator = { }
operator.__index = operator
operator.__tostring = "operator"

operator.new = function(self)
	return setmetatable({
		_index = 0,
		stack = {
			--[[
				[i] = {
					operator → string,
					isLazy → bool
				}
			]]
		}
	}, self)
end

operator.push = function(self, char)
	self._index = self._index + 1
	self.stack[self._index] = {
		operator = char,
		isLazy = false
	}

	return self
end

operator.isLazy = function(self, lazy)
	self.stack[self._index].isLazy = lazy -- Not checking yet about LAZY==ZERO_OR_ONE

	return self
end

operator.get = function(self)
	return self.stack[self._index]
end

return operator