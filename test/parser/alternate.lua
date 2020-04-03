local test = require("../../test/util")

test.assertion.object(
	"ab|c",
	{
		type = "alternate",
		trees = {
			_index = 2,
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
			_index = 3,
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

test.assertion.object(
	"h(e|y|ey)",
	{
		'h',
		{
			type = "group",
			_behind = false,
			effect = nil,
			_index = 6,
			tree = {
				_index = 1,
				stack = {
					{
						type = "alternate",
						trees = {
							_index = 3,
							[1] = {
								_index = 1,
								stack = {
									'e'
								}
							},
							[2] = {
								_index = 1,
								stack = {
									'y'
								}
							},
							[3] = {
								_index = 2,
								stack = {
									'e',
									'y'
								}
							}
						}
					}
				}
			}
		}
	},
	true
)

return test.assertion.get()