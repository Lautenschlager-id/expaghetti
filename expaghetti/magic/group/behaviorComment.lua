--[[
	Parser for the comment group behavior `(?#...)`.
]]

--[[ Dependencies ]]--
local GroupCommentNode = require("expaghetti.core.ast").GroupComment

--[[ Module ]]--

--- Parses the comment group behavior `(?#...)`.
---@param state ParserState The current parser state.
---@param peekIndex number The parser index after the behavior token.
---@return number nextIndex The parser index after the behavior.
---@return table group The parsed AST group node.
return function(state, peekIndex)
	return peekIndex, GroupCommentNode()
end
