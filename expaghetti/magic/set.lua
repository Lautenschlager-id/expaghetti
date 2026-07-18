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
----------------------------------------------------------------------------------------------------
local findSetClosingIndex = function(state, startIndex)
	local currentIndex = startIndex

	local nextIndex, element = state:readElement(currentIndex, true)
	if element == ENUM_NEGATE_SET then
		currentIndex = nextIndex
	end

	-- Skip the mandatory first character of the set.
	local nextIndex = state:readElement(currentIndex, true)
	if not nextIndex then
		return false, errorsEnum.unclosedSet
	end

	currentIndex = nextIndex
	while currentIndex <= state.patternLength do
		local nextIndex, element = state:readElement(currentIndex, true)

		if element == ENUM_CLOSE_SET then
			return currentIndex
		end

		currentIndex = nextIndex
	end

	return false, errorsEnum.unclosedSet
end

local addRange = function(set, startChar, endChar)
	set.rangeIndex = set.rangeIndex + 1
	set.ranges[set.rangeIndex] = startChar
	
	set.rangeIndex = set.rangeIndex + 1
	set.ranges[set.rangeIndex] = endChar
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

	local endIndex, errorMessage = findSetClosingIndex(state, state.index)
	if not endIndex then
		return errorMessage
	end

	-- Set boundary [index, endIndex)
	endIndex = endIndex - 1

	local set = AST.Set()
	local isCaseInsensitive = state.flags.i

	local watchingForRangeSeparator
	local rangeInitChar

	local elementIndex = state.index
	while elementIndex <= endIndex do
		local originalElementIndex = elementIndex

		local nextIndex, element = state:readElement(elementIndex, true)
		if not nextIndex then
			return element
		end

		elementIndex = nextIndex

		-- first character of the set
		if originalElementIndex == state.index and element == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		elseif element.type == ENUM_ELEMENT_TYPE_SET then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = element
		else
			local currentCharacterValue = element.value or state:getExecutionValues(element, true)
			local nextTokenValue, nextTokenIsRangeSep, skipCount

			if endIndex >= elementIndex then
				local peekIndex, nextElement = state:readElement(elementIndex, true)

				if nextElement then
					skipCount = peekIndex - elementIndex
					nextTokenIsRangeSep = nextElement == ENUM_SET_RANGE_SEPARATOR

					nextTokenValue = (nextElement.type ~= ENUM_ELEMENT_TYPE_SET) and (
						nextElement.value or state:getExecutionValues(nextElement, true)
					) or nil
				end
			end
			
			if rangeInitChar then
				-- both the last and next characters must be literals
				if nextTokenValue then
					if rangeInitChar > nextTokenValue then
						return errorsEnum.unorderedSetRange
					end

					addRange(set, rangeInitChar, nextTokenValue)

					-- skip next element(s)
					elementIndex = elementIndex + (skipCount or 0)
				else
					set.values[rangeInitChar] = true
					set.values[currentCharacterValue] = true
				end

				rangeInitChar = nil
			elseif nextTokenIsRangeSep then
				rangeInitChar = currentCharacterValue
			else
				set.values[currentCharacterValue] = true
			end
		end
	end
	
	state:compileSet(set)

	tree._index = tree._index + 1
	tree[tree._index] = set

	-- skip magic closing (+ 1 to undo the boundary, then + 1)
	state.index = endIndex + 2
	return nil
end

Set.match = function(currentElement, currentCharacter)
	local hasMatched = not not currentElement.values[currentCharacter]

	if not hasMatched then
		local ranges = currentElement.ranges
		for rangeIndex = 1, #ranges, 2 do
			local rStart = ranges[rangeIndex]
			local rEnd = ranges[rangeIndex + 1]
			
			if currentCharacter >= rStart and currentCharacter <= rEnd then
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