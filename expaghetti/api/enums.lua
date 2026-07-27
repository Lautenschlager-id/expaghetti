--[[
	Public API enumerations.

	Exposes the stable enumeration values supported by Expaghetti's
	public API while keeping the engine's internal enumerations
	implementation-private.
]]

--[[ Globals ]]--
local error = error
local next = next
local setmetatable = setmetatable

--[[ Enums ]]--
local Flags = require("expaghetti.enums.flags").FLAGS

--[[ Module ]]--
local Flag = {}
do
	for key, value in next, Flags do
		Flag[key] = value
		Flag[value] = value
	end

	setmetatable(Flag, {
		__newindex = function()
			error("Expaghetti.Flag enum is read-only", 2)
		end
	})
end

return {
	Flag = Flag,
}
