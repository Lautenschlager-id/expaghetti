return {
	{
		flags = {
			u = false,
		},
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("m"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("�"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("�"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("�"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("�"),
			},
			_index = 6,
		},
		regex = "maçã",
	},
	{
		flags = {
			u = true,
		},
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "m",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "a",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "ç",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "ã",
			},
			_index = 4,
		},
		regex = "maçã",
	},
	{
		flags = {
			u = true,
		},
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = " ",
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					"ª",
					"º",
				},
				type = "set",
				values = {
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "↓",
			},
			_index = 3,
		},
		regex = " [^ª-º]↓",
	},
}
