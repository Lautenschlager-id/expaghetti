--[[
    Parser and matcher for character sets (`[...]`).

    Supports literal characters, ranges, nested character classes,
    and negated sets.
]]

--[[ Dependencies ]]--
local SetNode = require("ast").Set

--[[ Enums ]]--
local Elements = require("enums.elements")
local Errors = require("enums.errors")
local Magic = require("enums.magic")

--[[ Aliases ]]--
local ELEMENT_SET = Elements.SET

local ERROR_UNTERMINATED_SET = Errors.unterminatedSet
local ERROR_UNORDERED_SET_RANGE = Errors.unorderedSetRange

local MAGIC_SET_CLOSE = Magic.SET_CLOSE
local MAGIC_SET_OPEN = Magic.SET_OPEN

local MAGIC_SET_NEGATE_PREFIX = Magic.SET_NEGATE_PREFIX
local MAGIC_SET_RANGE_SEPARATOR = Magic.SET_RANGE_SEPARATOR

--[[ Module ]]--
local Set = {}

--[[ Private Functions ]]--

--- Finds the closing delimiter of a character set.
---@param state ParserState The current parser state.
---@param startIndex number The parser index immediately after the opening delimiter.
---@return number|false endIndex The index of the closing delimiter, or false if none was found.
---@return string|nil errorMessage The parser error message on failure.
local findSetClosingIndex = function(state, startIndex)
	local currentIndex = startIndex

	local nextIndex, element = state:readElement(currentIndex, true)
	if element == MAGIC_SET_NEGATE_PREFIX then
		currentIndex = nextIndex
	end

	-- Skip the mandatory first character of the set.
	local nextIndex = state:readElement(currentIndex, true)
	if not nextIndex then
		return false, ERROR_UNTERMINATED_SET
	end

	local statePatternLength = state.patternLength
	currentIndex = nextIndex
	while currentIndex <= statePatternLength do
		local nextIndex, element = state:readElement(currentIndex, true)

		if element == MAGIC_SET_CLOSE then
			return currentIndex
		end

		currentIndex = nextIndex
	end

	return false, ERROR_UNTERMINATED_SET
end

--- Adds a character range to a set.
---@param set SetNode The set being built.
---@param startChar string|number The first character of the range.
---@param endChar string|number The last character of the range.
local addRange = function(set, startChar, endChar)
	local rangeIndex = set.rangeIndex + 1
	local ranges = set.ranges

	ranges[rangeIndex] = startChar
	
	rangeIndex = rangeIndex + 1
	ranges[rangeIndex] = endChar

	set.rangeIndex = rangeIndex
end

--[[ Public API ]]--

--- Returns whether a character starts a character set.
---@param currentCharacter string The current pattern character.
---@return boolean isSet Whether the character starts a character set.
Set.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_SET_OPEN
end

--- Returns whether an AST element is a character set node.
---@param currentElement table The AST element to test.
---@return boolean isSet Whether the element is a character set node.
Set.isElement = function(currentElement)
	return currentElement.type == ELEMENT_SET
end

--- Parses a character set.
---@param state ParserState The current parser state.
---@param tree ASTTree The AST tree being built.
---@return string|nil errorMessage The parser error message on failure.
Set.parse = function(state, tree)
	-- skip magic opening
	state.index = state.index + 1

	local endIndex, errorMessage = findSetClosingIndex(state, state.index)
	if not endIndex then
		return errorMessage
	end

	-- Set boundary [index, endIndex)
	endIndex = endIndex - 1

	local set = SetNode()
	local isCaseInsensitive = state.flags.i

	local watchingForRangeSeparator
	local rangeInitChar

	local setValues = set.values

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
			local classIndex = set.classIndex + 1
			set.classIndex = classIndex
			set.classes[classIndex] = element
		else
			local currentCharacterValue = element.value or state:getExecutionValues(element, true)
			local skipCount, nextTokenValue, nextTokenIsRangeSep = 0

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
					elementIndex = elementIndex + skipCount
				else
					setValues[rangeInitChar] = true
					setValues[currentCharacterValue] = true
				end

				rangeInitChar = nil
			elseif nextTokenIsRangeSep then
				rangeInitChar = currentCharacterValue
			else
				setValues[currentCharacterValue] = true
			end
		end
	end
	
	state:compileSet(set)

	local treeIndex = tree._index + 1
	tree._index = treeIndex
	tree[treeIndex] = set

	-- skip magic closing (+ 1 to undo the boundary, then + 1)
	state.index = endIndex + 2
	return nil
end

--- Matches a character set against the target character.
---@param currentElement SetNode The character set AST node.
---@param state MatchState Unused matcher state.
---@param currentCharacter string|number|nil The current target character.
---@return boolean hasMatched Whether the character matched the set.
Set.match = function(currentElement, _, currentCharacter)
	local hasMatched = not not currentElement.values[currentCharacter]

	if not hasMatched then
		local SetMatch = Set.match
		local ranges = currentElement.ranges
		for rangeIndex = 1, #ranges, 2 do
			local rangeStart = ranges[rangeIndex]
			local rangeEnd = ranges[rangeIndex + 1]
			
			if currentCharacter >= rangeStart and currentCharacter <= rangeEnd then
				hasMatched = true
				break
			end
		end

		if not hasMatched then
			local classes = currentElement.classes
			for classIndex = 1, currentElement.classIndex do
				if SetMatch(classes[classIndex], _, currentCharacter) then
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