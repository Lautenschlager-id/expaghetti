return {
	{
		parsed = {
			{
				isBeginning = true,
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
				isBeginning = true,
				type = "anchor",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("^"),
			},
			{
				isBeginning = true,
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
				isBeginning = false,
				type = "anchor",
			},
			_index = 3,
		},
		regex = "ab$",
	},
	{
		parsed = {
			{
				isBeginning = true,
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
				isBeginning = false,
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
				isBeginning = false,
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
				isBeginning = true,
				type = "anchor",
			},
			_index = 3,
		},
		regex = "$[^$$^]^",
	},
}
