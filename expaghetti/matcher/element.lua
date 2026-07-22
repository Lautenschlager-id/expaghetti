local Alternate = require("magic.alternate")
local Anchor = require("magic.anchor")
local Balanced = require("magic.balanced")
local Boundary = require("magic.boundary")
local CAPTURE_REFERENCE = require("magic.captureReference")
local Group = require("magic.group.group")
local POSITION_CAPTURE = require("magic.positionCapture")
local Set = require("magic.set")

local Any = require("magic.any")
local Literal = require("magic.literal")

local enumElements = require("enums.elements")
local ENUM_ELEMENT_TYPE_ALTERNATE = enumElements.ALTERNATE
local ENUM_ELEMENT_TYPE_ANCHOR = enumElements.ANCHOR
local ENUM_ELEMENT_TYPE_ANY = enumElements.ANY
local ENUM_ELEMENT_TYPE_BALANCED = enumElements.BALANCED
local ENUM_ELEMENT_TYPE_BOUNDARY = enumElements.BOUNDARY
local ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE = enumElements.CAPTURE_REFERENCE
local ENUM_ELEMENT_TYPE_GROUP = enumElements.GROUP
local ENUM_ELEMENT_TYPE_LITERAL = enumElements.LITERAL
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = enumElements.POSITION_CAPTURE
local ENUM_ELEMENT_TYPE_SET = enumElements.SET

local elementMatchers = {
	[ENUM_ELEMENT_TYPE_ALTERNATE] = {
		matcher = Alternate.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_ANCHOR] = {
		matcher = Anchor.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_ANY] = {
		matcher = Any.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_BALANCED] = {
		matcher = Balanced.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_BOUNDARY] = {
		matcher = Boundary.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE] = {
		matcher = CAPTURE_REFERENCE.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_GROUP] = {
		matcher = Group.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_LITERAL] = {
		matcher = Literal.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_POSITION_CAPTURE] = {
		matcher = POSITION_CAPTURE.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_SET] = {
		matcher = Set.match,
		requiresCharacter = true,
	},
}

--- Delegates the matching process to the specific class of a single AST element.
---@param currentElement table The AST element to match.
---@param currentCharacter string|number The target character at the current string index.
---@param state table The MatchState object.
---@return boolean hasMatched True if the single element successfully matched.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return table|nil metaData Metadata including captures, if any.
---@return boolean|nil shouldEndThisExecution True if execution stack should finish.
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
