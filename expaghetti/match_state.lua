local config = require("./config")
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE

local MatchState = {}
MatchState.__index = MatchState

function MatchState.new(flags, targetString, targetStringChars, targetStringLength, stringIndex, initialStringIndex, rootTree, parsedMetaData)
	local self = setmetatable({}, MatchState)
	
	self.flags = flags or {}
	self.targetStringLength = targetStringLength
	self.stringIndex = stringIndex or 0
	self.initialStringIndex = initialStringIndex or self.stringIndex

	if self.flags[ENUM_FLAG_UNICODE] then
		self.getTargetCharacter = function(self, index) return targetStringChars[index] end
		self.getExecutionValue = function(self, element) return element.unicodeValue end
		self.getExecutionLowerValue = function(self, element) return element.unicodeLowerValue end
		self.getExecutionUpperValue = function(self, element) return element.unicodeUpperValue end
		self.getExecutionRanges = function(self, element) return element.unicodeRanges end
		self.getExecutionKeys = function(self, element) return element.unicodeKeys end
		self.NEWLINE = "\n"
		self.CARRIAGE_RETURN = "\r"
	else
		self.getTargetCharacter = function(self, index) return string.byte(targetString, index) end
		self.getExecutionValue = function(self, element) return element.byteValue end
		self.getExecutionLowerValue = function(self, element) return element.byteLowerValue end
		self.getExecutionUpperValue = function(self, element) return element.byteUpperValue end
		self.getExecutionRanges = function(self, element) return element.byteRanges end
		self.getExecutionKeys = function(self, element) return element.byteKeys end
		self.NEWLINE = 10
		self.CARRIAGE_RETURN = 13
	end
	
	local limits = config.get()

	self.metaData = {
		captureStarts = {},
		captureEnds = {},
		positionCaptures = {},
		outerTreeReference = {},
		rootTree = rootTree,
		parsedMetaData = parsedMetaData,
		groupNames = parsedMetaData and parsedMetaData.groupNames,
		recursionDepth = 0,
		backtrackSteps = 0,
		maxRecursionDepth = limits.maxRecursionDepth,
		maxBacktrackDepth = limits.maxBacktrackDepth,
	}
	
	return self
end

function MatchState:branch(stringIndex, initialStringIndex)
	local child = setmetatable({}, MatchState)
	child.flags = self.flags
	child.getTargetCharacter = self.getTargetCharacter
	child.getExecutionValue = self.getExecutionValue
	child.getExecutionLowerValue = self.getExecutionLowerValue
	child.getExecutionUpperValue = self.getExecutionUpperValue
	child.getExecutionRanges = self.getExecutionRanges
	child.getExecutionKeys = self.getExecutionKeys
	child.NEWLINE = self.NEWLINE
	child.CARRIAGE_RETURN = self.CARRIAGE_RETURN
	child.targetStringLength = self.targetStringLength
	child.stringIndex = stringIndex or self.stringIndex
	child.initialStringIndex = initialStringIndex or self.initialStringIndex
	child.metaData = self.metaData
	return child
end

function MatchState:incrementBacktrack()
	self.metaData.backtrackSteps = self.metaData.backtrackSteps + 1
	return self.metaData.backtrackSteps > self.metaData.maxBacktrackDepth
end

function MatchState:enterRecursion()
	self.metaData.recursionDepth = self.metaData.recursionDepth + 1
	if self.metaData.recursionDepth > self.metaData.maxRecursionDepth then
		self.metaData.recursionDepth = self.metaData.recursionDepth - 1
		return true
	end
	return false
end

function MatchState:leaveRecursion()
	self.metaData.recursionDepth = self.metaData.recursionDepth - 1
end

function MatchState:recordCapture(groupIndex, startIndex, endIndex)
	if not groupIndex then return end
	
	local inits = self.metaData.captureStarts
	local ends = self.metaData.captureEnds
	
	if not inits[groupIndex] then
		inits[groupIndex] = {}
		ends[groupIndex] = {}
	end
	
	if startIndex <= endIndex then
		table.insert(inits[groupIndex], startIndex)
		table.insert(ends[groupIndex], endIndex)
	else
		table.insert(inits[groupIndex], 2)
		table.insert(ends[groupIndex], 1)
	end
end

function MatchState:popCapture(groupIndex)
	if not groupIndex then return end
	
	local inits = self.metaData.captureStarts[groupIndex]
	if inits and #inits > 0 then
		table.remove(inits)
		table.remove(self.metaData.captureEnds[groupIndex])
	end
end

return MatchState
