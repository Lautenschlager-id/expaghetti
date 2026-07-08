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

local findMagicClosingIndex = function(state, startIndex)
	local positionDiff = 0
	local elementIndex = startIndex

	while elementIndex <= state.patternLength do
		local nextIndex, element = state:readElement(elementIndex)
		
		if elementIndex == startIndex and element == ENUM_NEGATE_SET then
			positionDiff = 1
		elseif element == ENUM_CLOSE_SET and (elementIndex - startIndex) > positionDiff then
			return elementIndex
		end
		elementIndex = nextIndex
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

local function addKey(set, char, isCaseInsensitive)
	set.keys[char] = true
	set.unicodeKeys[char] = true
	set.byteKeys[string.byte(char)] = true
	
	if isCaseInsensitive then
		local lower = string.lower(char)
		local upper = string.upper(char)
		set.unicodeKeys[lower] = true
		set.unicodeKeys[upper] = true
		set.byteKeys[string.byte(lower)] = true
		set.byteKeys[string.byte(upper)] = true
	end
end

local function addRange(set, startChar, endChar, isCaseInsensitive)
	set.rangeIndex = set.rangeIndex + 1
	set.ranges[set.rangeIndex] = startChar
	set.ranges[set.rangeIndex + 1] = endChar
	
	table.insert(set.unicodeRanges, startChar)
	table.insert(set.unicodeRanges, endChar)
	table.insert(set.byteRanges, string.byte(startChar))
	table.insert(set.byteRanges, string.byte(endChar))
	
	if isCaseInsensitive then
		local lowerStart = string.lower(startChar)
		local lowerEnd = string.lower(endChar)
		local upperStart = string.upper(startChar)
		local upperEnd = string.upper(endChar)
		
		table.insert(set.unicodeRanges, lowerStart)
		table.insert(set.unicodeRanges, lowerEnd)
		table.insert(set.unicodeRanges, upperStart)
		table.insert(set.unicodeRanges, upperEnd)
		
		table.insert(set.byteRanges, string.byte(lowerStart))
		table.insert(set.byteRanges, string.byte(lowerEnd))
		table.insert(set.byteRanges, string.byte(upperStart))
		table.insert(set.byteRanges, string.byte(upperEnd))
	end
end

Set.parse = function(state, tree)
	-- skip magic opening
	state.index = state.index + 1

	local endIndex, errorMessage = findMagicClosingIndex(state, state.index)
	if not endIndex then
		return false, errorMessage
	end

	-- Set boundary [index, endIndex)
	endIndex = endIndex - 1

	local set = AST.Set()
	local isCaseInsensitive = state.flags.i and true or false

	local watchingForRangeSeparator
	local rangeInitChar

	local elementIndex = state.index
	while elementIndex <= endIndex do
		local originalElementIndex = elementIndex
		local nextIndex, element = state:readElement(elementIndex)
		if not nextIndex then return false, element end
		elementIndex = nextIndex

		-- first character of the set
		if originalElementIndex == state.index and element == ENUM_NEGATE_SET then
			set.hasToNegateMatch = true
		elseif element.type == ENUM_ELEMENT_TYPE_SET then
			set.classIndex = set.classIndex + 1
			set.classes[set.classIndex] = element
		else
			local nextTokenValue, nextTokenIsRangeSep, skipCount
			if endIndex >= elementIndex then
				local peekIndex, nextElement = state:readElement(elementIndex)
				if nextElement then
					skipCount = peekIndex - elementIndex
					nextTokenIsRangeSep = nextElement == ENUM_SET_RANGE_SEPARATOR
					nextTokenValue = nextElement.type ~= ENUM_ELEMENT_TYPE_SET and state:getCharacterValue(nextElement) or nil
				end
			end
			local currentCharacterValue = state:getCharacterValue(element)

			if watchingForRangeSeparator then
				watchingForRangeSeparator = false

				-- both the last and next characters must be literals
				if nextTokenValue and rangeInitChar then
					if rangeInitChar > nextTokenValue then
						return false, errorsEnum.unorderedSetRange
					end

					addRange(set, rangeInitChar, nextTokenValue, isCaseInsensitive)

					-- skip next element(s)
					elementIndex = elementIndex + (skipCount or 0)
				else
					addKey(set, rangeInitChar, isCaseInsensitive)
					addKey(set, currentCharacterValue, isCaseInsensitive)
				end
			elseif nextTokenIsRangeSep then
				watchingForRangeSeparator = true
				rangeInitChar = currentCharacterValue
			else
				addKey(set, currentCharacterValue, isCaseInsensitive)
			end
		end

	end

	tree._index = tree._index + 1
	tree[tree._index] = set

	-- skip magic closing (+ 1 to undo the boundary, then + 1)
	return endIndex + 2
end

Set.match = function(currentElement, currentCharacter, state)
	local hasMatched = false
	local keys = state:getExecutionKeys(currentElement)

	if keys[currentCharacter] then
		hasMatched = true
	end

	if not hasMatched then
		local ranges = state:getExecutionRanges(currentElement)
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
				if Set.match(classes[classIndex], currentCharacter, state) then
					hasMatched = true
					break
				end
			end
		end
	end

	return currentElement.hasToNegateMatch ~= hasMatched
end

return Set