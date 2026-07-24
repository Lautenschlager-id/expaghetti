return {
	{
		parsed = {
			{
				isStart = true,
				type = "anchor",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			_index = 3,
		},
		regex = "^ab",
	},
	{
		parsed = {
			{
				isStart = true,
				type = "anchor",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("^"),
			},
			{
				isStart = true,
				type = "anchor",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			_index = 5,
		},
		regex = "^%^^ab",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isStart = false,
				type = "anchor",
			},
			_index = 3,
		},
		regex = "ab$",
	},
	{
		parsed = {
			{
				isStart = true,
				type = "anchor",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isStart = false,
				type = "anchor",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("$"),
			},
			_index = 5,
		},
		regex = "^ab$%$",
	},
	{
		parsed = {
			{
				isStart = false,
				type = "anchor",
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte("$")] = true,
					[string.byte("^")] = true,
				},
			},
			{
				isStart = true,
				type = "anchor",
			},
			_index = 3,
		},
		regex = "$[^$$^]^",
	},
}
