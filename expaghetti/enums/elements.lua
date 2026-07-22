--[[
    AST element type identifiers.

    These values uniquely identify the different kinds of AST nodes produced
    by the parser and consumed by the matcher.
]]

return {
	ALTERNATE = "alternate",
	ANCHOR = "anchor",
	ANY = "any",
	BALANCED = "balanced",
	BOUNDARY = "boundary",
	CAPTURE_REFERENCE = "capture_reference",
	GROUP = "group",
	LITERAL = "literal",
	POSITION_CAPTURE = "position_capture",
	QUANTIFIER = "quantifier",
	SET = "set",
}