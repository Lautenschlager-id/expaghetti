local Alternate = require("magic.alternate")
local Anchor = require("magic.anchor")
local Balanced = require("magic.balanced")
local Boundary = require("magic.boundary")
local CaptureReference = require("magic.capture_reference")
local Group = require("magic.group.group")
local PositionCapture = require("magic.position_capture")
local Set = require("magic.set")

local Any = require("magic.any")
local Literal = require("magic.literal")

local enumElements = require("enums.elements")
local ENUM_ELEMENT_TYPE_ALTERNATE = enumElements.alternate
local ENUM_ELEMENT_TYPE_ANCHOR = enumElements.anchor
local ENUM_ELEMENT_TYPE_ANY = enumElements.any
local ENUM_ELEMENT_TYPE_BALANCED = enumElements.balanced
local ENUM_ELEMENT_TYPE_BOUNDARY = enumElements.boundary
local ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE = enumElements.capture_reference
local ENUM_ELEMENT_TYPE_GROUP = enumElements.group
local ENUM_ELEMENT_TYPE_LITERAL = enumElements.literal
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = enumElements.position_capture
local ENUM_ELEMENT_TYPE_SET = enumElements.set

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
		matcher = CaptureReference.match,
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
		matcher = PositionCapture.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_SET] = {
		matcher = Set.match,
		requiresCharacter = true,
	},
}

local singleElementMatcher = function(currentElement, currentCharacter, state)
	local elementClass = elementMatchers[currentElement.type]
	if not elementClass then
		return false
	end

	if elementClass.requiresCharacter and not currentCharacter then
		return false
	end

	return elementClass.matcher(currentElement, state, currentCharacter)
end

return singleElementMatcher
