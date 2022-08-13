local Set = { }

local OPEN_SET = '['
local CLOSE_SET = ']'
local NEGATE_SET = '^'

Set.is = function(currentCharacter)
	return currentCharacter == OPEN_SET
end

Set.execute = function(currentCharacter, index, expression, tree)
	--[[
		{
			type = "set",
			hasToNegateMatch = false,
			[literal] = true,
		}
	]]
	local set = {
		type = "set",
		hasToNegateMatch = false,
	}

	local setIndex = 0
	repeat
		index = index + 1
		currentCharacter = expression[index]

		if not currentCharacter then -- expression ended but magic was never closed
			return false, "Invalid regular expression: Missing '" .. CLOSE_SET .. "' to close set"
		end

		if setIndex == 0 and currentCharacter == NEGATE_SET then -- first character of the set
			set.hasToNegateMatch = true
		elseif currentCharacter == CLOSE_SET then
			index = index + 1
			break
		else
			set[currentCharacter] = true
		end

		setIndex = setIndex + 1
	until false

	tree._index = tree._index + 1
	tree[tree._index] = set

	return index
end

return Set