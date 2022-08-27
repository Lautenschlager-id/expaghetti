----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local parser = require("./parser")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local function matcher(expr, str, flags)
	flags = flags or { }

	local tree = parser(expr, flags)
	local splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

	return splitStr
end

----------------------------------------------------------------------------------------------------
-- Debugging
local p = require("./helpers/pretty-print")
local see = function(t) print(p(t, true)) end

see(matcher("abc", "not abacate"))
see(matcher("abc", "abacatãozão", { ['u'] = true }))
see(matcher("abc", "abacatãozão", { ['u'] = false }))

----------------------------------------------------------------------------------------------------

return matcher