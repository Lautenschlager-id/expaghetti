--[[
	Delegates AST element matching to the appropriate matcher implementation.
]]

--[[ Dependencies ]]--
local AlternateMatch = require("magic.alternate").match
local AnchorMatch = require("magic.anchor").match
local AnyMatch = require("magic.any").match
local BackreferenceMatch = require("magic.backreference").match
local BalancedMatch = require("magic.balanced").match
local FrontierMatch = require("magic.frontier").match
local GroupMatch = require("magic.group.group").match
local LiteralMatch = require("magic.literal").match
local PositionCaptureMatch = require("magic.positionCapture").match
local SetMatch = require("magic.set").match

--[[ Enums ]]--
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
local ELEMENT_SET = Elements.SET

--[[ Module ]]--
local elementMatchers = {
	[ELEMENT_ALTERNATE] = {
		matcher = AlternateMatch,
		requiresCharacter = false,
	},
	[ELEMENT_ANCHOR] = {
		matcher = AnchorMatch,
		requiresCharacter = false,
	},
	[ELEMENT_ANY] = {
		matcher = AnyMatch,
		requiresCharacter = true,
	},
	[ELEMENT_BACKREFERENCE] = {
		matcher = BackreferenceMatch,
		requiresCharacter = false,
	},
	[ELEMENT_BALANCED] = {
		matcher = BalancedMatch,
		requiresCharacter = true,
	},
	[ELEMENT_FRONTIER] = {
		matcher = FrontierMatch,
		requiresCharacter = true,
	},
	[ELEMENT_GROUP] = {
		matcher = GroupMatch,
		requiresCharacter = false,
	},
	[ELEMENT_LITERAL] = {
		matcher = LiteralMatch,
		requiresCharacter = true,
	},
	[ELEMENT_POSITION_CAPTURE] = {
		matcher = PositionCaptureMatch,
		requiresCharacter = false,
	},
	[ELEMENT_SET] = {
		matcher = SetMatch,
		requiresCharacter = true,
	},
}

--- Matches a single AST element.
---@param currentElement ASTElement The AST element to match.
---@param currentCharacter string|number The target character at the current string index.
---@param state MatchState The matcher state.
---@return boolean hasMatched Whether the element matched successfully.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return MatcherMetadata|nil metadata The match metadata.
---@return boolean|nil shouldEndThisExecution Whether the current execution stack should end.
local elementMatcher = function(currentElement, currentCharacter, state)
	local elementClass = elementMatchers[currentElement.type]
	if not elementClass then
		return false
	end

	if elementClass.requiresCharacter and not currentCharacter then
		return false
	end

	return elementClass.matcher(currentElement, state, currentCharacter)
end

return elementMatcher
