local enum = require("enum")

local strbyte = string.byte
local strchar = string.char

local set = { }
set.__index = set

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
end

set.close = function(self)
	self.isOpen = false
end

set.push = function(self, char)
	self.stack[self._index][char] = true
end

set.negate = function(self)
	self.stack[self._index]._negated = true
end

set.range = function(self, min, max)
	local this = self.stack[self._index]
	for b = strbyte(min), strbyte(max) do
		this[strchar(b)] = true
	end
end

return set