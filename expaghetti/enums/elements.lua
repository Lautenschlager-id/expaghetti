--[[
    AST element type identifiers.

    These values uniquely identify the different kinds of AST nodes produced
    by the parser and consumed by the matcher.
]]

--[[ Module ]]--

return {
	ALTERNATE = "alternate",
	ANCHOR = "anchor",
	ANY = "any",
	BALANCED = "balanced",
	FRONTIER = "frontier",
	BACKREFERENCE = "backreference",
	GROUP = "group",
	LITERAL = "literal",
	POSITION_CAPTURE = "position_capture",
	QUANTIFIER = "quantifier",
	SET = "set",
}