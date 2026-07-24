--[[
    Parser state used throughout the parsing process.

    Tracks the current parsing position, flags, shared metadata,
    and parser context.
]]

--[[ Globals ]]--
local next = next
local setmetatable = setmetatable
local string_byte = string.byte
local string_lower = string.lower
local string_upper = string.upper

--[[ Dependencies ]]--
local Escaped = require("magic.escaped")

local toCharArray = require("helpers.string").toCharArray

--[[ Enums ]]--
local Flags = require("enums.flags").FLAGS

--[[ Aliases ]]--
local EscapedIsToken, EscapedParse = Escaped.isToken, Escaped.parse

local FLAG_UNICODE = Flags.UNICODE
local FLAG_CASE_INSENSITIVE = Flags.CASE_INSENSITIVE

--[[ Module ]]--
local ParserState = {
	parser = nil
}
ParserState.__index = ParserState

--- Creates a new ParserState instance for parsing a regular expression.
---@param expr string|table The regular expression string.
---@param flags string|table|nil A string of flag characters or a table of boolean flags.
---@return ParserState state The instantiated parser state.
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

	self.metadata = {
		groupNames = {},
		groupIndex = 0,
		positionCaptureIndex = 0,
		groupTreesByIndex = {},
		groupTreesByName = {},
	}

	self.index = 1
	self.patternChars, self.patternLength = toCharArray(expr, not not self.flags[FLAG_UNICODE])

	return self
end

--- Reads the next element or character from the pattern.
---@param index number The current index in the pattern characters.
---@param isInsideSet boolean|nil True if currently parsing inside a character set (e.g. `[]`).
---@return number|boolean nextIndex The next index after reading, or false if reading failed.
---@return string|ASTElement element The parsed pattern element or raw character.
function ParserState:readElement(index, isInsideSet)
	local patternChars = self.patternChars

	local char = patternChars[index]
	if EscapedIsToken(char) then
		return EscapedParse(self, index, patternChars, isInsideSet)
	else
		return index + 1, char
	end
end

--- Branches the current parser state into a child state, inheriting current context.
---@return ParserState childState The forked parser state.
function ParserState:fork()
	local child = setmetatable({}, ParserState)

	child.expr = self.expr

	child.flags = self.flags

	child.isGroup = self.isGroup
	child.isAlternate = self.isAlternate
	child.isBranchReset = self.isBranchReset

	child.initialGroupIndex = self.initialGroupIndex

	child.metadata = self.metadata

	child.index = self.index
	child.patternChars = self.patternChars
	child.patternLength = self.patternLength

	return child
end

--- Parses a sub-tree using a child state.
---@param childState ParserState The child parser state.
---@return ASTTree|boolean tree The generated AST tree, or false if parsing failed.
---@return string|nil errorMessage The parser error message on failure.
function ParserState:parseSubTree(childState)
	local tree, errorMessage = ParserState.parser(childState)

	if not tree then
		return false, errorMessage
	end

	self.index = childState.index

	return tree
end

--- Returns whether an object is a parsed AST element.
---@param element ASTElement|string The object to test.
---@return boolean isElement Whether the object is a parsed AST element.
function ParserState:isElement(element)
	return element and (not not element.type)
end

--- Retrieves the execution values for a character based on active flags (e.g. case insensitive).
---@param char string The character to process.
---@param isInsideSet boolean|nil True if inside a character set.
---@return string|number executionValue The primary character value or byte.
---@return string|number|nil lowerValue The lowercase value or byte, if case insensitive.
---@return string|number|nil upperValue The uppercase value or byte, if case insensitive.
function ParserState:getExecutionValues(char, isInsideSet)
	local flags = self.flags

	-- Determine whether we should work with Lua strings or numerical bytes.
	-- If the UNICODE flag is present or we are inside a character set (where chars might represent byte classes),
	-- we retain the string representation. Otherwise, we operate directly on numeric bytes for performance.
	local hasFlagUnicode = flags[FLAG_UNICODE]
	local returnString = hasFlagUnicode or isInsideSet
	local lowerChar, upperChar

	if flags[FLAG_CASE_INSENSITIVE] then
		-- When case-insensitive, we must track both the upper and lower variants.
		-- This essentially splits a single character match into a branching dual-match.
		lowerChar = string_lower(char)
		upperChar = string_upper(char)

		lowerChar = returnString and lowerChar or string_byte(lowerChar)
		upperChar = returnString and upperChar or string_byte(upperChar)
	end
	char = returnString and char or string_byte(char)

	return char, lowerChar, upperChar
end

--- Compiles a parsed Set element by populating its internal structures based on character execution values.
---@param set SetNode The character set to compile.
function ParserState:compileSet(set)
	local values = {}

	-- Iterates through all individual characters in the parsed set, fetch their normalized
	-- execution forms (accounting for case-insensitivity), and add them to the fast-lookup hash map.
	for char in next, set.values do
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
	-- Compile contiguous character ranges (e.g., `a-z`, `0-9`).
	-- If case insensitivity is enabled, a single range (like `A-Z`) effectively becomes TWO ranges 
	-- (e.g., `a-z` and `A-Z`) in the compiled execution array.
	local setRanges = set.ranges
	for i = 1, set.rangeIndex, 2 do
		local startValue, startLower, startUpper = self:getExecutionValues(setRanges[i])
		local endValue, endLower, endUpper = self:getExecutionValues(setRanges[i + 1])

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
---@param flagConfig FlagConfiguration The inline flag configuration.
function ParserState:applyInlineFlags(flagConfig)
	local flags = self.flags

	for flag in next, flagConfig.enable do
		flags[flag] = true
	end

	for flag in next, flagConfig.disable do
		flags[flag] = nil
	end
end

--- Pushes a new scoped flag configuration and returns the previous flags.
---@param flagConfig FlagConfiguration The scoped flag configuration.
---@return FlagTable previousFlags The previous flag table.
function ParserState:pushScopedFlags(flagConfig)
	local previousFlags = self.flags

	local flags = {}
	self.flags = flags

	for flag, value in next, previousFlags do
		flags[flag] = value
	end

	self:applyInlineFlags(flagConfig)
	return previousFlags
end

--- Restores flags from a previously pushed scope.
---@param previousFlags FlagTable The flags to restore.
function ParserState:popScopedFlags(previousFlags)
	self.flags = previousFlags
end

return ParserState
