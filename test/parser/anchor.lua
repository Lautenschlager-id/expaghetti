local test = require("../../test/util")

test.assertion.object(
	'^',
	{
		type = "anchor",
		anchor = '^'
	}
)

test.assertion.object(
	'$',
	{
		type = "anchor",
		anchor = '$'
	}
)

test.assertion.object(
	"%b",
	{
		type = "anchor",
		anchor = 'b'
	}
)

test.assertion.object(
	"%B",
	{
		type = "anchor",
		anchor = 'B'
	}
)

return test.assertion.get()