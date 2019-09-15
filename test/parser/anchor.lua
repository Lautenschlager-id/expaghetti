local test = require("../../test/util")

test.assertion.object(
	'^',
	{
		type = "anchor",
		anchor = '^'
	},
	"The anchor '^' has failed."
)

test.assertion.object(
	'$',
	{
		type = "anchor",
		anchor = '$'
	},
	"The anchor '$' has failed."
)

test.assertion.object(
	"%b",
	{
		type = "anchor",
		anchor = 'b'
	},
	"The anchor '%b' has failed."
)

test.assertion.object(
	"%B",
	{
		type = "anchor",
		anchor = 'B'
	},
	"The anchor '%B' has failed."
)

return test.assertion.get()