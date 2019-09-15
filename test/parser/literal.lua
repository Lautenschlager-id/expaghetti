local test = require("../../test/util")

test.assertion.object(
	"abcde",
	{
		'a',
		'b',
		'c',
		'd',
		'e'
	},
	true
)

return test.assertion.get()