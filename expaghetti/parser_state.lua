----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
local flagsEnum = require("./enums/flags").flags
local ENUM_FLAG_UNICODE = flagsEnum.UNICODE
local ENUM_FLAG_CASE_INSENSITIVE = flagsEnum.CASE_INSENSITIVE
----------------------------------------------------------------------------------------------------
local ParserState = {}
ParserState.__index = ParserState

function ParserState.new(expr, flags, isGroup, isAlternate, index, patternChars, patternLength, metaData, hasGroupClosed)
	local self = setmetatable({}, ParserState)
	self.expr = expr
	self.flags = {}
	if type(flags) == "string" then
		for char in flags:gmatch(".") do
			self.flags[char] = true
		end
	elseif type(flags) == "table" then
		for k, v in pairs(flags) do
			self.flags[k] = v
		end
	end
	self.isGroup = isGroup
	self.isAlternate = isAlternate
	self.index = index or 1
	self.patternChars = patternChars
	self.patternLength = patternLength
	
	if metaData then
		self.metaData = metaData
	else
		self.metaData = {
			groupNames = {},
			groupIndex = 0,
			positionCaptureIndex = 0,
			groupTreesByIndex = {},
			groupTreesByName = {},
		}
	end
	if isGroup and hasGroupClosed == nil then
		self.hasGroupClosed = false
	else
		self.hasGroupClosed = hasGroupClosed
	end
	self.initialGroupIndex = self.metaData.groupIndex
	return self
end

function ParserState:readElement(index, isInsideSet)
	local char = self.patternChars[index]
	if Escaped.isToken(char) then
		return Escaped.parse(self, index, self.patternChars, isInsideSet)
	else
		return index + 1, char
	end
end

function ParserState:fork(isGroup, isAlternate, hasGroupClosed, isBranchReset)
	local child = setmetatable({}, ParserState)
	child.expr = self.expr
	child.flags = self.flags
	child.isGroup = isGroup
	child.isAlternate = isAlternate
	child.index = self.index
	child.patternChars = self.patternChars
	child.patternLength = self.patternLength
	child.metaData = self.metaData
	if isGroup and hasGroupClosed == nil then
		child.hasGroupClosed = false
	else
		child.hasGroupClosed = hasGroupClosed
	end
	child.initialGroupIndex = self.initialGroupIndex
	child.isBranchReset = isBranchReset
	return child
end

function ParserState:parseSubTree(isGroup, isAlternate, hasGroupClosed, isBranchReset)
	-- To avoid circular dependency, we require parser dynamically, or inject it
	local parser = require("./parser")
	local childState = self:fork(isGroup, isAlternate, hasGroupClosed, isBranchReset)
	local tree, errorMessage = parser(childState)

	if not tree then
		return false, errorMessage
	end

	self.index = childState.index
	if hasGroupClosed ~= nil then
		self.hasGroupClosed = childState.hasGroupClosed
	end

	return tree
end

function ParserState:isElement(element)
	return element and (not not element.type)
end

function ParserState:getExecutionValues(char, isInsideSet)
	local hasFlagUnicode = self.flags[ENUM_FLAG_UNICODE]
	local returnString = hasFlagUnicode or isInsideSet
	local lowerChar, upperChar

	if self.flags[ENUM_FLAG_CASE_INSENSITIVE] then
		lowerChar = string.lower(char)
		upperChar = string.upper(char)

		lowerChar = returnString and lowerChar or string.byte(lowerChar)
		upperChar = returnString and upperChar or string.byte(upperChar)
	end
	char = returnString and char or string.byte(char)

	return char, lowerChar, upperChar
end

function ParserState:compileSet(set)
	local values = {}

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

function ParserState:applyInlineFlags(flagConfig)
	local flags = self.flags

	for flag in pairs(flagConfig.enable) do
		flags[flag] = true
	end

	for flag in pairs(flagConfig.disable) do
		flags[flag] = nil
	end
end

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

function ParserState:popScopedFlags(previousFlags)
	self.flags = previousFlags
end

return ParserState
