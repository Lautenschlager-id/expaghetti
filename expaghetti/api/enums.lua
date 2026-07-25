local internalFlags = require("enums.flags").FLAGS

local RegexFlag = {}

for k, v in pairs(internalFlags) do
	RegexFlag[k] = v
	RegexFlag[v] = v
end

setmetatable(RegexFlag, {
	__newindex = function()
		error("Expaghetti.RegexFlag enum is read-only")
	end
})

return {
	RegexFlag = RegexFlag
}
