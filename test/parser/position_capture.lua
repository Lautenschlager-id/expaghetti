local test = require("../../test/util")

test.assertion.object(
	"()",
	{
		type = "position_capture"
	}
)

return test.assertion.get()