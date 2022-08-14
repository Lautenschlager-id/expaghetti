local Escaped = require("./magic/escaped")

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

local getCharacterConsideringEscapedElements = function(character, index, expression, tree)
	if not character then
		return
	end

	if Escaped.is(character) then
		local value
		index, value = Escaped.execute(character, index, expression, tree)
		if not index then
			-- value = error message
			return false, value
		end

		if value.type == "literal" then
			character = value.value
		else
			character = value
		end

		index = index - 1
	end

	return index, character
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

			classIndex = 0,
			classes = { },

			[literal1] = true,
			...
		}
	]]
	local set = {
		type = "set",

		hasToNegateMatch = false,

		rangeIndex = 0,
		ranges = { },

		classIndex = 0,
		classes = { },
	}

	local lastCharacter, nextCharacter, nextIndex
	local watchForRangeSeparator = false
	local firstCharacter = index
	repeat
		currentCharacter = expression[index]
		-- first character of the set
		if index == firstCharacter and currentCharacter == NEGATE_SET then
			set.hasToNegateMatch = true
		else
			index, currentCharacter =
				getCharacterConsideringEscapedElements(currentCharacter, index, expression, tree)
			if not index then
				-- currentCharacter = error message
				return false, currentCharacter
			end

			nextCharacter, nextIndex = false
			if index + 1 < endIndex then
				nextIndex = index + 1
				-- TO DO: Improve how it's checked, or else it will always calculate the value twice
				nextIndex, nextCharacter = getCharacterConsideringEscapedElements(
					expression[nextIndex], nextIndex, expression, tree)

				if not nextIndex then
					-- nextCharacter = error message
					return false, nextCharacter
				end
			end

			if currentCharacter.type == "set" then
				set.classIndex = set.classIndex + 1
				set.classes[set.classIndex] = currentCharacter

			-- assume that currentCharacter == SET_RANGE_SEPARATOR
			elseif watchForRangeSeparator then
				watchForRangeSeparator = false

				-- with the first condition checking if the char is a set, then it will fall to this
				-- and if only the following char is a set, then .type ~= nil
				-- so it can only be a range when both .type are nil, this nil == nil == true
				if nextCharacter and (lastCharacter.type == nextCharacter.type == true) then
					-- Lua can perform string comparisons natively
					if lastCharacter > nextCharacter then
						return false, "Invalid regular expression: Range out of order in set"
					end

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = lastCharacter

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = nextCharacter

					-- Skip next delim
					if nextIndex then
						index = nextIndex
					else
						index = index + 1
					end
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