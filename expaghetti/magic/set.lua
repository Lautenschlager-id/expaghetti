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

local findMagicClosingIndex = function(index, tokens)
	local firstCharacter = index
	local positionDiff = 0

	local token
	repeat
		token = tokens[index]

		-- expression ended but magic was never closed
		if not token then
			return false, errorsEnum.unclosedSet
		elseif index == firstCharacter and token.raw == ENUM_NEGATE_SET then
			positionDiff = 1
		elseif token.raw == ENUM_CLOSE_SET and (index - firstCharacter) > positionDiff then
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

	local endIndex, errorMessage = findMagicClosingIndex(state.index, state.tokens)
	if not endIndex then
		return false, errorMessage
	end

	-- Set boundary [index, endIndex)
	endIndex = endIndex - 1

	local set = AST.Set()
	if state.flags.i then
		set.isCaseInsensitive = true
	end

	local watchingForRangeSeparator
	local currentToken, lastToken, rangeInitChar, currentCharacterValue

	local elementIndex = state.index - 1
	repeat
		elementIndex = elementIndex + 1
		currentToken = state.tokens[elementIndex]

		-- first character of the set
		if elementIndex == state.index and currentToken.raw == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		elseif type(currentToken.raw) == "table" and currentToken.raw.type == ENUM_ELEMENT_TYPE_SET then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = currentToken.raw
		else
			local nextToken, rangeEndChar
			if endIndex > elementIndex then
				nextToken = state.tokens[elementIndex + 1]
				rangeEndChar = nextToken.value
			end
			currentCharacterValue = currentToken.value

			-- assumes that currentToken.raw == ENUM_SET_RANGE_SEPARATOR
			if watchingForRangeSeparator then
				watchingForRangeSeparator = false
				rangeInitChar = state.tokens[elementIndex - 1].value

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
			elseif nextToken and nextToken.raw == ENUM_SET_RANGE_SEPARATOR then
				watchingForRangeSeparator = true
			else
				set[currentCharacterValue] = true
			end
		end

		lastToken = currentToken
	until elementIndex == endIndex

	tree._index = tree._index + 1
	tree[tree._index] = set

	-- skip magic closing (+ 1 to undo the boundary, then + 1)
	return endIndex + 2
end

return Set