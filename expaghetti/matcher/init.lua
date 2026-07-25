--[[
    Matcher entry point.

    Evaluates a regular expression against a target string.
]]

--[[ Dependencies ]]--
local coreTreeMatcher = require("matcher.core")
local MatchState = require("matcher.state")
local parser = require("parser.init")

--[[ Aliases ]]--
local MatchStateNew = MatchState.new

--[[ Module ]]--

--- Evaluates a regular expression against a target string.
---@param expr string The regular expression.
---@param str string The target string to match against.
---@param flags string|FlagTable|nil A string of flag characters or a table of boolean flags.
---@param stringIndex number|nil The 0-based starting position in the target string (defaults to 0).
---@return boolean hasMatched True if the pattern successfully matched the target.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return MatcherMetadata|nil matcherMetadata The match metadata.
local matcher = function(expr, str, flags, stringIndex, config)
	if type(str) ~= "string" then
		return false, "Target must be a string"
	end

	local tree, errorMessage = expr

	stringIndex = stringIndex or 0

	local state = MatchStateNew(flags, str, tree, config)

	local hasMatched, iniStr, endStr, matcherMetadata
	while stringIndex <= state.targetStringLength do
		state:reset(stringIndex)
		state.tree = tree
		state.treeIndex = 0
		
		hasMatched, iniStr, endStr, matcherMetadata = coreTreeMatcher(state)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetadata
		end

		stringIndex = stringIndex + 1
	end
end

MatchState.matcher = coreTreeMatcher

return matcher
