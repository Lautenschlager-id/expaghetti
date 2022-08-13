local Set = { }

local OPEN_SET = '['
local CLOSE_SET = ']'

Set.is = function(currentCharacter)
	return currentCharacter == OPEN_SET
end

Set.execute = function(currentCharacter, index, expression, tree)
	--[[
		{
			type = "set",
			[literal] = true,
		}
	]]
	local set = {
		type = "set",
	}

	repeat
		index = index + 1
		currentCharacter = expression[index]

		if not currentCharacter then -- expression ended but magic was never closed
			return false, "Invalid regular expression: Missing '" .. CLOSE_SET .. "' to close set"
		end

		if currentCharacter == CLOSE_SET then
			index = index + 1
			break
		end

		set[currentCharacter] = true
	until false

	tree._index = tree._index + 1
	tree[tree._index] = set

	return index
end

return Set