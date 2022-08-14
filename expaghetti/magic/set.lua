----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local elementsEnum = require("./enums/elements")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_SET = magicEnum.OPEN_SET
local ENUM_CLOSE_SET = magicEnum.CLOSE_SET
local ENUM_NEGATE_SET = magicEnum.NEGATE_SET
local ENUM_SET_RANGE_SEPARATOR = magicEnum.SET_RANGE_SEPARATOR
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_SET = elementsEnum.set
----------------------------------------------------------------------------------------------------
local Set = { }

local getCharacterConsideringEscapedElements = function(character, index, expression)
	if not character then
		return
	end

	local isEscaped = false
	if Escaped.is(character) then
		local value
		index, value = Escaped.execute(character, index, expression)
		if not index then
			-- value = error message
			return false, value
		end

		if value.type == ENUM_ELEMENT_TYPE_LITERAL then
			character = value.value
		else
			character = value
		end

		index = index - 1
		isEscaped = true
	end

	return index, character, isEscaped
end

local findMagicClosing = function(index, expression)
	local currentCharacter, isEscaped
	repeat
		index, currentCharacter, isEscaped = getCharacterConsideringEscapedElements(
			expression[index], index, expression, true)
		if not index and currentCharacter then
			-- currentCharacter = error message
			return false, currentCharacter
		end

		-- expression ended but magic was never closed
		if not currentCharacter then
			return false, errorsEnum.unclosedSet
		elseif not isEscaped and currentCharacter == ENUM_CLOSE_SET then
			return index
		end

		index = index + 1
	until false
end
----------------------------------------------------------------------------------------------------
Set.is = function(currentCharacter)
	return currentCharacter == ENUM_OPEN_SET
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
			type = ENUM_ELEMENT_TYPE_SET,

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
		type = ENUM_ELEMENT_TYPE_SET,

		hasToNegateMatch = false,

		rangeIndex = 0,
		ranges = { },

		classIndex = 0,
		classes = { },
	}

	local lastCharacter, nextCharacter, nextIndex, isEscaped
	local watchForRangeSeparator = false
	local firstCharacter = index
	repeat
		currentCharacter = expression[index]
		-- first character of the set
		if index == firstCharacter and currentCharacter == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		else
			index, currentCharacter =
				getCharacterConsideringEscapedElements(currentCharacter, index, expression)
			if not index then
				-- currentCharacter = error message
				return false, currentCharacter
			end

			nextCharacter, nextIndex = false
			if index + 1 < endIndex then
				nextIndex = index + 1
				-- TO DO: Improve how it's checked, or else it will always calculate the value twice
				nextIndex, nextCharacter, isEscaped = getCharacterConsideringEscapedElements(
					expression[nextIndex], nextIndex, expression)

				if not nextIndex then
					-- nextCharacter = error message
					return false, nextCharacter
				end
			end

			if currentCharacter.type == ENUM_ELEMENT_TYPE_SET then
				set.classIndex = set.classIndex + 1
				set.classes[set.classIndex] = currentCharacter

			-- assume that currentCharacter == ENUM_SET_RANGE_SEPARATOR
			elseif watchForRangeSeparator then
				watchForRangeSeparator = false

				-- having the first condition to check if the char is a set,
				-- then it won't fall in this condition ever
				-- and when only the next char is a set, then .type ~= nil
				-- so the reason for this comparison is that
				-- it can only be a range when both .type are nil, this nil == nil == true
				if nextCharacter and (lastCharacter.type == nextCharacter.type == true) then
					-- Lua can perform string comparisons natively
					if lastCharacter > nextCharacter then
						return false, errorsEnum.unorderedSetRange
					end

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = lastCharacter

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = nextCharacter

					-- Skip next delim
					index = nextIndex or (index + 1)
				else
					set[lastCharacter] = true
					set[currentCharacter] = true
				end
			elseif not isEscaped and nextCharacter == ENUM_SET_RANGE_SEPARATOR then
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