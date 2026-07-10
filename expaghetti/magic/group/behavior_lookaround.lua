----------------------------------------------------------------------------------------------------
local AST = require("./ast")
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR = magicEnum.GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR
local ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR = magicEnum.GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR
local ENUM_GROUP_LOOKBEHIND_BEHAVIOR = magicEnum.GROUP_LOOKBEHIND_BEHAVIOR
----------------------------------------------------------------------------------------------------

-- Parses lookahead and lookbehind group behaviors.
-- Lookaheads use `(?=...)` / `(?!...)`, lookbehinds use `(?<=...)` / `(?<!...)`.
-- The `=` and `!` tokens are reused for both lookahead and lookbehind polarity.
return function(state, peekIndex, peekChar, lookbehindIndex, lookbehindChar)
	-- Lookahead: (?=...), (?!...)
	local isNegativeLookahead = (peekChar == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR) or nil
	if peekChar == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR or isNegativeLookahead then
		local node = AST.GroupLookahead()
		node.isLookahead = true
		node.disableCapture = true
		node.hasBehavior = true
		node.isNegative = isNegativeLookahead
		return peekIndex, node
		
	-- Lookbehind: (?<=...), (?<!...)
	-- Peek at the third character to determine polarity
	elseif peekChar == ENUM_GROUP_LOOKBEHIND_BEHAVIOR then
		if not lookbehindIndex then
			return false, nil, errorsEnum.invalidGroupBehavior
		end

		local isNegativeLookbehind = (lookbehindChar == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR) or nil
		if lookbehindChar == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR or isNegativeLookbehind then
			local node = AST.GroupLookbehind()
			node.isLookbehind = true
			node.disableCapture = true
			node.hasBehavior = true
			node.isNegative = isNegativeLookbehind
			return lookbehindIndex, node
		end
	end
	
	return false, nil, errorsEnum.invalidGroupBehavior
end
