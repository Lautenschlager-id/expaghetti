local AST = require("./ast")
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local inlineFlagsEnum = require("./enums/flags").inlineFlags

local ENUM_CLOSE_GROUP = magicEnum.CLOSE_GROUP
local ENUM_GROUP_SCOPED_FLAGS_BEHAVIOR = magicEnum.GROUP_SCOPED_FLAGS_BEHAVIOR
local ENUM_GROUP_FLAGS_DISABLE_BEHAVIOR = magicEnum.GROUP_FLAGS_DISABLE_BEHAVIOR

local ENUM_GROUP_FLAG_IGNORE_CASE = magicEnum.GROUP_FLAG_IGNORE_CASE
local ENUM_GROUP_FLAG_MULTILINE = magicEnum.GROUP_FLAG_MULTILINE
local ENUM_GROUP_FLAG_DOTALL = magicEnum.GROUP_FLAG_DOTALL
local ENUM_GROUP_FLAG_NO_CAPTURE = magicEnum.GROUP_FLAG_NO_CAPTURE

return function(state, peekIndex, peekChar)
	local enableFlags = {}
	local disableFlags = {}
	local currentTarget = enableFlags
	
	local nextPeekIndex, nextChar
	
	-- Parse all inline flags (e.g. `i`, `m`, `s`) and switch target if `-` is encountered
	while inlineFlagsEnum[peekChar] do
		if peekChar == ENUM_GROUP_FLAGS_DISABLE_BEHAVIOR then
			currentTarget = disableFlags
		else
			currentTarget[peekChar] = true
		end
		nextPeekIndex, nextChar = state:readElement(peekIndex)
		if not nextPeekIndex or state:isElement(nextChar) then
			peekChar = nextChar
			break
		end
		peekChar = nextChar
		peekIndex = nextPeekIndex
	end
	
	-- Handle scoped flags e.g. `(?i:abc)`
	if peekChar == ENUM_GROUP_SCOPED_FLAGS_BEHAVIOR then
		local node = AST.GroupScopedFlags()
		node.scopedFlags = {
			enable = enableFlags,
			disable = disableFlags
		}
		return peekIndex, node
		
	-- Handle standard inline flag toggles e.g. `(?i)`
	elseif peekChar == ENUM_CLOSE_GROUP then
		local node = AST.GroupInlineFlags()
		node.inlineFlags = {
			enable = enableFlags,
			disable = disableFlags
		}
		return peekIndex, node
	else
		return false, nil, errorsEnum.invalidGroupBehavior
	end
end
