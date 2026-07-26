--[[
	Parses a regular expression into an Abstract Syntax Tree (AST).
]]

--[[ Dependencies ]]--
local ParserState = require("parser.state")
local parserCore = require("parser.core")

--[[ Aliases ]]--
local ParserStateNew = ParserState.new

--[[ Module ]]--

--- Parses a regular expression into an Abstract Syntax Tree (AST).
---@param exprOrState string|ParserState The regular expression string or an existing parser state.
---@param flags table A table of flag keys.
---@return ASTTree|boolean tree The generated AST, or false if parsing failed.
---@return string|nil errorMessage The parser error message on failure.
local parser = function(exprOrState, flags)
	local state
	if exprOrState.__index then
		state = exprOrState
	else
		state = ParserStateNew(exprOrState, flags)
	end

	local tree, errorMessage = parserCore(state)
	if not tree then
		return false, errorMessage
	end

	-- Perform root-level post-processing.
	-- Attach parser metadata to the root AST and resolve all deferred named
	-- references once every named capture group has been discovered.
	if not state.isGroup and not state.isAlternate then
		tree._metadata = state.metadata
		state:resolveNamedReferences()
	end

	return tree
end

ParserState.parser = parser

return parser
