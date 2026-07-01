----------------------------------------------------------------------------------------------------
local Quantifier = require("./magic/Quantifier")
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_LITERAL = require("./enums/elements").literal
----------------------------------------------------------------------------------------------------
local Literal = { }

Literal.parse = function(state, currentCharacter, tree)
	-- tree is a bad parameter, but if it's true then an error is thrown anyway
	if Quantifier.isToken(state, tree) then
		return false, errorsEnum.nothingToRepeat
	end

	tree._index = tree._index + 1
	local node = AST.Literal(currentCharacter)
	if state.flags.i and type(currentCharacter) == "string" then
		node.isCaseInsensitive = true
		node.lowercaseValue = string.lower(currentCharacter)
	end
	tree[tree._index] = node

	return state.index + 1
end

return Literal