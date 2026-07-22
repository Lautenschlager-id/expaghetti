local config = require("./config")
local ENUM_FLAG_UNICODE = require("./enums/flags").FLAGS.UNICODE
local toCharArray = require("./helpers/string").toCharArray

local MatchState = {
	matcher = nil
}
MatchState.__index = MatchState

--- Creates a new MatchState instance for a regex execution.
---@param flags table Dictionary of active flags.
---@param targetString string The string being searched.
---@param rootTree table The AST root tree.
---@return table MatchState The instantiated MatchState object.
function MatchState.new(flags, targetString, rootTree)
	local self = setmetatable({}, MatchState)
	
	self.flags = flags or {}

	if self.flags[ENUM_FLAG_UNICODE] then
		local targetStringChars, targetStringLength = toCharArray(targetString, true)
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
	self.parsedMetaData = rootTree and rootTree._metadata or nil
	
	local limits = config.get()
	self.metadata = {
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

--- Resets the execution state arrays for a new match attempt starting at stringIndex.
---@param stringIndex number The starting string index for the new match attempt.
function MatchState:reset(stringIndex)
	self.stringIndex = stringIndex or 0
	self.initialStringIndex = self.stringIndex

	local metadata = self.metadata
	metadata.captureStarts = {}
	metadata.captureEnds = {}
	metadata.captureCounts = {}
	metadata.positionCaptures = {}
	metadata.outerTreeReference = {}
	metadata.recursionDepth = 0
	metadata.backtrackSteps = 0
end

--- Branches the current state into a new child state (e.g., for lookaheads).
---@param stringIndex number|nil The string index for the branched state.
---@param initialStringIndex number|nil The initial string index for the branched state.
---@return table MatchState The newly branched state.
function MatchState:branch(stringIndex, initialStringIndex)
	local child = setmetatable({}, MatchState)
	child.flags = self.flags
	child.getTargetCharacter = self.getTargetCharacter
	child.targetStringLength = self.targetStringLength
	child.stringIndex = stringIndex or self.stringIndex
	child.initialStringIndex = initialStringIndex or self.initialStringIndex
	child.metadata = self.metadata
	child.rootTree = self.rootTree
	child.parsedMetaData = self.parsedMetaData
	child.tree = self.tree
	child.treeIndex = self.treeIndex
	child.quantifierMaxEnd = self.quantifierMaxEnd
	return child
end

--- Increments the global backtrack counter and checks against the max backtrack limit.
---@return boolean exceeded Limit exceeded (true if backtrack limit has been breached).
function MatchState:incrementBacktrack()
	self.metadata.backtrackSteps = self.metadata.backtrackSteps + 1
	return self.metadata.backtrackSteps > self.metadata.maxBacktrackDepth
end

--- Increments the recursion depth and checks against the max recursion limit.
---@return boolean exceeded Limit exceeded (true if recursion limit has been breached).
function MatchState:enterRecursion()
	self.metadata.recursionDepth = self.metadata.recursionDepth + 1
	if self.metadata.recursionDepth > self.metadata.maxRecursionDepth then
		self.metadata.recursionDepth = self.metadata.recursionDepth - 1
		return true
	end
	return false
end

--- Decrements the recursion depth.
function MatchState:leaveRecursion()
	self.metadata.recursionDepth = self.metadata.recursionDepth - 1
end

--- Records a successful capture group match.
---@param groupIndex number|string The identifier of the capture group.
---@param startIndex number The initial string index of the capture.
---@param endIndex number The ending string index of the capture.
function MatchState:recordCapture(groupIndex, startIndex, endIndex)
	if not groupIndex then return end
	
	local inits = self.metadata.captureStarts
	local ends = self.metadata.captureEnds
	local counts = self.metadata.captureCounts
	
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

--- Pops the most recently recorded capture for a specific group.
---@param groupIndex number|string The identifier of the capture group.
function MatchState:popCapture(groupIndex)
	if not groupIndex then return end
	
	local counts = self.metadata.captureCounts
	local length = counts[groupIndex] or 0
	
	if length > 0 then
		self.metadata.captureStarts[groupIndex][length] = nil
		self.metadata.captureEnds[groupIndex][length] = nil
		counts[groupIndex] = length - 1
	end
end

return MatchState
