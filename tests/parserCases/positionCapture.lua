return {
	{
		parsed = {
			{
				index = 1,
				type = "position_capture"
			},
			_index = 1
		},
		regex = "()"
	},
	{
		parsed = {
			{
				index = 1,
				type = "position_capture"
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a")
			},
			{
				index = 2,
				type = "position_capture"
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a")
			},
			{
				index = 3,
				type = "position_capture"
			},
			_index = 5
		},
		regex = "()a()a()"
	},
	{
		parsed = {
			{
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a")
					},
					{
						index = 1,
						type = "position_capture"
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a")
					},
					_index = 3
				},
				type = "group",
				index = 1
			},
			_index = 1
		},
		regex = "(a()a)"
	},
	{
		parsed = {
			{
				branches = {
					{
						{
							tree = {
								{
									index = 1,
									type = "position_capture"
								},
								_index = 1
							},
							hasSpecialBehavior = true,
							isLookahead = true,
							type = "group",
							isNonCapturing = true
						},
						_index = 1
					},
					{
						{
							index = 2,
							type = "position_capture"
						},
						_index = 1
					},
					_index = 2
				},
				type = "alternate"
			},
			_index = 1
		},
		regex = "(?=())|()"
	}
}
