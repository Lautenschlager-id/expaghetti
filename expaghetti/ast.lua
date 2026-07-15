local elementsEnum = require("./enums/elements")

local AST = {}

function AST.Anchor(isBeginning)
	return {
		type = elementsEnum.anchor,
		isBeginning = isBeginning,
	}
end

function AST.Any()
	return {
		type = elementsEnum.any,
	}
end

function AST.Literal(value, lowerValue, upperValue)
	return {
		type = elementsEnum.literal,
		value = value,
		isCaseInsensitive = not not lowerValue,
		lowerValue = lowerValue,
		upperValue = upperValue,
	}
end
local function baseGroup()
	return {
		type = elementsEnum.group,
		-- Common
		tree = nil,
		index = nil,
		name = nil,
		hasBehavior = nil,
		disableCapture = nil,
		quantifier = nil,
		-- Lookarounds
		isLookahead = nil,
		isLookbehind = nil,
		isNegative = nil,
		fixedLength = nil,
		-- Special Behaviors
		isAtomic = nil,
		isBranchReset = nil,
		-- Flags
		inlineFlags = nil,
		scopedFlags = nil,
		-- Recursion
		isRecursion = nil,
		isRecursionRoot = nil,
		targetIndex = nil,
		targetName = nil,
		-- Internal
		_skipFromTree = nil,
	}
end

function AST.Group()
	return baseGroup()
end

function AST.GroupCapture()
	return baseGroup()
end

function AST.GroupNonCapturing()
	local node = baseGroup()
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

function AST.GroupNamed(name)
	local node = baseGroup()
	node.hasBehavior = true
	node.name = name
	return node
end

function AST.GroupAtomic()
	local node = baseGroup()
	node.disableCapture = true
	node.isAtomic = true
	node.hasBehavior = true
	return node
end

function AST.GroupBranchReset()
	local node = baseGroup()
	node.disableCapture = true
	node.isBranchReset = true
	node.hasBehavior = true
	return node
end

function AST.GroupLookahead()
	local node = baseGroup()
	node.isLookahead = true
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

function AST.GroupLookbehind()
	local node = baseGroup()
	node.isLookbehind = true
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

function AST.GroupRecursion()
	local node = baseGroup()
	node.isRecursion = true
	node.hasBehavior = true
	return node
end

function AST.GroupComment()
	local node = baseGroup()
	node.disableCapture = true
	node._skipFromTree = true
	node.hasBehavior = true
	return node
end

function AST.GroupInlineFlags()
	local node = baseGroup()
	node._skipFromTree = true
	node.hasBehavior = true
	return node
end

function AST.GroupScopedFlags()
	local node = baseGroup()
	node.disableCapture = true
	node.hasBehavior = true
	return node
end

function AST.Set()
	return {
		type = elementsEnum.set,
		hasToNegateMatch = false,
		rangeIndex = 0,
		ranges = {},
		values = {},
		classIndex = 0,
		classes = {},
	}
end

function AST.Boundary(isNegated, set)
	return {
		type = elementsEnum.boundary,
		isNegated = isNegated,
		set = set,
	}
end

function AST.Quantifier(min, max)
	return {
		type = elementsEnum.quantifier,
		min = min or 0,
		max = max or 0,
		mode = nil,
	}
end

function AST.Alternate(trees)
	return {
		type = elementsEnum.alternate,
		trees = trees,
	}
end

function AST.PositionCapture(index)
	return {
		type = elementsEnum.position_capture,
		index = index,
	}
end

function AST.CaptureReference(index)
	return {
		type = elementsEnum.capture_reference,
		index = index,
	}
end

function AST.Balanced(lowerOpen, upperOpen, lowerClose, upperClose)
	return {
		type = elementsEnum.balanced,
		lowerOpen = lowerOpen,
		upperOpen = upperOpen,
		lowerClose = lowerClose,
		upperClose = upperClose,
	}
end

AST.hasNestedQuantifier = function(tree)
	if not tree then
		return false
	end
	for elementIndex = 1, tree._index do
		local child = tree[elementIndex]
		if child.quantifier and child.quantifier.type == elementsEnum.quantifier then
			return true
		end
	end
	return false
end

AST.elementHasNestedQuantifier = function(element)
	if element.type == elementsEnum.group then
		return AST.hasNestedQuantifier(element.tree)
	end
	return false
end

AST.elementInnerQuantifierIsPossessive = function(element)
	if element.type == elementsEnum.group and element.tree then
		for elementIndex = 1, element.tree._index do
			local child = element.tree[elementIndex]
			if child.quantifier and child.quantifier.type == elementsEnum.quantifier and child.quantifier.mode == "possessive" then
				return true
			end
		end
	elseif element.quantifier and element.quantifier.type == elementsEnum.quantifier and element.quantifier.mode == "possessive" then
		return true
	end
	return false
end

return AST
