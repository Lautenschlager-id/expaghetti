-- %x

-- [a-zA-Z]
local a = {
	type = "set",

	hasToNegateMatch = false,

	rangeIndex = 4,
	ranges = {
		'a',
		'z',

		'A',
		'Z'
	}
}
-- [0-9]
local d = {
	type = "set",

	hasToNegateMatch = false,

	rangeIndex = 2,
	ranges = {
		'0',
		'9'
	}
}
-- [0-9a-fA-F]
local h = {
	type = "set",

	hasToNegateMatch = false,

	rangeIndex = 6,
	ranges = {
		'0',
		'9',

		'a',
		'f',

		'A',
		'F'
	}
}
-- [a-z]
local l = {
	type = "set",

	hasToNegateMatch = false,

	rangeIndex = 2,
	ranges = {
		'a',
		'z'
	}
}
-- [!-/:-@[-`{-~]
local p = {
	type = "set",

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
	}
}
-- [\f\n\r\t ]
local s = {
	type = "set",

	hasToNegateMatch = false,

	rangeIndex = 0,
	ranges = { },

	['\f'] = true,
	['\n'] = true,
	['\r'] = true,
	['\t'] = true,
	[' '] = true
}
-- [A-Z]
local u = {
	type = "set",

	hasToNegateMatch = false,

	rangeIndex = 2,
	ranges = {
		'A',
		'Z'
	}
}
-- [0-9a-zA-Z_]
local w = {
	type = "set",

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

	['_'] = true
}
local x = h

-- %X

-- [^a-zA-Z]
local A = {
	type = "set",

	hasToNegateMatch = true,

	rangeIndex = 4,
	ranges = {
		'a',
		'z',

		'A',
		'Z'
	}
}
-- [^0-9]
local D = {
	type = "set",

	hasToNegateMatch = true,

	rangeIndex = 2,
	ranges = {
		'0',
		'9'
	}
}
-- [^0-9a-fA-F]
local H = {
	type = "set",

	hasToNegateMatch = true,

	rangeIndex = 6,
	ranges = {
		'0',
		'9',

		'a',
		'f',

		'A',
		'F'
	}
}
-- [^a-z]
local L = {
	type = "set",

	hasToNegateMatch = true,

	rangeIndex = 2,
	ranges = {
		'a',
		'z'
	}
}
-- [^!-/:-@[-`{-~]
local P = {
	type = "set",

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
	}
}
-- [^\f\n\r\t ]
local S = {
	type = "set",

	hasToNegateMatch = true,

	rangeIndex = 0,
	ranges = { },

	['\f'] = true,
	['\n'] = true,
	['\r'] = true,
	['\t'] = true,
	[' '] = true
}
-- [^A-Z]
local U = {
	type = "set",

	hasToNegateMatch = true,

	rangeIndex = 2,
	ranges = {
		'A',
		'Z'
	}
}
-- [^0-9a-zA-Z_]
local W = {
	type = "set",

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

	['_'] = true
}
local X = H

return {
	a = a,
	d = d,
	h = h,
	l = l,
	p = p,
	s = s,
	u = u,
	w = w,
	x = x,

	A = A,
	D = D,
	H = H,
	L = L,
	P = P,
	S = S,
	U = U,
	W = W,
	X = X,
}