local queueFactory = require("handler/queue")

local alternate = { }
alternate.__index = alternate

alternate.new = function(self)
	return setmetatable({
		_index = 0,
		stack = {
			[0] = 0
		}
	}, self)
end

alternate.push = function(self, position)
	self._index = self._index + 1
	self.stack[self._index] = position

	return self
end

alternate.exists = function(self)
	return self._index > 0
end

alternate.build = function(self, exp)
	local tree = { } -- ab(ac|bd)|fg = { { "a", "b", { { "a", "c" }, { "b", "d" } } }, { "f", "g" } }

	self:push(exp._index) -- [0, #e], not [0, #e - []]

	for i = 1, self._index do
		tree[i] = queueFactory:new()

		for j = self.stack[i - 1] + 1, self.stack[i] do
			tree[i]:push(exp:get(j))
		end
	end

	return { type = "alternate", trees = tree }
end

return alternate