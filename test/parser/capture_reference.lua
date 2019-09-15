local test = require("../../test/util")

test.assertion.object(
	"%1",
	{
		type = "capture_reference",
		value = 1
	}
)

return test.assertion.get()