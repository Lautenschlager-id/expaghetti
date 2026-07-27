--[[
	Replacement template parser.

	Parses a replacement template into an Abstract Syntax Tree (AST)
	composed of literal and backreference elements.
]]

--[[ Dependencies ]]--
local LiteralParse = require("expaghetti.magic.literal").parse
local ParserStateNew = require("expaghetti.parser.state").new

--[[ Module ]]--

--- Parses a replacement template into an Abstract Syntax Tree (AST).
---@param expr string The replacement template to parse.
---@param flags table A table of flag keys.
---@return ASTTree|boolean tree The generated AST tree, or false if parsing failed.
---@return string|nil errorMessage The parser error message on failure.
return function(expr, flags)
	local state = ParserStateNew(expr, flags)

	local tree = {
		_index = 0
	}

	while state.index <= state.patternLength do
		local errorMessage

		local nextIndex, element = state:readReplacementTemplateElement(state.index)
		if not nextIndex then
			return false, element
		end

		if state:isElement(element) then
			-- If the element is already parsed (like an escaped literal), append it to the tree directly.
			state.index = nextIndex

			local treeIndex = tree._index + 1
			tree._index = treeIndex
			tree[treeIndex] = element
		else
			errorMessage = LiteralParse(state, element, tree)
		end

		if errorMessage then
			return false, errorMessage
		end
	end

	return tree
end
