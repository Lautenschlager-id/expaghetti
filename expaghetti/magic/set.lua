--[[
    Parses set elements.
]]

--[[ Dependencies ]]--
local magicEnum = require("enums.magic")
local errorsEnum = require("enums.errors")
local elementsEnum = require("enums.elements")
local AST = require("ast")

--[[ Enum Aliases ]]--
local MAGIC_SET_OPEN = magicEnum.SET_OPEN
local MAGIC_SET_CLOSE = magicEnum.SET_CLOSE
local MAGIC_SET_NEGATE_PREFIX = magicEnum.SET_NEGATE_PREFIX
local MAGIC_SET_RANGE_SEPARATOR = magicEnum.SET_RANGE_SEPARATOR
local ELEMENT_SET = elementsEnum.SET
local ERROR_UNCLOSED_SET = errorsEnum.unterminatedSet
local ERROR_UNORDERED_SET_RANGE = errorsEnum.unorderedSetRange

--[[ Module ]]--
local Set = {}

--[[ Private Functions ]]--
local findSetClosingIndex = function(state, startIndex)
	local currentIndex = startIndex

	local nextIndex, element = state:readElement(currentIndex, true)
	if element == MAGIC_SET_NEGATE_PREFIX then
		currentIndex = nextIndex
	end

	-- Skip the mandatory first character of the set.
	local nextIndex = state:readElement(currentIndex, true)
	if not nextIndex then
		return false, ERROR_UNCLOSED_SET
	end

	currentIndex = nextIndex
	while currentIndex <= state.patternLength do
		local nextIndex, element = state:readElement(currentIndex, true)

		if element == MAGIC_SET_CLOSE then
			return currentIndex
		end

		currentIndex = nextIndex
	end

	return false, ERROR_UNCLOSED_SET
end

local addRange = function(set, startChar, endChar)
	set.rangeIndex = set.rangeIndex + 1
	set.ranges[set.rangeIndex] = startChar
	
	set.rangeIndex = set.rangeIndex + 1
	set.ranges[set.rangeIndex] = endChar
end

--[[ Public API ]]--
Set.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_SET_OPEN
end

Set.isElement = function(currentElement)
	return currentElement.type == ELEMENT_SET
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
		if originalElementIndex == state.index and element == MAGIC_SET_NEGATE_PREFIX then
			set.hasToNegateMatch = true
		elseif element.type == ELEMENT_SET then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = element
		else
			local currentCharacterValue = element.value or state:getExecutionValues(element, true)
			local nextTokenValue, nextTokenIsRangeSep, skipCount

			if endIndex >= elementIndex then
				local peekIndex, nextElement = state:readElement(elementIndex, true)

				if nextElement then
					skipCount = peekIndex - elementIndex
					nextTokenIsRangeSep = nextElement == MAGIC_SET_RANGE_SEPARATOR

					nextTokenValue = (nextElement.type ~= ELEMENT_SET) and (
						nextElement.value or state:getExecutionValues(nextElement, true)
					) or nil
				end
			end
			
			if rangeInitChar then
				-- both the last and next characters must be literals
				if nextTokenValue then
					if rangeInitChar > nextTokenValue then
						return ERROR_UNORDERED_SET_RANGE
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

Set.match = function(currentElement, _, currentCharacter)
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
				if Set.match(classes[classIndex], _, currentCharacter) then
					hasMatched = true
					break
				end
			end
		end
	end

	return currentElement.hasToNegateMatch ~= hasMatched
end

--[[ Return ]]--
return Set