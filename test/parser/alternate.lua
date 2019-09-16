local test = require("../../test/util")

test.assertion.object(
	"ab|c",
	{
		type = "alternate",
		trees = {
			[1] = {
				_index = 2,
				stack = {
					'a',
					'b'
				}
			},
			[2] = {
				_index = 1,
				stack = {
					'c'
				}
			}
		}
	}
)

test.assertion.object(
	"%cA|c|",
	{
		type = "alternate",
		trees = {
			[1] = {
				_index = 1,
				stack = {
					'\001'
				}
			},
			[2] = {
				_index = 1,
				stack = {
					'c'
				}
			},
			[3] = {
				_index = 0,
				stack = { }
			}
		}
	}
)

return test.assertion.get()