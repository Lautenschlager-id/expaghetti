local Literal = { }

Literal.execute = function(currentCharacter, index, expression, tree)
	tree[index] = {
		type = "literal",
		value = currentCharacter
	}

	index = index + 1
	return index
end

return Literal