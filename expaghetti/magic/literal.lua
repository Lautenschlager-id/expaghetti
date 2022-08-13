local Literal = { }

Literal.execute = function(currentCharacter, index, expression, tree)
	--[[
		{
			type = "literal",
			value = 'a'
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = "literal",
		value = currentCharacter
	}

	index = index + 1
	return index
end

return Literal