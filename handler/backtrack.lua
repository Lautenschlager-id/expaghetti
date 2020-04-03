local backtrack = { }
backtrack.__index = backtrack

backtrack.new = function(self)
	return setmetatable({
		_lastIndex = nil,
		executing = false,
		stack = { }
	}, self)
end

backtrack.push = function(self, index, match)
	if not self.stack[index] then
		self.stack[index] = {
			_index = 0
		}
	end
	self._lastIndex = index
	self.stack[index]._index = self.stack[index]._index + 1
	--self.stack[index][self.stack[index]._index] = match

	return self
end

backtrack.pop = function(self, index, matchIndex)
	local this = self.stack[(index or self._lastIndex)]

	--[=[
	for i = (matchIndex or this._index) + 1, this._index do
		this[i - 1] = this[i]
	end
	this[this._index] = nil
	]=]
	this._index = this._index - 1

	return self
end

backtrack.getLength = function(self, index)
	return self.stack[(index or self._lastIndex)]._index
end

backtrack.get = backtrack.getLength--function(self, index, matchIndex)
	--index = (index or self._lastIndex)
	--return self.stack[index][(matchIndex or self.stack[index]._index)]
--end

return backtrack