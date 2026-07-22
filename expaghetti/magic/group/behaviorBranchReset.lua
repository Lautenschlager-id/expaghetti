--[[
    Parser for the branch reset group behavior `(?|...)`.
]]

--[[ Dependencies ]]--
local GroupBranchResetNode = require("ast").GroupBranchReset

--[[ Module ]]--

--- Parses the branch reset group behavior `(?|...)`.
---@param state ParserState The current parser state.
---@param peekIndex number The parser index immediately after the behavior token.
---@return number nextIndex The parser index after consuming the behavior.
---@return table group The parsed AST group node.
return function(state, peekIndex)
	return peekIndex, GroupBranchResetNode()
end
