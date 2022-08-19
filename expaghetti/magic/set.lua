----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_SET = magicEnum.OPEN_SET
local ENUM_CLOSE_SET = magicEnum.CLOSE_SET
local ENUM_NEGATE_SET = magicEnum.NEGATE_SET
local ENUM_SET_RANGE_SEPARATOR = magicEnum.SET_RANGE_SEPARATOR
local ENUM_ELEMENT_TYPE_SET = require("./enums/elements").set
----------------------------------------------------------------------------------------------------
local Set = { }

local findMagicClosingIndex = function(index, charactersList)
	local currentCharacter
	repeat
		currentCharacter = charactersList[index]

		-- expression ended but magic was never closed
		if not currentCharacter then
			return false, errorsEnum.unclosedSet
		elseif currentCharacter == ENUM_CLOSE_SET then
			return index
		end

		index = index + 1
	until false
end
----------------------------------------------------------------------------------------------------
Set.is = function(currentCharacter)
	return currentCharacter == ENUM_OPEN_SET
end

Set.execute = function(currentCharacter, index, charactersList, charactersValueList, tree)
	-- skip magic opening
	index = index + 1

	local endIndex, errorMessage = findMagicClosingIndex(index, charactersList)
	if not endIndex then
		-- charactersList = error message
		return false, errorMessage

	-- Empty set
	elseif index == endIndex then
		return false, errorsEnum.emptySet
	end

	-- Set boundary [index, endIndex)
	endIndex = endIndex - 1

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

			quantifier = nil,

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

	local watchingForRangeSeparator
	local lastCharacter, rangeInitChar, currentCharacterValue

	local elementIndex = index - 1
	repeat
		elementIndex = elementIndex + 1
		currentCharacter = charactersList[elementIndex]

		-- first character of the set
		if elementIndex == index and currentCharacter == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		elseif currentCharacter.type == ENUM_ELEMENT_TYPE_SET then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = currentCharacter
		else
			local nextCharacter, rangeEndChar
			if endIndex > elementIndex then
				nextCharacter = charactersList[elementIndex + 1]
				rangeEndChar = charactersValueList[elementIndex + 1]
			end
			currentCharacterValue = charactersValueList[elementIndex]

			-- assumes that currentCharacter == ENUM_SET_RANGE_SEPARATOR
			if watchingForRangeSeparator then
				watchingForRangeSeparator = false
				rangeInitChar = charactersValueList[elementIndex - 1]

				-- both the last and next characters must be literals
				if rangeEndChar and rangeInitChar then
					-- Lua can perform string comparisons natively
					if rangeInitChar > rangeEndChar then
						return false, errorsEnum.unorderedSetRange
					end

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = rangeInitChar

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = rangeEndChar

					-- Skip next element
					elementIndex = elementIndex + 1
				else
					-- For example, `a-%a`, adds `a` and `-`, and executes `%a` in the next iter
					set[rangeInitChar] = true
					set[currentCharacterValue] = true
				end
			elseif nextCharacter == ENUM_SET_RANGE_SEPARATOR then
				watchingForRangeSeparator = true
			else
				set[currentCharacterValue] = true
			end
		end

		lastCharacter = currentCharacter
	until elementIndex == endIndex

	tree._index = tree._index + 1
	tree[tree._index] = set

	-- skip magic closing (+ 1 to undo the boundary, then + 1)
	return endIndex + 2
end

return Set