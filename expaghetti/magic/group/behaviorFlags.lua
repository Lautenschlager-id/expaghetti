--[[
	Parser for inline and scoped flag group behaviors:
	`(?flags)`, `(?-flags)`, `(?flags:...)`, and `(?-flags:...)`.
]]

--[[ Dependencies ]]--
local AST = require("core.ast")

--[[ Enums ]]--
local Magic = require("enums.magic")

--[[ Aliases ]]--
local ENUM_GROUP_CLOSE = Magic.GROUP_CLOSE
local ENUM_GROUP_SCOPED_FLAGS_BEHAVIOR = Magic.GROUP_SCOPED_FLAGS_BEHAVIOR
local ENUM_GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR = Magic.GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR

local ERROR_INVALID_GROUP_BEHAVIOR = require("enums.errors").invalidGroupBehavior

local FLAGS_INLINE_TOKENS = require("enums.flags").INLINE_TOKENS

local GroupScopedFlagsNode = AST.GroupScopedFlags
local GroupInlineFlagsNode = AST.GroupInlineFlags

--[[ Module ]]--

--- Parses an inline or scoped flag group behavior.
---@param state ParserState The current parser state.
---@param peekIndex number The parser index after the first flag token.
---@param peekChar string The first flag token.
---@return number|false nextIndex The parser index after the parsed behavior, or false on failure.
---@return table|nil group The parsed AST group node.
---@return string|nil errorMessage The parser error message when parsing fails.
return function(state, peekIndex, peekChar)
	local enableFlags = {}
	local disableFlags = {}
	local targetFlags = enableFlags

	-- Parse all inline flags (e.g. `i`, `m`, `s`) and switch target if `-` is encountered
	while FLAGS_INLINE_TOKENS[peekChar] do
		if peekChar == ENUM_GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR then
			targetFlags = disableFlags
		else
			targetFlags[peekChar] = true
		end

		local nextPeekIndex, nextChar = state:readElement(peekIndex)
		if not nextPeekIndex or state:isElement(nextChar) then
			peekChar = nextChar
			break
		end
		peekChar = nextChar
		peekIndex = nextPeekIndex
	end

	-- Handle scoped flags e.g. `(?i:abc)`
	if peekChar == ENUM_GROUP_SCOPED_FLAGS_BEHAVIOR then
		local node = GroupScopedFlagsNode()
		node.scopedFlags = {
			enable = enableFlags,
			disable = disableFlags
		}
		return peekIndex, node

	-- Handle standard inline flag toggles e.g. `(?i)`
	elseif peekChar == ENUM_GROUP_CLOSE then
		local node = GroupInlineFlagsNode()
		node.inlineFlags = {
			enable = enableFlags,
			disable = disableFlags
		}
		return peekIndex, node
	else
		return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
	end
end
