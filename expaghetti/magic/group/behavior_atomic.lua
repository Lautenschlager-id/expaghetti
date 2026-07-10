----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------

-- Parses atomic group behavior `(?>...)`.
-- Atomic groups prevent backtracking into the group once it matches.
return function(state, peekIndex)
	return peekIndex, AST.GroupAtomic()
end
