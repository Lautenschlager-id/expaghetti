--[[
    Parser for the atomic group behavior `(?>...)`.
]]

--[[ Dependencies ]]--
local GroupAtomicNode = require("ast").GroupAtomic

--[[ Module ]]--

--- Parses the atomic group behavior `(?>...)`.
---@param state ParserState The current parser state.
---@param peekIndex number The parser index immediately after the behavior token.
---@return number nextIndex The parser index after consuming the behavior.
---@return table group The parsed AST group node.
return function(state, peekIndex)
	return peekIndex, GroupAtomicNode()
end
