--[[
	Lookup table containing all line break characters recognized by the
	regular expression engine.

	Supports both string and byte representations to avoid conversions
	during matching.
]]

--[[ Globals ]]--
local string_byte = string.byte

--[[ Module ]]--

return {
	["\n"] = true,
	["\r"] = true,
	[string_byte("\n")] = true,
	[string_byte("\r")] = true,
}
