----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_SET = require("./enums/elements").set
----------------------------------------------------------------------------------------------------
-- %x

-- [a-zA-Z]
local a = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 4,
	ranges = {
		'a',
		'z',

		'A',
		'Z'
	},

	classIndex = 0,
	classes = { }
}
-- [0-9]
local d = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 2,
	ranges = {
		'0',
		'9'
	},

	classIndex = 0,
	classes = { }
}
-- [0-9a-fA-F]
local h = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 6,
	ranges = {
		'0',
		'9',

		'a',
		'f',

		'A',
		'F'
	},

	classIndex = 0,
	classes = { }
}
-- [a-z]
local l = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 2,
	ranges = {
		'a',
		'z'
	},

	classIndex = 0,
	classes = { }
}
-- [!-/:-@[-`{-~]
local p = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 8,
	ranges = {
		'!',
		'/',

		':',
		'@',

		'[',
		'`',

		'{',
		'~'
	},

	classIndex = 0,
	classes = { }
}
-- [\f\n\r\t ]
local s = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 0,
	ranges = { },

	classIndex = 0,
	classes = { },

	['\f'] = true,
	['\n'] = true,
	['\r'] = true,
	['\t'] = true,
	[' '] = true
}
-- [A-Z]
local u = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 2,
	ranges = {
		'A',
		'Z'
	},

	classIndex = 0,
	classes = { }
}
-- [0-9a-zA-Z_]
local w = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = false,

	rangeIndex = 6,
	ranges = {
		'0',
		'9',

		'a',
		'z',

		'A',
		'Z'
	},

	classIndex = 0,
	classes = { },

	['_'] = true
}

-- %X

-- [^a-zA-Z]
local A = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 4,
	ranges = {
		'a',
		'z',

		'A',
		'Z'
	},

	classIndex = 0,
	classes = { }
}
-- [^0-9]
local D = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 2,
	ranges = {
		'0',
		'9'
	},

	classIndex = 0,
	classes = { }
}
-- [^0-9a-fA-F]
local H = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 6,
	ranges = {
		'0',
		'9',

		'a',
		'f',

		'A',
		'F'
	},

	classIndex = 0,
	classes = { }
}
-- [^a-z]
local L = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 2,
	ranges = {
		'a',
		'z'
	},

	classIndex = 0,
	classes = { }
}
-- [^!-/:-@[-`{-~]
local P = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 8,
	ranges = {
		'!',
		'/',

		':',
		'@',

		'[',
		'`',

		'{',
		'~'
	},

	classIndex = 0,
	classes = { }
}
-- [^\f\n\r\t ]
local S = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 0,
	ranges = { },

	classIndex = 0,
	classes = { },

	['\f'] = true,
	['\n'] = true,
	['\r'] = true,
	['\t'] = true,
	[' '] = true
}
-- [^A-Z]
local U = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 2,
	ranges = {
		'A',
		'Z'
	},

	classIndex = 0,
	classes = { }
}
-- [^0-9a-zA-Z_]
local W = {
	type = ENUM_ELEMENT_TYPE_SET,

	hasToNegateMatch = true,

	rangeIndex = 6,
	ranges = {
		'0',
		'9',

		'a',
		'z',

		'A',
		'Z'
	},

	classIndex = 0,
	classes = { },

	['_'] = true
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