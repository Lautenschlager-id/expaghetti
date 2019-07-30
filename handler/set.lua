local strbyte = string.byte
local strchar = string.char

local set = { }
set.__index = set
set.__tostring = "set"

set.new = function(self)
	return setmetatable({
		_index = 0,
		isOpen = false,
		stack = {
			--[[
				[i] = {
					_negated → bool,
					[char] = true -- Hash system for performance
				}
			]]
		}
	}, self)
end

set.open = function(self)
	self._index = self._index + 1
	self.stack[self._index] = {
		_negated = false
	}

	self.isOpen = true

	return self
end

set.close = function(self)
	self.isOpen = false

	return self
end

set.push = function(self, char)
	if not self.isOpen then return end
	self.stack[self._index][char] = true

	return self
end

set.negate = function(self)
	if not self.isOpen then return end
	self.stack[self._index]._negated = true

	return self
end

set.range = function(self, min, max)
	if not self.isOpen then return end
	local this = self.stack[self._index]
	for b = strbyte(min), strbyte(max) do
		this[strchar(b)] = true
	end

	return self
end

set.get = function(self)
	if not self.isOpen then return end
	return self.stack[self._index]
end

set.match = function(self, char)
	local this = self.stack[self._index]
	if this._negated then
		return not this[char]
	else
		return this[char]
	end
end

return set