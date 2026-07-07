----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local AST = require("./ast")
local Escaped = require("./magic/escaped")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_SET = magicEnum.OPEN_SET
local ENUM_CLOSE_SET = magicEnum.CLOSE_SET
local ENUM_NEGATE_SET = magicEnum.NEGATE_SET
local ENUM_SET_RANGE_SEPARATOR = magicEnum.SET_RANGE_SEPARATOR
local ENUM_ELEMENT_TYPE_SET = require("./enums/elements").set
----------------------------------------------------------------------------------------------------
local Set = { }

local findMagicClosingIndex = function(index, patternChars, patternLength)
	local firstCharacter = index
	local positionDiff = 0

	while index <= patternLength do
		local char = patternChars[index]
		
		if Escaped.isToken(char) then
			-- Skip the escape and the escaped character
			index = index + 2
		else
			if index == firstCharacter and char == ENUM_NEGATE_SET then
				positionDiff = 1
			elseif char == ENUM_CLOSE_SET and (index - firstCharacter) > positionDiff then
				return index
			end
			index = index + 1
		end
	end
	
	return false, errorsEnum.unclosedSet
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

	local endIndex, errorMessage = findMagicClosingIndex(state.index, state.patternChars, state.patternLength)
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
	local rangeInitChar, currentCharacterValue

	local elementIndex = state.index - 1
	repeat
		elementIndex = elementIndex + 1
		local char = state.patternChars[elementIndex]
		local isClass, classNode, charValue, isRangeSeparator, isEscapedLiteral
		local originalElementIndex = elementIndex

		if Escaped.isToken(char) then
			local nextIndex, parsedElement = Escaped.parse(elementIndex, state.patternChars)
			if not nextIndex then return false, parsedElement end
			if parsedElement.type == ENUM_ELEMENT_TYPE_SET then
				isClass = true
				classNode = parsedElement
			else
				charValue = parsedElement.value
				isEscapedLiteral = true
			end
			elementIndex = nextIndex - 1
		else
			charValue = char
			if char == ENUM_SET_RANGE_SEPARATOR then
				isRangeSeparator = true
			end
		end

		-- first character of the set
		if not isEscapedLiteral and originalElementIndex == state.index and charValue == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		elseif isClass then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = classNode
		else
			local nextTokenValue, nextTokenIsRangeSep, skipCount
			if endIndex > elementIndex then
				local nextChar = state.patternChars[elementIndex + 1]
				if Escaped.isToken(nextChar) then
					local parsedNextIndex, parsedElement = Escaped.parse(elementIndex + 1, state.patternChars)
					if parsedElement and parsedElement.type ~= ENUM_ELEMENT_TYPE_SET then
						nextTokenValue = parsedElement.value
						skipCount = parsedNextIndex - (elementIndex + 1)
					end
				else
					nextTokenValue = nextChar
					if nextChar == ENUM_SET_RANGE_SEPARATOR then
						nextTokenIsRangeSep = true
					end
					skipCount = 1
				end
			end
			currentCharacterValue = charValue

			if watchingForRangeSeparator then
				watchingForRangeSeparator = false

				-- both the last and next characters must be literals
				if nextTokenValue and rangeInitChar then
					if rangeInitChar > nextTokenValue then
						return false, errorsEnum.unorderedSetRange
					end

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = rangeInitChar

					set.rangeIndex = set.rangeIndex + 1
					set.ranges[set.rangeIndex] = nextTokenValue

					-- skip next element(s)
					elementIndex = elementIndex + skipCount
				else
					set[rangeInitChar] = true
					set[currentCharacterValue] = true
				end
			elseif nextTokenIsRangeSep then
				watchingForRangeSeparator = true
				rangeInitChar = currentCharacterValue
			else
				set[currentCharacterValue] = true
			end
		end

	until elementIndex == endIndex

	tree._index = tree._index + 1
	tree[tree._index] = set

	-- skip magic closing (+ 1 to undo the boundary, then + 1)
	return endIndex + 2
end

return Set