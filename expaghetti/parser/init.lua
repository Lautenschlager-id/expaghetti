----------------------------------------------------------------------------------------------------
local ParserState = require("parser.state")
----------------------------------------------------------------------------------------------------
local parserCore = require("parser.core")
----------------------------------------------------------------------------------------------------

--- The main parser entry point. Parses a regex expression string into an AST.
---@param exprOrState string|table The regular expression string or an existing ParserState.
---@param flags string|table|nil A string of flag characters or a table of boolean flags.
---@return table|boolean tree The generated AST, or false if an error occurred.
---@return string|table|nil errorMessage An error message or error token if parsing failed.
local parser = function(exprOrState, flags)
	local state
	if exprOrState.__index then
		state = exprOrState
	else
		state = ParserState.new(exprOrState, flags)
	end

	local tree, errorMessage = parserCore(state)
	if not tree then
		return false, errorMessage
	end
	
	-- Upon successful parsing, attach metadata (like capture group contexts) to the ROOT of the tree.
	-- We prevent attaching metadata to sub-trees (groups and alternates) to avoid data duplication
	-- and keep the tree lightweight.
	if not state.isGroup and not state.isAlternate then
		tree._metaData = state.metaData
	end

	return tree
end

ParserState.parser = parser

return parser
