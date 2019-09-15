local test = require("../../test/util")

-- Empty
test.assertion.object(
	"[]",
	nil
)

-- Set
test.assertion.object(
	"[abc]",
	{
		type = "set",
		_hasValue = true,
		_negated = false,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 0,
		_set = { },
		['a'] = true,
		['b'] = true,
		['c'] = true
	}
)

-- Negated set
test.assertion.object(
	"[^abc]",
	{
		type = "set",
		_hasValue = true,
		_negated = true,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 0,
		_set = { },
		['a'] = true,
		['b'] = true,
		['c'] = true
	}
)

-- Range
test.assertion.object(
	"[a-z]",
	{
		type = "set",
		_hasValue = true,
		_negated = false,
		_rangeIndex = 1,
		_min = { 'a' },
		_max = { 'z' },
		_setIndex = 0,
		_set = { }
	}
)

-- Negated range
test.assertion.object(
	"[^a-z]",
	{
		type = "set",
		_hasValue = true,
		_negated = true,
		_rangeIndex = 1,
		_min = { 'a' },
		_max = { 'z' },
		_setIndex = 0,
		_set = { }
	}
)


-- Set with range
test.assertion.object(
	"[a-z123]",
	{
		type = "set",
		_hasValue = true,
		_negated = false,
		_rangeIndex = 1,
		_min = { 'a' },
		_max = { 'z' },
		_setIndex = 0,
		_set = { },
		['1'] = true,
		['2'] = true,
		['3'] = true
	}
)

-- Set with magic
test.assertion.object(
	"[()%$%]]",
	{
		type = "set",
		_hasValue = true,
		_negated = false,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 0,
		_set = { },
		['('] = true,
		[')'] = true,
		['$'] = true,
		[']'] = true
	}
)

-- Set with class
test.assertion.object(
	"[%w]",
	{
		type = "set",
		_hasValue = true,
		_negated = false,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 1,
		_set = {
			{
				type = "set",
				_hasValue = true,
				_negated = false,
				_rangeIndex = 3,
				_min = { '0', 'a', 'A' },
				_max = { '9', 'z', 'Z' },
				_setIndex = 0,
				_set = { },
				['_'] = true
			}
		}
	}
)

-- Negated set with class
test.assertion.object(
	"[^%w]",
	{
		type = "set",
		_hasValue = true,
		_negated = true,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 1,
		_set = {
			{
				type = "set",
				_hasValue = true,
				_negated = false,
				_rangeIndex = 3,
				_min = { '0', 'a', 'A' },
				_max = { '9', 'z', 'Z' },
				_setIndex = 0,
				_set = { },
				['_'] = true
			}
		}
	}
)

-- Set with ']'
test.assertion.object(
	"[]a]",
	{
		type = "set",
		_hasValue = true,
		_negated = false,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 0,
		_set = { },
		[']'] = true,
		['a'] = true
	}
)

-- Negated set with ']'
test.assertion.object(
	"[^]a]",
	{
		type = "set",
		_hasValue = true,
		_negated = true,
		_rangeIndex = 0,
		_min = { },
		_max = { },
		_setIndex = 0,
		_set = { },
		[']'] = true,
		['a'] = true
	}
)

return test.assertion.get()