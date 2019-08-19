local expor = { }
expor.__index = expor
expor.__tostring = "expor" -- "expression or"

expor.new = function(self)
	return setmetatable({
		_index = 0,
		stack = {
			[0] = 0
			--[[
				[i] → int
			]]
		}
	}, self)
end

expor.push = function(self, position)
	self._index = self._index + 1
	self.stack[self._index] = position

	return self
end

expor.exists = function(self)
	return self._index > 0
end

expor.generate = function(self, exp)
	local tree = { } -- ab(ac|bd)|fg = { { "a", "b", { { "a", "c" }, { "b", "d" } } }, { "f", "g" } }

	self:push(exp._index) -- [0, #e], not [0, #e - []]

	local p
	for i = 1, self._index do
		p = 0
		tree[i] = { }

		for j = self.stack[i - 1] + 1, self.stack[i] do
			p = p + 1
			tree[i][p] = exp:get(j)
		end
	end

	return { { type = "or", exp = tree } }
end

return expor