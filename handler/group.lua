local group = { }
group.__index = group
group.__tostring = "group"

group.new = function(self)
	return setmetatable({
		_index = 0,
		isOpen = false,
		stack = {
			--[[
				[i] = {
					_effect → string, -- group behavior, :=!...
					_index → int,
					[i] → string
				}
			]]
		},
		watchEffect = false
	}, self)
end

group.open = function(self)
	self._index = self._index + 1
	self.stack[self._index] = {
		_behind = nil,
		_effect = nil,
		_index = 0
	}

	self.watchEffect = false
	self.isOpen = true

	return self
end

group.close = function(self)
	self.isOpen = false

	return self
end

group.push = function(self, char)
	if not self.isOpen then return end
	local this = self.stack[self._index]
	this._index = this._index + 1
	this[this._index] = char

	return self
end

group.setEffect = function(self, effect)
	if not self.isOpen then return end
	self.stack[self._index]._effect = effect

	return self
end

group.setBehind = function(self)
	if not self.isOpen then return end
	self.stack[self._index]._behind = true

	return self
end

group.get = function(self)
	if not self.isOpen then return end
	return self.stack[self._index]
end

return group