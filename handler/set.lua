local enum = require("enum")

local strbyte = string.byte

local set = { }
set.__index = set

set.new = function(self)
	return setmetatable({
		_index = 0,
		isOpen = false,
		stack = {
			--[[
				[i] = {
					_index → int,
					_negated → bool,
					_rangeIndex → int,
					_min → arr<int>,
					_max → arr<int>,
					... → str
				}
			]]
		}
	}, self)
end

set.open = function(self)
	self._index = self._index + 1
	self.stack[self._index] = {
		_index = 0,
		_negated = false,
		_rangeIndex = 0,
		_min = { },
		_max = { }
	}

	self.isOpen = true
end

set.close = function(self)
	self.isOpen = false
end

set.push = function(self, char)
	local this = self.stack[self._index]
	this._index = this._index + 1
	this[this._index] = char
end

set.negate = function(self)
	self.stack[self._index]._negated = true
end

set.range = function(self, min, max)
	min, max = strbyte(min), strbyte(max)

	local this = self.stack[self._index]
	this._rangeIndex = this._rangeIndex + 1
	this._min[this._rangeIndex] = min
	this._max[this._rangeIndex] = max
end

return set