----------------------------------------------------------------------------------------------------
local parser = require("parser.init")
local MatchState = require("matcher.state")
----------------------------------------------------------------------------------------------------
local coreTreeMatcher = require("matcher.core")
----------------------------------------------------------------------------------------------------

--- The main matching engine entry point. Evaluates a regex expression against a target string.
---@param expr string The regular expression pattern.
---@param str string The target string to match against.
---@param flags string|table|nil A string of flag characters or a table of boolean flags.
---@param stringIndex number|nil The starting 0-indexed string index (defaults to 0).
---@return boolean hasMatched True if the pattern successfully matched the target.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return table|nil matcherMetaData Extracted metadata (e.g., capture groups).
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
