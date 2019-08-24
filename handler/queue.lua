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
	local exp
	if index then
		exp = self.stack[index]
	else
		exp = self.stack[self._index]
	end
	return exp, type(exp)
end

return queue