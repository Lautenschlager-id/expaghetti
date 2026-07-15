----------------------------------------------------------------------------------------------------
local tblconcat = table.concat
local strformat = string.format
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_GROUP_NON_CAPTURING_BEHAVIOR = magicEnum.GROUP_NON_CAPTURING_BEHAVIOR
local ENUM_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local ENUM_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
----------------------------------------------------------------------------------------------------

-- Validates if a character is valid for use in a group name identifier.
-- First character must be a letter (A-z) or `$`. Subsequent characters may also be digits.
local function isValidNameCharacter(char, isFirstCharacter)
	if (char >= 'A' and char <= 'z') or (isFirstCharacter and char == '$') then
		return true
	elseif not isFirstCharacter and (char >= '0' and char <= '9') then
		return true
	end
	return false
end

-- Parses capture-oriented group behaviors:
--	Standard capturing groups:	(...)
--	Non-capturing groups:		(?:...)
--	Named capturing groups:		(?<name>...)
return function(state, index, peekIndex, peekChar)
	-- No behavior token found: standard capturing group
	if not peekIndex then
		return index, AST.GroupCapture()
	end
	
	-- Non-capturing group: (?:...)
	if peekChar == ENUM_GROUP_NON_CAPTURING_BEHAVIOR then
		return peekIndex, AST.GroupNonCapturing()

	-- Named capturing group: (?<name>...)
	-- Parse the name between `<` and `>`, validating each character
	elseif peekChar == ENUM_GROUP_NAME_OPEN then
		local name, nameIndex = { }, 0
		local isFirstCharacter = true
		local loopIndex, currentChar = peekIndex
		
		-- Consume characters until the closing `>` is found
		repeat
			index = loopIndex
			loopIndex, currentChar = state:readElement(index)
			if not loopIndex or state:isElement(currentChar) then
				return false, nil, errorsEnum.invalidGroupName
			end
			local currentCharacterValue = currentChar

			if isValidNameCharacter(currentCharacterValue, isFirstCharacter) then
				nameIndex = nameIndex + 1
				name[nameIndex] = currentChar
				isFirstCharacter = false
			elseif nameIndex > 0 and currentChar == ENUM_GROUP_NAME_CLOSE then
				name = tblconcat(name)
				if state.metaData.groupNames[name] then
					return false, nil, strformat(errorsEnum.duplicatedGroupName, name)
				else
					state.metaData.groupNames[name] = true
					return loopIndex, AST.GroupNamed(name)
				end
			else
				return false, nil, errorsEnum.invalidGroupName
			end
		until false
	end
	
	return false, nil, errorsEnum.invalidGroupBehaviorindex
end
