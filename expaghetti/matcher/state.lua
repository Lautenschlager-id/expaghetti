--[[
    Match state used throughout the matching process.

    Tracks the current execution position, shared metadata,
    recursion state, backtracking state, and capture information.
]]

--[[ Globals ]]--
local setmetatable = setmetatable
local string_byte = string.byte

--[[ Dependencies ]]--
local toCharArray = require("helpers.string").toCharArray

--[[ Aliases ]]--
local FLAG_UNICODE = require("enums.flags").FLAGS.UNICODE

--[[ Module ]]--
local MatchState = {
	matcher = nil
}
MatchState.__index = MatchState

--- Creates a new MatchState instance for a regular expression execution.
---@param rootTree ASTTree The root AST tree.
---@param targetString string The target string.
---@param flags FlagTable Active matching flags.
---@param config Config|table|nil Optional configuration limits.
---@return MatchState state The newly created match state.
function MatchState.new(rootTree, targetString, flags, config)
	local metadata = {
		captureStarts = {},
		captureEnds = {},
		captureCounts = {},
		positionCaptures = {},

		outerTreeReference = {},

		rootTree = rootTree,

		parsedMetadata = nil,

		groupNames = nil,

		recursionDepth = 0,
		backtrackSteps = 0,
		maxRecursionDepth = config.maxRecursionDepth,
		maxBacktrackDepth = config.maxBacktrackDepth,
	}
	
	local self = setmetatable({
		flags = flags,
		
		getTargetCharacter = nil,
		targetStringLength = nil,
		
		rootTree = rootTree,

		parsedMetadata = nil,
		metadata = metadata,
	}, MatchState)
	
	if flags[FLAG_UNICODE] then
		local targetStringChars, targetStringLength = toCharArray(targetString, true)
		self.getTargetCharacter = function(self, index)
			return targetStringChars[index]
		end
		self.targetStringLength = targetStringLength
	else
		self.getTargetCharacter = function(self, index)
			return string_byte(targetString, index)
		end
		self.targetStringLength = #targetString
	end

	local parsedMetadata = rootTree and rootTree._metadata or nil 
	self.parsedMetadata = parsedMetadata
	metadata.parsedMetadata = parsedMetadata
	metadata.groupNames = parsedMetadata and parsedMetadata.groupNames

	return self
end

--- Resets the match state for a new matching attempt.
---@param stringIndex number The starting string index.
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

--- Creates a child state that shares the current execution context.
--- Used by constructs that execute in an isolated context (e.g. lookarounds)
--- while sharing captures and other execution metadata.
---@param stringIndex number|nil The starting string index for the child state.
---@param initialStringIndex number|nil The initial string index for the child state.
---@return MatchState childState The branched match state.
function MatchState:branch(stringIndex, initialStringIndex)
	return setmetatable({
		flags = self.flags,
		getTargetCharacter = self.getTargetCharacter,
		targetStringLength = self.targetStringLength,
		stringIndex = stringIndex or self.stringIndex,
		initialStringIndex = initialStringIndex or self.initialStringIndex,
		metadata = self.metadata,
		rootTree = self.rootTree,
		parsedMetadata = self.parsedMetadata,
		tree = self.tree,
		treeIndex = self.treeIndex,
		quantifierMaxEnd = self.quantifierMaxEnd,
	}, MatchState)
end

--- Increments the global backtrack counter.
---@return boolean exceeded Whether the configured backtrack limit was exceeded.
function MatchState:incrementBacktrack()
	local metadata = self.metadata
	local backtrackSteps = metadata.backtrackSteps + 1
	metadata.backtrackSteps = backtrackSteps
	return backtrackSteps > metadata.maxBacktrackDepth
end

--- Enters a recursive execution context.
---@return boolean exceeded Whether the configured recursion limit was exceeded.
function MatchState:enterRecursion()
	local metadata = self.metadata

	local recursionDepth = metadata.recursionDepth + 1
	if recursionDepth > metadata.maxRecursionDepth then
		return true
	end
	metadata.recursionDepth = recursionDepth
	return false
end

--- Leaves the current recursive execution context.
function MatchState:leaveRecursion()
	local metadata = self.metadata
	metadata.recursionDepth = metadata.recursionDepth - 1
end

--- Records a completed capture.
---@param groupIndex number|string The capture group identifier.
---@param startIndex number The first captured string index.
---@param endIndex number The last captured string index.
function MatchState:recordCapture(groupIndex, startIndex, endIndex)
	if not groupIndex then return end
	
	local metadata = self.metadata

	local inits = metadata.captureStarts
	local ends = metadata.captureEnds
	local counts = metadata.captureCounts
	
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

--- Removes the most recently recorded capture for a capture group.
---@param groupIndex number|string The capture group identifier.
function MatchState:popCapture(groupIndex)
	if not groupIndex then return end
	
	local metadata = self.metadata

	local counts = metadata.captureCounts
	local length = counts[groupIndex] or 0
	
	if length > 0 then
		metadata.captureStarts[groupIndex][length] = nil
		metadata.captureEnds[groupIndex][length] = nil
		counts[groupIndex] = length - 1
	end
end

return MatchState
