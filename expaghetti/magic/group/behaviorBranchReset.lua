----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------

-- Parses branch reset group behavior `(?|...)`.
-- Branch reset groups reset capture indices for each alternative branch.
return function(state, peekIndex)
	return peekIndex, AST.GroupBranchReset()
end
