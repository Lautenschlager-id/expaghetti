----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
----------------------------------------------------------------------------------------------------

local flags = {
	CASE_INSENSITIVE = 'i',
	MULTILINE = 'm',
	DOTALL = 's',
	NO_AUTO_CAPTURE = 'n',
	UNICODE = 'u',
}

local inlineFlags = {
	[flags.CASE_INSENSITIVE] = true,
	[flags.MULTILINE] = true,
	[flags.DOTALL] = true,
	[flags.NO_AUTO_CAPTURE] = true,
	[magicEnum.GROUP_FLAGS_DISABLE_BEHAVIOR] = true
}

return {
	flags = flags,
	inlineFlags = inlineFlags
}