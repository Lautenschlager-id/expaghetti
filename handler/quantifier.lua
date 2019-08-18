local quantifier = { }
quantifier.__index = quantifier
quantifier.__tostring = "quantifier"

quantifier.new = function(self)
	return setmetatable({
		_index = 0,
		isOpen = false,
		stack = {
			--[[
				[i] = {
					_index → int,
					[i] → int
				}
			]]
		}
	}, self)
end

quantifier.open = function(self)
	if self.isOpen then
		--error("Cannot nest quantifiers")
	end

	self._index = self._index + 1
	self.stack[self._index] = {
		_index = 1,
		isLazy = false,
		[1] = nil,
		[2] = nil
	}

	self.isOpen = true

	return self
end

quantifier.close = function(self)
	self.isOpen = false

	return self
end

quantifier.next = function(self) -- adds +1 to the index when x,y
	if not self.isOpen then return end
	local this = self.stack[self._index]
	this._index = this._index + 1

	return self
end

quantifier.isLazy = function(self, lazy)
	self.stack[self._index].isLazy = lazy -- Not checking yet about LAZY==ZERO_OR_ONE (???)

	return self
end

quantifier.push = function(self, num)
	num = tonumber(num)
	if not num then
		--error("Cannot create non-numeric quantifiers")
	end

	if not self.isOpen then return end
	local this = self.stack[self._index]
	if this[this._index] then
		this[this._index] = tonumber(this[this._index] .. num)
	else
		this[this._index] = num
	end

	return self
end

quantifier.get = function(self)
	if not self.isOpen then return end
	return self.stack[self._index]
end

return quantifier