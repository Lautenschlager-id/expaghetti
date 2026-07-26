--[[
	Abstract Syntax Tree (AST) node constructors.

	Provides factory functions for creating the AST node types used
	throughout the parser and matcher.
]]

--[[ Dependencies ]]--
local Elements = require("enums.elements")

--[[ Aliases ]]--
local ELEMENT_ALTERNATE = Elements.ALTERNATE
local ELEMENT_ANCHOR = Elements.ANCHOR
local ELEMENT_ANY = Elements.ANY
local ELEMENT_BACKREFERENCE = Elements.BACKREFERENCE
local ELEMENT_BALANCED = Elements.BALANCED
local ELEMENT_FRONTIER = Elements.FRONTIER
local ELEMENT_GROUP = Elements.GROUP
local ELEMENT_LITERAL = Elements.LITERAL
local ELEMENT_POSITION_CAPTURE = Elements.POSITION_CAPTURE
local ELEMENT_QUANTIFIER = Elements.QUANTIFIER
local ELEMENT_SET = Elements.SET

--[[ Module ]]--
local AST = {}

--- Creates the common base structure shared by all group AST nodes.
---@return ASTGroup node
local baseGroup = function()
	return {
		type = ELEMENT_GROUP,
		-- Common
		tree = nil,
		index = nil,
		_skipFromTree = nil,
		-- Specific
		isNonCapturing = nil,
		hasSpecialBehavior = nil,
		name = nil,
		isAtomic = nil,
		isBranchReset = nil,
		isLookahead = nil,
		isLookbehind = nil,
		isRecursion = nil,
	}
end

--- Creates an AST node representing an alternation.
---@param branches ASTTree[] The alternate branches.
---@return ASTAlternate node
AST.Alternate = function(branches)
	return {
		type = ELEMENT_ALTERNATE,
		branches = branches,
	}
end

--- Creates an AST node representing a beginning or end anchor.
---@param isStart boolean Whether the anchor matches the beginning of the target string.
---@return ASTAnchor node
AST.Anchor = function(isStart)
	return {
		type = ELEMENT_ANCHOR,
		isStart = isStart,
	}
end

--- Creates an AST node representing the wildcard (`.`) element.
---@return ASTAny node
AST.Any = function()
	return {
		type = ELEMENT_ANY,
	}
end

--- Creates an AST node representing a numeric or named backreference.
---@param index number|string The referenced capture group identifier.
---@return ASTBackreference node
AST.Backreference = function(index)
	return {
		type = ELEMENT_BACKREFERENCE,
		index = index,
	}
end

--- Creates an AST node representing a balanced element (`%bxy`).
---@param lowerOpen string|number The lowercase opening delimiter.
---@param upperOpen string|number The uppercase opening delimiter.
---@param lowerClose string|number The lowercase closing delimiter.
---@param upperClose string|number The uppercase closing delimiter.
---@return ASTBalanced node
AST.Balanced = function(lowerOpen, upperOpen, lowerClose, upperClose)
	return {
		type = ELEMENT_BALANCED,
		lowerOpen = lowerOpen,
		upperOpen = upperOpen,
		lowerClose = lowerClose,
		upperClose = upperClose,
	}
end

--- Creates an AST node representing a frontier assertion.
---@param isNegated boolean Whether the frontier assertion is negated.
---@param set ASTSet The character set used by the assertion.
---@return ASTFrontier node
AST.Frontier = function(isNegated, set)
	return {
		type = ELEMENT_FRONTIER,
		isNegated = isNegated,
		set = set,
	}
end

--- Creates a capturing group AST node.
---@return ASTGroup node
AST.Group = function()
	return baseGroup()
end

--- Creates an explicit capturing group AST node.
---@return ASTGroup node
AST.GroupCapture = function()
	return baseGroup()
end

--- Creates a non-capturing group AST node.
---@return ASTGroup node
AST.GroupNonCapturing = function()
	local node = baseGroup()
	node.isNonCapturing = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a named capturing group AST node.
---@param name string The capture group name.
---@return ASTGroup node
AST.GroupNamed = function(name)
	local node = baseGroup()
	node.hasSpecialBehavior = true
	node.name = name
	return node
end

--- Creates an atomic group AST node.
---@return ASTGroup node
AST.GroupAtomic = function()
	local node = baseGroup()
	node.isNonCapturing = true
	node.isAtomic = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a branch-reset group AST node.
---@return ASTGroup node
AST.GroupBranchReset = function()
	local node = baseGroup()
	node.isNonCapturing = true
	node.isBranchReset = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a lookahead assertion AST node.
---@return ASTGroup node
AST.GroupLookahead = function()
	local node = baseGroup()
	node.isLookahead = true
	node.isNonCapturing = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a lookbehind assertion AST node.
---@return ASTGroup node
AST.GroupLookbehind = function()
	local node = baseGroup()
	node.isLookbehind = true
	node.isNonCapturing = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a recursion group AST node.
---@return ASTGroup node
AST.GroupRecursion = function()
	local node = baseGroup()
	node.isRecursion = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a comment group AST node.
---@return ASTGroup node
AST.GroupComment = function()
	local node = baseGroup()
	node.isNonCapturing = true
	node._skipFromTree = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates an inline flags group AST node.
---@return ASTGroup node
AST.GroupInlineFlags = function()
	local node = baseGroup()
	node._skipFromTree = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates a scoped flags group AST node.
---@return ASTGroup node
AST.GroupScopedFlags = function()
	local node = baseGroup()
	node.isNonCapturing = true
	node.hasSpecialBehavior = true
	return node
end

--- Creates an AST node representing a literal character.
---@param value string|number The literal character value.
---@param lowerValue string|number|nil The lowercase equivalent for case-insensitive matching.
---@param upperValue string|number|nil The uppercase equivalent for case-insensitive matching.
---@return ASTLiteral node
AST.Literal = function(value, lowerValue, upperValue)
	return {
		type = ELEMENT_LITERAL,
		value = value,
		isCaseInsensitive = not not lowerValue,
		lowerValue = lowerValue,
		upperValue = upperValue,
	}
end

--- Creates an AST node representing a position capture.
---@param index number The capture group index.
---@return ASTPositionCapture node
AST.PositionCapture = function(index)
	return {
		type = ELEMENT_POSITION_CAPTURE,
		index = index,
	}
end

--- Creates a quantifier AST node.
---@param min number|nil The minimum number of occurrences.
---@param max number|nil The maximum number of occurrences (0 for unlimited).
---@return ASTQuantifier node
AST.Quantifier = function(min, max)
	return {
		type = ELEMENT_QUANTIFIER,
		min = min or 0,
		max = max or 0,
		mode = nil,
	}
end

--- Creates an empty character set AST node.
---@return ASTSet node
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

return AST
