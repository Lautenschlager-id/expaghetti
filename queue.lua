local queue = { }
queue.__index = queue
queue.__tostring = "queue"

queue.new = function(self)
	return setmetatable({
		_index = 0,
		stack = { }
	}, self)
end

queue.push = function(self, data)
	self._index = self._index + 1
	self.stack[self._index] = data
end

queue.get = function(self, index)
	if index then
		return self.stack[index]
	else
		return self.stack[self._index]
	end
end

return queue