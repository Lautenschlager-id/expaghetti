--[[ Dependencies ]]--
local LiteralParse = require("magic.literal").parse
local ParserStateNew = require("parser.state").new

--[[ Module ]]--
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
