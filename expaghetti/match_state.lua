local config = require("./config")
local ENUM_FLAG_UNICODE = require("./enums/flags").flags.UNICODE
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar

local MatchState = {}
MatchState.__index = MatchState

function MatchState.new(flags, targetString, rootTree)
	local self = setmetatable({}, MatchState)
	
	self.flags = flags or {}

	if self.flags[ENUM_FLAG_UNICODE] then
		local targetStringChars, targetStringLength = splitStringByEachChar(targetString, true)
		self.getTargetCharacter = function(self, index)
			return targetStringChars[index]
		end
		self.targetStringLength = targetStringLength
	else
		self.getTargetCharacter = function(self, index)
			return string.byte(targetString, index)
		end
		self.targetStringLength = #targetString
	end

	self.rootTree = rootTree
	self.parsedMetaData = rootTree and rootTree._metaData or nil
	
	local limits = config.get()
	self.metaData = {
		captureStarts = {},
		captureEnds = {},
		captureCounts = {},
		positionCaptures = {},
		outerTreeReference = {},
		rootTree = self.rootTree,
		parsedMetaData = self.parsedMetaData,
		groupNames = self.parsedMetaData and self.parsedMetaData.groupNames,
		recursionDepth = 0,
		backtrackSteps = 0,
		maxRecursionDepth = limits.maxRecursionDepth,
		maxBacktrackDepth = limits.maxBacktrackDepth,
	}

	return self
end

function MatchState:reset(stringIndex)
	self.stringIndex = stringIndex or 0
	self.initialStringIndex = self.stringIndex

	local metaData = self.metaData
	metaData.captureStarts = {}
	metaData.captureEnds = {}
	metaData.captureCounts = {}
	metaData.positionCaptures = {}
	metaData.outerTreeReference = {}
	metaData.recursionDepth = 0
	metaData.backtrackSteps = 0
end

function MatchState:branch(stringIndex, initialStringIndex)
	local child = setmetatable({}, MatchState)
	child.flags = self.flags
	child.getTargetCharacter = self.getTargetCharacter
	child.targetStringLength = self.targetStringLength
	child.stringIndex = stringIndex or self.stringIndex
	child.initialStringIndex = initialStringIndex or self.initialStringIndex
	child.metaData = self.metaData
	child.rootTree = self.rootTree
	child.parsedMetaData = self.parsedMetaData
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
	local counts = self.metaData.captureCounts
	
	local groupInits = inits[groupIndex]
	local groupEnds = ends[groupIndex]

	if not groupInits then
		groupInits = {}
		groupEnds = {}
		counts[groupIndex] = 0
		inits[groupIndex] = groupInits
		ends[groupIndex] = groupEnds
	end
	
	local nextIndex = counts[groupIndex] + 1
	counts[groupIndex] = nextIndex

	groupInits[nextIndex] = startIndex
	groupEnds[nextIndex] = endIndex
end

function MatchState:popCapture(groupIndex)
	if not groupIndex then return end
	
	local counts = self.metaData.captureCounts
	local length = counts[groupIndex] or 0
	
	if length > 0 then
		self.metaData.captureStarts[groupIndex][length] = nil
		self.metaData.captureEnds[groupIndex][length] = nil
		counts[groupIndex] = length - 1
	end
end

return MatchState
