local test = require("../../test/util")

-- X, Y
test.assertion.object(
	"a{5,9}",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = 5,
			[2] = 9
		},
		'a'
	},
	true
)

test.assertion.object(
	"a{5123,12319}",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = 5123,
			[2] = 12319
		},
		'a'
	},
	true
)

-- N
test.assertion.object(
	"a{2}",
	{
		{
			type = "quantifier",
			_index = 1,
			effect = nil,
			[1] = 2,
			[2] = nil
		},
		'a'
	},
	true
)

-- X, N
test.assertion.object(
	"a{5,}",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = 5,
			[2] = nil
		},
		'a'
	},
	true
)

-- N, X
test.assertion.object(
	"a{,5}",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = nil,
			[2] = 5
		},
		'a'
	},
	true
)

-- Operators
test.assertion.object(
	"a+",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = 1,
			[2] = nil
		},
		'a'
	},
	true
)

test.assertion.object(
	"a*",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = 0,
			[2] = nil
		},
		'a'
	},
	true
)

test.assertion.object(
	"a?",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = nil,
			[1] = 0,
			[2] = 1
		},
		'a'
	},
	true
)

-- Lazy
test.assertion.object(
	"a{3,5}?",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "?",
			[1] = 3,
			[2] = 5
		},
		'a'
	},
	true
)

test.assertion.object(
	"a+?",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "?",
			[1] = 1,
			[2] = nil
		},
		'a'
	},
	true
)

test.assertion.object(
	"a*?",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "?",
			[1] = 0,
			[2] = nil
		},
		'a'
	},
	true
)

test.assertion.object(
	"a??",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "?",
			[1] = 0,
			[2] = 1
		},
		'a'
	},
	true
)

-- Atomic
test.assertion.object(
	"a{3,5}+",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "+",
			[1] = 3,
			[2] = 5
		},
		'a'
	},
	true
)

test.assertion.object(
	"a++",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "+",
			[1] = 1,
			[2] = nil
		},
		'a'
	},
	true
)

test.assertion.object(
	"a*+",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "+",
			[1] = 0,
			[2] = nil
		},
		'a'
	},
	true
)

test.assertion.object(
	"a?+",
	{
		{
			type = "quantifier",
			_index = 2,
			effect = "+",
			[1] = 0,
			[2] = 1
		},
		'a'
	},
	true
)

return test.assertion.get()