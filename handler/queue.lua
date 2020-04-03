local queue = { }
queue.__index = queue

queue.new = function(self)
	return setmetatable({
		_index = 0,
		stack = { }
	}, self)
end

queue.push = function(self, data)
	self._index = self._index + 1
	self.stack[self._index] = data

	return self
end

queue.switchWithLast = function(self)
	if self._index < 2 then
		--error("Nothing to repeat at")
	end

	self.stack[self._index - 1], self.stack[self._index] = self.stack[self._index], self.stack[self._index- 1]

	return self
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

queue.clear = function(self)
	self._index = 0
	self.stack = { }

	return self
end

return queue