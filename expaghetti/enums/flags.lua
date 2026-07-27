--[[
	Flag definitions used by the parser and matcher.

	Includes the complete set of supported regular expression flags
	and the subset allowed within inline flag groups.
]]

--[[ Enums ]]--
local Magic = require("expaghetti.enums.magic")

--[[ Modules ]]--
local FLAGS = {
	CASE_INSENSITIVE = 'i',
	DOT_ALL = 's',
	MULTILINE = 'm',
	NO_AUTO_CAPTURE = 'n',
	UNICODE = 'u',
}

local INLINE_TOKENS = {
	[FLAGS.CASE_INSENSITIVE] = true,
	[FLAGS.DOT_ALL] = true,
	[FLAGS.MULTILINE] = true,
	[FLAGS.NO_AUTO_CAPTURE] = true,
	[Magic.GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR] = true
}

return {
	FLAGS = FLAGS,
	INLINE_TOKENS = INLINE_TOKENS,
}