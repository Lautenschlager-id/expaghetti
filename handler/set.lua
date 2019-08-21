local enum_type_set = "set"

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
					_rangeIndex → int,
					_min → arr<string>,	
					_max → arr<string>,
					_setIndex → int,
					_set → arr<table>
					[char] = true -- Hash system for performance
				}
			]]
		}
	}, self)
end

set.open = function(self)
	self._index = self._index + 1
	self.stack[self._index] = {
		type = enum_type_set,
		_hasValue = false,
		_negated = false,
		_rangeIndex = 0,
		_min = { },	
		_max = { },
		_setIndex = 0,
		_set = { }
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
	local this = self.stack[self._index]
	this._hasValue = true

	if type(char) == "table" then -- Temporary quickfix
		this._setIndex = this._setIndex + 1
		this._set[this._setIndex] = char
	else
		this[char] = true
	end

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
	this._hasValue = true
	this._rangeIndex = this._rangeIndex + 1
	this._min[this._rangeIndex] = min -- Lua can perform string comparisons natively
	this._max[this._rangeIndex] = max

	return self
end

set.hasValue = function(self)
	return self.stack[self._index]._hasValue
end

set.get = function(self)
	if not self.isOpen then return end
	return self.stack[self._index]
end

set.match = function(this, char) -- Maybe make this function static? (set, char)
	--local this = self.stack[self._index]
	local found = this[char]
	if not found and this._rangeIndex > 0 then
		for i = 1, this._rangeIndex do
			if char >= this._min[i] and char <= this._max[i] then
				found = true
				break
			end
		end
	end

	if this._negated then
		return not found
	else
		return found
	end
end

return set