local enum_type_alternate = "alternate"

local alternate = { }
alternate.__index = alternate

alternate.new = function(self)
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

alternate.push = function(self, position)
	self._index = self._index + 1
	self.stack[self._index] = position

	return self
end

alternate.exists = function(self)
	return self._index > 0
end

alternate.generate = function(self, exp)
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

	return { { type = enum_type_alternate, exp = tree } }
end

return alternate