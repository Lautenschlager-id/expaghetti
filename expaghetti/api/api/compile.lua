--[[
	Compiles regular expressions into reusable Pattern objects.

	Implements the compilation API that parses a pattern once
	and returns a reusable Pattern instance.
]]

--[[ Dependencies ]]--
local PatternNew = require("core.pattern").new

--[[ Module ]]--
return function(api, compilePattern)
	--- Compiles a regular expression into a reusable pattern.
	--- Parses and validates the pattern, returning a compiled Pattern
	--- instance that can be reused across multiple matching operations.
	---@param regex string The regular expression to compile.
	---@param flags string|RegexFlag[]|nil Optional regular expression flags.
	---@return Pattern|nil pattern The compiled pattern.
	---@return string|nil errorMessage The compilation error message, if compilation fails.
	return function(regex, flags)
		local tree, parsedFlags, errorMessage = compilePattern(regex, flags)
		if not tree then
			return nil, errorMessage
		end
		return PatternNew(api, tree, parsedFlags)
	end
end
