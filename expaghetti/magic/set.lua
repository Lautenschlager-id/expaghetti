----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_SET = magicEnum.OPEN_SET
local ENUM_CLOSE_SET = magicEnum.CLOSE_SET
local ENUM_NEGATE_SET = magicEnum.NEGATE_SET
local ENUM_SET_RANGE_SEPARATOR = magicEnum.SET_RANGE_SEPARATOR
local ENUM_ELEMENT_TYPE_SET = require("./enums/elements").set
----------------------------------------------------------------------------------------------------
local Set = { }

local findMagicClosingIndex = function(index, charactersList)
	local firstCharacter = index
	local positionDiff = 0

	local currentCharacter
	repeat
		currentCharacter = charactersList[index]

		-- expression ended but magic was never closed
		if not currentCharacter then
			return false, errorsEnum.unclosedSet
		elseif index == firstCharacter and currentCharacter == ENUM_NEGATE_SET then
			positionDiff = 1
		elseif currentCharacter == ENUM_CLOSE_SET and (index - firstCharacter) > positionDiff then
			return index
		end

		index = index + 1
	until false
end
----------------------------------------------------------------------------------------------------
Set.isToken = function(currentCharacter)
	return currentCharacter == ENUM_OPEN_SET
end

Set.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_SET
end

Set.parse = function(state, tree)
	-- skip magic opening
	state.index = state.index + 1

	local endIndex, errorMessage = findMagicClosingIndex(state.index, state.charactersList)
	if not endIndex then
		-- state.charactersList = error message
		return false, errorMessage
	end

	-- Set boundary [index, endIndex)
	endIndex = endIndex - 1

	local set = AST.Set()

	local watchingForRangeSeparator
	local currentCharacter, lastCharacter, rangeInitChar, currentCharacterValue

	local elementIndex = state.index - 1
	repeat
		elementIndex = elementIndex + 1
		currentCharacter = state.charactersList[elementIndex]

		-- first character of the set
		if elementIndex == state.index and currentCharacter == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		elseif currentCharacter.type == ENUM_ELEMENT_TYPE_SET then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = currentCharacter
		else
			local nextCharacter, rangeEndChar
			if endIndex > elementIndex then
				nextCharacter = state.charactersList[elementIndex + 1]
				rangeEndChar = state.charactersValueList[elementIndex + 1]
			end
			currentCharacterValue = state.charactersValueList[elementIndex]

			-- assumes that currentCharacter == ENUM_SET_RANGE_SEPARATOR
			if watchingForRangeSeparator then
				watchingForRangeSeparator = false
				rangeInitChar = state.charactersValueList[elementIndex - 1]

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

Set.match = function(currentElement, currentCharacter)
	local hasMatched = false

	if currentElement[currentCharacter] then
		hasMatched = true
	else
		local ranges = currentElement.ranges
		for rangeIndex = 1, currentElement.rangeIndex, 2 do
			if currentCharacter >= ranges[rangeIndex]
				and currentCharacter <= ranges[rangeIndex + 1] then

				hasMatched = true
				break
			end
		end

		if not hasMatched then
			local classes = currentElement.classes
			for classIndex = 1, currentElement.classIndex do
				if Set.match(classes[classIndex], currentCharacter) then
					hasMatched = true
					break
				end
			end
		end
	end

	return currentElement.hasToNegateMatch ~= hasMatched
end

return Set