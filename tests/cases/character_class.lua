return {
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					string.byte("a"),
					string.byte("z"),
					string.byte("A"),
					string.byte("Z"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%a",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					string.byte("0"),
					string.byte("9"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%d",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 6,
				ranges = {
					string.byte("0"),
					string.byte("9"),
					string.byte("a"),
					string.byte("f"),
					string.byte("A"),
					string.byte("F"),
				},
				type = "set",
				values = {
				},
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 6,
				ranges = {
					string.byte("0"),
					string.byte("9"),
					string.byte("a"),
					string.byte("f"),
					string.byte("A"),
					string.byte("F"),
				},
				type = "set",
				values = {
				},
			},
			_index = 2,
		},
		regex = "%h%x",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					string.byte("a"),
					string.byte("z"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%l",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 8,
				ranges = {
					string.byte("!"),
					string.byte("/"),
					string.byte(":"),
					string.byte("@"),
					string.byte("["),
					string.byte("`"),
					string.byte("{"),
					string.byte("~"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%p",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(" ")] = true,
					[string.byte("\n")] = true,
					[string.byte("\12")] = true,
					[string.byte("\13")] = true,
					[string.byte("\9")] = true,
				},
			},
			_index = 1,
		},
		regex = "%s",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					string.byte("A"),
					string.byte("Z"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%u",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 6,
				ranges = {
					string.byte("0"),
					string.byte("9"),
					string.byte("a"),
					string.byte("z"),
					string.byte("A"),
					string.byte("Z"),
				},
				type = "set",
				values = {
					[string.byte("_")] = true,
				},
			},
			_index = 1,
		},
		regex = "%w",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 4,
				ranges = {
					string.byte("a"),
					string.byte("z"),
					string.byte("A"),
					string.byte("Z"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%A",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					string.byte("0"),
					string.byte("9"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%D",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 6,
				ranges = {
					string.byte("0"),
					string.byte("9"),
					string.byte("a"),
					string.byte("f"),
					string.byte("A"),
					string.byte("F"),
				},
				type = "set",
				values = {
				},
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 6,
				ranges = {
					string.byte("0"),
					string.byte("9"),
					string.byte("a"),
					string.byte("f"),
					string.byte("A"),
					string.byte("F"),
				},
				type = "set",
				values = {
				},
			},
			_index = 2,
		},
		regex = "%H%X",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					string.byte("a"),
					string.byte("z"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%L",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 8,
				ranges = {
					string.byte("!"),
					string.byte("/"),
					string.byte(":"),
					string.byte("@"),
					string.byte("["),
					string.byte("`"),
					string.byte("{"),
					string.byte("~"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%P",
	},
	{
		parsed = {
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
					[string.byte(" ")] = true,
					[string.byte("\n")] = true,
					[string.byte("\12")] = true,
					[string.byte("\13")] = true,
					[string.byte("\9")] = true,
				},
			},
			_index = 1,
		},
		regex = "%S",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					string.byte("A"),
					string.byte("Z"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%U",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 6,
				ranges = {
					string.byte("0"),
					string.byte("9"),
					string.byte("a"),
					string.byte("z"),
					string.byte("A"),
					string.byte("Z"),
				},
				type = "set",
				values = {
					[string.byte("_")] = true,
				},
			},
			_index = 1,
		},
		regex = "%W",
	},
}
