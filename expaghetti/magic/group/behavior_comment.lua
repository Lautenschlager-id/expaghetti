----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------

-- Parses comment group behavior `(?#...)`.
-- Comment groups are ignored during matching and excluded from the tree.
return function(state, peekIndex)
	return peekIndex, AST.GroupComment()
end
