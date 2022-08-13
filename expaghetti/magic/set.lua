local Set = { }

local OPEN_SET = '['
local CLOSE_SET = ']'
local NEGATE_SET = '^'
local SET_RANGE_SEPARATOR = '-'

Set.is = function(currentCharacter)
	return currentCharacter == OPEN_SET
end

local findMagicClosing = function(index, expression)
	local currentCharacter
	repeat
		currentCharacter = expression[index]

		-- expression ended but magic was never closed
		if not currentCharacter then
			return false, "Invalid regular expression: Missing '" .. CLOSE_SET .. "' to close set"
		elseif currentCharacter == CLOSE_SET then
			return index
		end

		index = index + 1
	until false
end

Set.execute = function(currentCharacter, index, expression, tree)
	-- skip magic opening
	index = index + 1

	local endIndex, errorMessage = findMagicClosing(index, expression)
	if not endIndex then
		return false, errorMessage
	end

	--[[
		{
			type = "set",

			hasToNegateMatch = false,

			rangeIndex = 0,
			ranges = {
				[min1] = '',
				[max1] = '',
				...
			},

			[literal1] = true,
			...
		}
	]]
	local set = {
		type = "set",

		hasToNegateMatch = false,

		rangeIndex = 0,
		ranges = { },
	}

	local lastCharacter, nextCharacter
	local watchForRangeSeparator = false
	local firstCharacter = index
	repeat
		currentCharacter = expression[index]
		-- first character of the set
		if index == firstCharacter and currentCharacter == NEGATE_SET then
			set.hasToNegateMatch = true
		else
			nextCharacter = index + 1 < endIndex and expression[index + 1]

			-- assume that currentCharacter == SET_RANGE_SEPARATOR
			if watchForRangeSeparator then
				watchForRangeSeparator = false

				if nextCharacter then
					-- Lua can perform string comparisons natively
					if lastCharacter > nextCharacter then
						return false, "Invalid regular expression: Range out of order in set"
					end

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = lastCharacter

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = nextCharacter

					-- Skip next delim
					index = index + 1
				else
					set[lastCharacter] = true
					set[currentCharacter] = true
				end
			elseif nextCharacter == SET_RANGE_SEPARATOR then
				watchForRangeSeparator = true
			else
				set[currentCharacter] = true
			end
		end

		lastCharacter = currentCharacter
		index = index + 1
	until index == endIndex

	-- skip magic closing
	index = index + 1

	tree._index = tree._index + 1
	tree[tree._index] = set

	return index
end

return Set