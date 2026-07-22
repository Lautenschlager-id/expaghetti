--[[
    Abstract Syntax Tree elements.
]]

--[[ Dependencies ]]--
local elementsEnum = require("enums.elements")

--[[ Enum Aliases ]]--
local ELEMENT_ANCHOR = elementsEnum.anchor
local ELEMENT_ANY = elementsEnum.any
local ELEMENT_LITERAL = elementsEnum.literal
local ELEMENT_GROUP = elementsEnum.group
local ELEMENT_SET = elementsEnum.set
local ELEMENT_BOUNDARY = elementsEnum.boundary
local ELEMENT_QUANTIFIER = elementsEnum.quantifier
local ELEMENT_ALTERNATE = elementsEnum.alternate
local ELEMENT_positionCapture = elementsEnum.positionCapture
local ELEMENT_captureReference = elementsEnum.captureReference
local ELEMENT_BALANCED = elementsEnum.balanced


--[[ Module ]]--
local AST = {}

--[[ Private Functions ]]--
local baseGroup = function()
	return {
		type = ELEMENT_GROUP,
		-- Common
		tree = nil,
		index = nil,
		_skipFromTree = nil,
		-- Specific
		disableCapture = nil,
		hasBehavior = nil,
		name = nil,
		isAtomic = nil,
		isBranchReset = nil,
		isLookahead = nil,
		isLookbehind = nil,
		isRecursion = nil,
	}
end

--[[ Public API ]]--
AST.Anchor = function(isBeginning)
	return {
		type = ELEMENT_ANCHOR,
		isBeginning = isBeginning,
	}
end

AST.Any = function()
	return {
		type = ELEMENT_ANY,
	}
end

AST.Literal = function(value, lowerValue, upperValue)
	return {
		type = ELEMENT_LITERAL,
		value = value,
		isCaseInsensitive = not not lowerValue,
		lowerValue = lowerValue,
		upperValue = upperValue,
	}
end

AST.Group = function()
	return baseGroup()
end

AST.GroupCapture = function()
	return baseGroup()
end

AST.GroupNonCapturing = function()
	local node = baseGroup()
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

AST.GroupNamed = function(name)
	local node = baseGroup()
	node.hasBehavior = true
	node.name = name
	return node
end

AST.GroupAtomic = function()
	local node = baseGroup()
	node.disableCapture = true
	node.isAtomic = true
	node.hasBehavior = true
	return node
end

AST.GroupBranchReset = function()
	local node = baseGroup()
	node.disableCapture = true
	node.isBranchReset = true
	node.hasBehavior = true
	return node
end

AST.GroupLookahead = function()
	local node = baseGroup()
	node.isLookahead = true
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

AST.GroupLookbehind = function()
	local node = baseGroup()
	node.isLookbehind = true
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

AST.GroupRecursion = function()
	local node = baseGroup()
	node.isRecursion = true
	node.hasBehavior = true
	return node
end

AST.GroupComment = function()
	local node = baseGroup()
	node.disableCapture = true
	node._skipFromTree = true
	node.hasBehavior = true
	return node
end

AST.GroupInlineFlags = function()
	local node = baseGroup()
	node._skipFromTree = true
	node.hasBehavior = true
	return node
end

AST.GroupScopedFlags = function()
	local node = baseGroup()
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

AST.Set = function()
	return {
		type = ELEMENT_SET,
		hasToNegateMatch = false,
		rangeIndex = 0,
		ranges = {},
		values = {},
		classIndex = 0,
		classes = {},
	}
end

AST.Boundary = function(isNegated, set)
	return {
		type = ELEMENT_BOUNDARY,
		isNegated = isNegated,
		set = set,
	}
end

AST.Quantifier = function(min, max)
	return {
		type = ELEMENT_QUANTIFIER,
		min = min or 0,
		max = max or 0,
		mode = nil,
	}
end

AST.Alternate = function(trees)
	return {
		type = ELEMENT_ALTERNATE,
		trees = trees,
	}
end

AST.PositionCapture = function(index)
	return {
		type = ELEMENT_positionCapture,
		index = index,
	}
end

AST.CaptureReference = function(index)
	return {
		type = ELEMENT_captureReference,
		index = index,
	}
end

AST.Balanced = function(lowerOpen, upperOpen, lowerClose, upperClose)
	return {
		type = ELEMENT_BALANCED,
		lowerOpen = lowerOpen,
		upperOpen = upperOpen,
		lowerClose = lowerClose,
		upperClose = upperClose,
	}
end

--[[ Return ]]--
return AST
