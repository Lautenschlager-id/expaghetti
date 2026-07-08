----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_SET = require("./enums/elements").set
----------------------------------------------------------------------------------------------------
-- %x

-- [a-zA-Z]
local a = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 4,
	ranges = { 'a', 'z', 'A', 'Z' },
	unicodeRanges = { 'a', 'z', 'A', 'Z' },
	byteRanges = { 97, 122, 65, 90 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [0-9]
local d = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 2,
	ranges = { '0', '9' },
	unicodeRanges = { '0', '9' },
	byteRanges = { 48, 57 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [0-9a-fA-F]
local h = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 6,
	ranges = { '0', '9', 'a', 'f', 'A', 'F' },
	unicodeRanges = { '0', '9', 'a', 'f', 'A', 'F' },
	byteRanges = { 48, 57, 97, 102, 65, 70 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [a-z]
local l = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 2,
	ranges = { 'a', 'z' },
	unicodeRanges = { 'a', 'z' },
	byteRanges = { 97, 122 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [!-/:-@[-`{-~]
local p = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 8,
	ranges = { '!', '/', ':', '@', '[', '`', '{', '~' },
	unicodeRanges = { '!', '/', ':', '@', '[', '`', '{', '~' },
	byteRanges = { 33, 47, 58, 64, 91, 96, 123, 126 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [\f\n\r\t ]
local s = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 0,
	ranges = { },
	unicodeRanges = { },
	byteRanges = { },
	classIndex = 0,
	classes = { },
	unicodeKeys = { ['\f'] = true, ['\n'] = true, ['\r'] = true, ['\t'] = true, [' '] = true },
	byteKeys = { [12] = true, [10] = true, [13] = true, [9] = true, [32] = true }
}
-- [A-Z]
local u = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 2,
	ranges = { 'A', 'Z' },
	unicodeRanges = { 'A', 'Z' },
	byteRanges = { 65, 90 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [0-9a-zA-Z_]
local w = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = false,
	rangeIndex = 6,
	ranges = { '0', '9', 'a', 'z', 'A', 'Z' },
	unicodeRanges = { '0', '9', 'a', 'z', 'A', 'Z' },
	byteRanges = { 48, 57, 97, 122, 65, 90 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { ['_'] = true },
	byteKeys = { [95] = true }
}

-- %X

-- [^a-zA-Z]
local A = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 4,
	ranges = { 'a', 'z', 'A', 'Z' },
	unicodeRanges = { 'a', 'z', 'A', 'Z' },
	byteRanges = { 97, 122, 65, 90 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [^0-9]
local D = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 2,
	ranges = { '0', '9' },
	unicodeRanges = { '0', '9' },
	byteRanges = { 48, 57 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [^0-9a-fA-F]
local H = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 6,
	ranges = { '0', '9', 'a', 'f', 'A', 'F' },
	unicodeRanges = { '0', '9', 'a', 'f', 'A', 'F' },
	byteRanges = { 48, 57, 97, 102, 65, 70 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [^a-z]
local L = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 2,
	ranges = { 'a', 'z' },
	unicodeRanges = { 'a', 'z' },
	byteRanges = { 97, 122 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [^!-/:-@[-`{-~]
local P = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 8,
	ranges = { '!', '/', ':', '@', '[', '`', '{', '~' },
	unicodeRanges = { '!', '/', ':', '@', '[', '`', '{', '~' },
	byteRanges = { 33, 47, 58, 64, 91, 96, 123, 126 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [^\f\n\r\t ]
local S = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 0,
	ranges = { },
	unicodeRanges = { },
	byteRanges = { },
	classIndex = 0,
	classes = { },
	unicodeKeys = { ['\f'] = true, ['\n'] = true, ['\r'] = true, ['\t'] = true, [' '] = true },
	byteKeys = { [12] = true, [10] = true, [13] = true, [9] = true, [32] = true }
}
-- [^A-Z]
local U = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 2,
	ranges = { 'A', 'Z' },
	unicodeRanges = { 'A', 'Z' },
	byteRanges = { 65, 90 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { },
	byteKeys = { }
}
-- [^0-9a-zA-Z_]
local W = {
	type = ENUM_ELEMENT_TYPE_SET,
	hasToNegateMatch = true,
	rangeIndex = 6,
	ranges = { '0', '9', 'a', 'z', 'A', 'Z' },
	unicodeRanges = { '0', '9', 'a', 'z', 'A', 'Z' },
	byteRanges = { 48, 57, 97, 122, 65, 90 },
	classIndex = 0,
	classes = { },
	unicodeKeys = { ['_'] = true },
	byteKeys = { [95] = true }
}

return {
	a = a,
	d = d,
	h = h,
	l = l,
	p = p,
	s = s,
	u = u,
	w = w,
	x = h,

	A = A,
	D = D,
	H = H,
	L = L,
	P = P,
	S = S,
	U = U,
	W = W,
	X = H,
}