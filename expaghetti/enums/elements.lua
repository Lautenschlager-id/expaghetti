--[[
    AST element type identifiers.

    These values uniquely identify the different kinds of AST nodes produced
    by the parser and consumed by the matcher.
]]

return {
	alternate = "alternate",
	anchor = "anchor",
	any = "any",
	balanced = "balanced",
	boundary = "boundary",
	captureReference = "captureReference",
	group = "group",
	literal = "literal",
	positionCapture = "positionCapture",
	quantifier = "quantifier",
	set = "set",
}