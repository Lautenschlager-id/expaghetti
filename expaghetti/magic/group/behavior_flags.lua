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

return function(state)
	local index = state.index
	local nextIndex, currentChar = state:readElement(index)
	local loopIndex, charVal = state:readElement(nextIndex)
	
	local enableFlags = {}
	local disableFlags = {}
	local currentTarget = enableFlags
	
	local nextLoopIndex, nextChar
	
	-- Parse all inline flags (e.g. `i`, `m`, `s`) and switch target if `-` is encountered
	while inlineFlagsEnum[charVal] do
		if charVal == ENUM_GROUP_FLAGS_DISABLE_BEHAVIOR then
			currentTarget = disableFlags
		else
			currentTarget[charVal] = true
		end
		nextLoopIndex, nextChar = state:readElement(loopIndex)
		if not nextLoopIndex or state:isElement(nextChar) then
			charVal = nextChar
			break
		end
		charVal = nextChar
		loopIndex = nextLoopIndex
	end
	
	-- Handle scoped flags e.g. `(?i:abc)`
	if charVal == ENUM_GROUP_SCOPED_FLAGS_BEHAVIOR then
		local node = AST.GroupScopedFlags()
		node.scopedFlags = { enable = enableFlags, disable = disableFlags }
		return loopIndex, node
		
	-- Handle standard inline flag toggles e.g. `(?i)`
	elseif charVal == ENUM_CLOSE_GROUP then
		local node = AST.GroupInlineFlags()
		node.inlineFlags = { enable = enableFlags, disable = disableFlags }
		return loopIndex, node
	else
		return false, nil, errorsEnum.invalidGroupBehavior
	end
end
