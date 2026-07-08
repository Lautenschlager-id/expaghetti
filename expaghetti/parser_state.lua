----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
local flagsEnum = require("./enums/flags")
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
	
	self.hasGroupClosed = hasGroupClosed
	self.initialGroupIndex = self.metaData.groupIndex
	return self
end

function ParserState:readElement(index)
	local char = self.patternChars[index]
	if Escaped.isToken(char) then
		return Escaped.parse(self, index, self.patternChars)
	else
		return index + 1, char
	end
end

function ParserState:parseSubTree(isGroup, isAlternate, hasGroupClosed, isBranchReset)
	-- To avoid circular dependency, we require parser dynamically, or inject it
	local parser = require("./parser")
	local tree, nextIndex, newHasGroupClosed = parser(
		nil, nil,
		isGroup, isAlternate,
		self.index, self.patternChars, self.patternLength,
		self.metaData,
		hasGroupClosed,
		self.flags,
		isBranchReset
	)
	if not tree then
		return false, nextIndex
	end
	self.index = nextIndex
	if hasGroupClosed ~= nil then
		self.hasGroupClosed = newHasGroupClosed
	end
	return tree
end

function ParserState:isElement(element)
	return type(element) == "table"
end

function ParserState:getCharacterValue(element)
	if type(element) == "table" then
		return element.value
	end
	return element
end

function ParserState:getExecutionValues(char)
	local hasFlagUnicode = self.flags[ENUM_FLAG_UNICODE]
	local lowerChar, upperChar

	if self.flags[ENUM_FLAG_CASE_INSENSITIVE] then
		lowerChar = string.lower(char)
		upperChar = string.upper(char)

		lowerChar = hasFlagUnicode and lowerChar or string.byte(lowerChar)
		upperChar = hasFlagUnicode and upperChar or string.byte(upperChar)
	end
	char = hasFlagUnicode and char or string.byte(char)

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

return ParserState
