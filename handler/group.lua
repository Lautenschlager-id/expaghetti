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
		_effect = nil,
		_index = 0
	}

	self.watchEffect = false
	self.isOpen = true
end

group.close = function(self)
	self.isOpen = false
end

group.push = function(self, char)
	if not self.isOpen then return end
	local this = self.stack[self._index]
	this._index = this._index + 1
	this[this._index] = char
end

group.setEffect = function(self, effect)
	if not self.isOpen then return end
	self.stack[self._index]._effect = effect
end

group.get = function(self)
	if not self.isOpen then return end
	return self.stack[self._index]
end

return group