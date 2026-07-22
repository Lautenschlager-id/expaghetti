return {
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
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
					[string.byte("B")] = true,
					[string.byte("D")] = true,
					[string.byte("[")] = true,
					[string.byte("\1")] = true,
					[string.byte("a")] = true,
					[string.byte("c")] = true,
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			_index = 3,
		},
		regex = "a[aB%cAc[D]b",
	},
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
					string.byte("b"),
					string.byte("c"),
					string.byte("d"),
				},
				type = "set",
				values = {
					[string.byte("-")] = true,
				},
			},
			_index = 1,
		},
		regex = "[a-b-c-d]",
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
					[string.byte("]")] = true,
					[string.byte("a")] = true,
				},
			},
			_index = 1,
		},
		regex = "[]a]",
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
					[string.byte("]")] = true,
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("]"),
			},
			_index = 3,
		},
		regex = "[]]a]",
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
					[string.byte("]")] = true,
					[string.byte("a")] = true,
				},
			},
			_index = 1,
		},
		regex = "[^]a]",
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
					[string.byte("]")] = true,
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("]"),
			},
			_index = 3,
		},
		regex = "[^]]a]",
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
					[string.byte("a")] = true,
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("]"),
			},
			_index = 2,
		},
		regex = "[^a]]",
	},
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
					string.byte("b"),
					string.byte("c"),
					string.byte("d"),
				},
				type = "set",
				values = {
					[string.byte("-")] = true,
				},
			},
			_index = 1,
		},
		regex = "[-a-b-c-d-]",
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
					string.byte("\1"),
					string.byte("\2"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "[%cA-%cb]",
	},
	{
		parsed = {
			{
				classIndex = 3,
				classes = {
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
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
					[string.byte("^")] = true,
				},
			},
			_index = 1,
		},
		regex = "[%w.%a^%U]",
	},
	{
		parsed = {
			{
				classIndex = 3,
				classes = {
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
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					string.byte("."),
					string.byte("~"),
				},
				type = "set",
				values = {
					[string.byte("^")] = true,
					[string.byte("a")] = true,
				},
			},
			_index = 1,
		},
		regex = "[%w.-~%aa^%U]",
	},
	{
		parsed = {
			{
				classIndex = 1,
				classes = {
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
				},
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					string.byte("U"),
					string.byte("Z"),
				},
				type = "set",
				values = {
					[string.byte("-")] = true,
					[string.byte("Z")] = true,
				},
			},
			_index = 1,
		},
		regex = "[^%UU-ZZ-]",
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
					[string.byte("!")] = true,
					[string.byte("$")] = true,
					[string.byte("%")] = true,
					[string.byte("(")] = true,
					[string.byte(")")] = true,
					[string.byte("*")] = true,
					[string.byte("+")] = true,
					[string.byte(",")] = true,
					[string.byte("-")] = true,
					[string.byte(".")] = true,
					[string.byte(":")] = true,
					[string.byte("<")] = true,
					[string.byte("=")] = true,
					[string.byte(">")] = true,
					[string.byte("?")] = true,
					[string.byte("[")] = true,
					[string.byte("]")] = true,
					[string.byte("^")] = true,
					[string.byte("a")] = true,
					[string.byte("b")] = true,
					[string.byte("{")] = true,
					[string.byte("|")] = true,
					[string.byte("}")] = true,
				},
			},
			_index = 1,
		},
		regex = "[^^$|.%%()?:>=!<{},+*[%]a%-b]",
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
					[string.byte("!")] = true,
					[string.byte("$")] = true,
					[string.byte("%")] = true,
					[string.byte("(")] = true,
					[string.byte(")")] = true,
					[string.byte("*")] = true,
					[string.byte("+")] = true,
					[string.byte(",")] = true,
					[string.byte("-")] = true,
					[string.byte(".")] = true,
					[string.byte(":")] = true,
					[string.byte("<")] = true,
					[string.byte("=")] = true,
					[string.byte(">")] = true,
					[string.byte("?")] = true,
					[string.byte("[")] = true,
					[string.byte("]")] = true,
					[string.byte("^")] = true,
					[string.byte("a")] = true,
					[string.byte("b")] = true,
					[string.byte("{")] = true,
					[string.byte("|")] = true,
					[string.byte("}")] = true,
				},
			},
			_index = 1,
		},
		regex = "[%^^$|.%%()?:>=!<{},+*[%]a%-b]",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("`"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("["),
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					string.byte("["),
					string.byte("]"),
				},
				type = "set",
				values = {
					[string.byte("%")] = true,
					[string.byte("^")] = true,
					[string.byte("w")] = true,
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("]"),
			},
			_index = 4,
		},
		regex = "%c %[[%^%%w[-%]]%]",
	},
	{
		errorMessage = "Invalid regular expression: Expected ']' to close character set",
		regex = "[",
	},
	{
		errorMessage = "Invalid regular expression: Expected ']' to close character set",
		regex = "[^",
	},
	{
		errorMessage = "Invalid regular expression: Expected ']' to close character set",
		regex = "[]",
	},
	{
		errorMessage = "Invalid regular expression: Expected ']' to close character set",
		regex = "[^]",
	},
	{
		errorMessage = "Invalid regular expression: Expected ']' to close character set",
		regex = "[%]",
	},
	{
		errorMessage = "Invalid regular expression: Character range is out of order",
		regex = "[b-a]",
	},
}
