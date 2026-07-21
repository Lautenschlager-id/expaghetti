----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("helpers.string").splitStringByEachChar
local Escaped = require("magic.escaped")
local flagsEnum = require("enums.flags").flags
local ENUM_FLAG_UNICODE = flagsEnum.UNICODE
local ENUM_FLAG_CASE_INSENSITIVE = flagsEnum.CASE_INSENSITIVE
----------------------------------------------------------------------------------------------------
local ParserState = {
	parser = nil
}
ParserState.__index = ParserState

--- Creates a new ParserState instance for parsing a regex expression.
---@param expr string|table The regular expression string.
---@param flags string|table|nil A string of flag characters or a table of boolean flags.
---@return table ParserState The instantiated ParserState object.
function ParserState.new(expr, flags)
	local self = setmetatable({}, ParserState)

	self.expr = expr

	self.flags = {}
	if flags then
		if type(flags) == "string" then 
			for char in flags:gmatch(".") do
				self.flags[char] = true
			end
		elseif type(flags) == "table" then
			for k, v in pairs(flags) do
				self.flags[k] = v
			end
		end
	end

	self.isGroup = false
	self.isAlternate = false
	self.isBranchReset = false

	self.initialGroupIndex = 0

	self.metaData = {
		groupNames = {},
		groupIndex = 0,
		positionCaptureIndex = 0,
		groupTreesByIndex = {},
		groupTreesByName = {},
	}

	self.index = 1
	self.patternChars, self.patternLength = splitStringByEachChar(expr, not not self.flags[ENUM_FLAG_UNICODE])

	return self
end

--- Reads the next element or character from the pattern.
---@param index number The current index in the pattern characters.
---@param isInsideSet boolean|nil True if currently parsing inside a character set (e.g. `[]`).
---@return number|boolean nextIndex The next index after reading, or false if reading failed.
---@return string|table token The read character, or a parsed token (e.g., an escaped character).
function ParserState:readElement(index, isInsideSet)
	local char = self.patternChars[index]
	if Escaped.isToken(char) then
		return Escaped.parse(self, index, self.patternChars, isInsideSet)
	else
		return index + 1, char
	end
end

--- Branches the current parser state into a child state, inheriting current context.
---@return table ParserState The newly forked child state.
function ParserState:fork()
	local child = setmetatable({}, ParserState)

	child.expr = self.expr

	child.flags = self.flags

	child.isGroup = self.isGroup
	child.isAlternate = self.isAlternate
	child.isBranchReset = self.isBranchReset

	child.initialGroupIndex = self.initialGroupIndex

	child.metaData = self.metaData

	child.index = self.index
	child.patternChars = self.patternChars
	child.patternLength = self.patternLength

	return child
end

--- Parses a sub-tree using a child state.
---@param childState table The forked ParserState to parse with.
---@return table|boolean tree The generated AST tree, or false if an error occurred.
---@return string|table|nil errorMessage An error message if parsing failed.
function ParserState:parseSubTree(childState)
	local tree, errorMessage = ParserState.parser(childState)

	if not tree then
		return false, errorMessage
	end

	self.index = childState.index

	return tree
end

--- Checks if a given object is a parsed element (has a `type`).
---@param element table|string The object to check.
---@return boolean isElement True if it is a parsed element table.
function ParserState:isElement(element)
	return element and (not not element.type)
end

--- Retrieves the execution values for a character based on active flags (e.g. case insensitive).
---@param char string The character to process.
---@param isInsideSet boolean|nil True if inside a character set.
---@return string|number value The primary character value or byte.
---@return string|number|nil lowerValue The lowercase value or byte, if case insensitive.
---@return string|number|nil upperValue The uppercase value or byte, if case insensitive.
function ParserState:getExecutionValues(char, isInsideSet)
	-- Determine whether we should work with Lua strings or numerical bytes.
	-- If the UNICODE flag is present or we are inside a character set (where chars might represent byte classes),
	-- we retain the string representation. Otherwise, we operate directly on numeric bytes for performance.
	local hasFlagUnicode = self.flags[ENUM_FLAG_UNICODE]
	local returnString = hasFlagUnicode or isInsideSet
	local lowerChar, upperChar

	if self.flags[ENUM_FLAG_CASE_INSENSITIVE] then
		-- When case-insensitive, we must track both the upper and lower variants.
		-- This essentially splits a single character match into a branching dual-match.
		lowerChar = string.lower(char)
		upperChar = string.upper(char)

		lowerChar = returnString and lowerChar or string.byte(lowerChar)
		upperChar = returnString and upperChar or string.byte(upperChar)
	end
	char = returnString and char or string.byte(char)

	return char, lowerChar, upperChar
end

--- Compiles a parsed Set element by populating its internal structures based on character execution values.
---@param set table The Set element to compile.
function ParserState:compileSet(set)
	local values = {}

	-- Step 1: Compile discrete character values.
	-- Iterate through all individual characters in the parsed set, fetch their normalized
	-- execution forms (accounting for case-insensitivity), and add them to the fast-lookup hash map.
	for char in pairs(set.values) do
		local value, lowerValue, upperValue = self:getExecutionValues(char)

		if lowerValue then
			values[lowerValue] = true
			values[upperValue] = true
		else
			values[value] = true
		end
	end

	set.values = values

	local ranges, index = {}, 0

	-- Step 2: Compile contiguous character ranges (e.g., `a-z`, `0-9`).
	-- The AST stores these as pairs of start/end values in `set.ranges`.
	-- If case insensitivity is enabled, a single range (like `A-Z`) effectively becomes TWO ranges 
	-- (e.g., `a-z` and `A-Z`) in the compiled execution array.
	for i = 1, set.rangeIndex, 2 do
		local startValue, startLower, startUpper = self:getExecutionValues(set.ranges[i])
		local endValue, endLower, endUpper = self:getExecutionValues(set.ranges[i + 1])

		index = index + 1
		if startLower then
			ranges[index] = startLower
			index = index + 1
			ranges[index] = endLower

			index = index + 1
			ranges[index] = startUpper
			index = index + 1
			ranges[index] = endUpper
		else
			ranges[index] = startValue
			index = index + 1
			ranges[index] = endValue
		end
	end

	set.ranges = ranges
	set.rangeIndex = index
end

--- Applies inline flag modifications to the current state.
---@param flagConfig table A table with `enable` and `disable` sets of flags.
function ParserState:applyInlineFlags(flagConfig)
	local flags = self.flags

	for flag in pairs(flagConfig.enable) do
		flags[flag] = true
	end

	for flag in pairs(flagConfig.disable) do
		flags[flag] = nil
	end
end

--- Pushes a new scoped flag configuration and returns the previous flags.
---@param flagConfig table A table with `enable` and `disable` sets of flags.
---@return table previousFlags The flags table before modifications.
function ParserState:pushScopedFlags(flagConfig)
	local previousFlags = self.flags

	local flags = {}
	self.flags = flags

	for flag, value in pairs(previousFlags) do
		flags[flag] = value
	end

	self:applyInlineFlags(flagConfig)
	return previousFlags
end

--- Restores flags from a previously pushed scope.
---@param previousFlags table The saved flags to restore.
function ParserState:popScopedFlags(previousFlags)
	self.flags = previousFlags
end

return ParserState
