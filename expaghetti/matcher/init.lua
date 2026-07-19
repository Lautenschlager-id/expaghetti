----------------------------------------------------------------------------------------------------
local parser = require("parser")
local MatchState = require("matcher.state")
----------------------------------------------------------------------------------------------------
local coreTreeMatcher = require("matcher.core")
----------------------------------------------------------------------------------------------------

local matcher = function(expr, str, flags, stringIndex)
	if type(expr) ~= "string" then
		return false, "Expression must be a string"
	end
	if type(str) ~= "string" then
		return false, "Target must be a string"
	end

	if type(flags) == "string" then
		local t = {}
		for char in flags:gmatch(".") do
			t[char] = true
		end
		flags = t
	else
		flags = flags or {}
	end

	local tree, errorMessage = parser(expr, flags)
	if not tree then
		return false, errorMessage
	end

	stringIndex = stringIndex or 0

	local state = MatchState.new(flags, str, tree)

	local hasMatched, iniStr, endStr, matcherMetaData
	while stringIndex <= state.targetStringLength do
		state:reset(stringIndex)
		state.tree = tree
		state.treeIndex = 0
		
		hasMatched, iniStr, endStr, matcherMetaData = coreTreeMatcher(state)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData
		end

		stringIndex = stringIndex + 1
	end
end

MatchState.matcher = coreTreeMatcher

return matcher
