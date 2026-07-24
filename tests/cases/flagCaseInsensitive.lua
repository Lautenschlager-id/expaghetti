return {
	{
		regex = "abc",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("a"),
				type = "literal",
				upperValue = string.byte("A"),
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("b"),
				type = "literal",
				upperValue = string.byte("B"),
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("c"),
				type = "literal",
				upperValue = string.byte("C"),
				value = string.byte("c"),
			},
			_index = 3,
		},
	},
	{
		regex = "ABC",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("a"),
				type = "literal",
				upperValue = string.byte("A"),
				value = string.byte("A"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("b"),
				type = "literal",
				upperValue = string.byte("B"),
				value = string.byte("B"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("c"),
				type = "literal",
				upperValue = string.byte("C"),
				value = string.byte("C"),
			},
			_index = 3,
		},
	},
	{
		regex = "aB",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("a"),
				type = "literal",
				upperValue = string.byte("A"),
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("b"),
				type = "literal",
				upperValue = string.byte("B"),
				value = string.byte("B"),
			},
			_index = 2,
		},
	},
	{
		regex = "%+%*%.",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("+"),
				type = "literal",
				upperValue = string.byte("+"),
				value = string.byte("+"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("*"),
				type = "literal",
				upperValue = string.byte("*"),
				value = string.byte("*"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("."),
				type = "literal",
				upperValue = string.byte("."),
				value = string.byte("."),
			},
			_index = 3,
		},
	},
	{
		regex = "%(%)%[%]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("("),
				type = "literal",
				upperValue = string.byte("("),
				value = string.byte("("),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte(")"),
				type = "literal",
				upperValue = string.byte(")"),
				value = string.byte(")"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("["),
				type = "literal",
				upperValue = string.byte("["),
				value = string.byte("["),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("]"),
				type = "literal",
				upperValue = string.byte("]"),
				value = string.byte("]"),
			},
			_index = 4,
		},
	},
	{
		regex = "%cA%cb",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("\1"),
				type = "literal",
				upperValue = string.byte("\1"),
				value = string.byte("\1"),
			},
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("\2"),
				type = "literal",
				upperValue = string.byte("\2"),
				value = string.byte("\2"),
			},
			_index = 2,
		},
	},
	{
		regex = "%cZ",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = string.byte("\26"),
				type = "literal",
				upperValue = string.byte("\26"),
				value = string.byte("\26"),
			},
			_index = 1,
		},
	},
	{
		regex = "[abc]",
		flags = {
			['i'] = true,
		},
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
					[string.byte("A")] = true,
					[string.byte("B")] = true,
					[string.byte("C")] = true,
					[string.byte("a")] = true,
					[string.byte("b")] = true,
					[string.byte("c")] = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[ABC]",
		flags = {
			['i'] = true,
		},
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
					[string.byte("A")] = true,
					[string.byte("B")] = true,
					[string.byte("C")] = true,
					[string.byte("a")] = true,
					[string.byte("b")] = true,
					[string.byte("c")] = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[a-z]",
		flags = {
			['i'] = true,
		},
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
	},
	{
		regex = "[A-Z]",
		flags = {
			['i'] = true,
		},
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
	},
	{
		regex = "[^a-z]",
		flags = {
			['i'] = true,
		},
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
	},
	{
		regex = "[a-cXY]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					string.byte("a"),
					string.byte("c"),
					string.byte("A"),
					string.byte("C"),
				},
				type = "set",
				values = {
					[string.byte("x")] = true,
					[string.byte("y")] = true,
					[string.byte("X")] = true,
					[string.byte("Y")] = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[^a-cXY]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 4,
				ranges = {
					string.byte("a"),
					string.byte("c"),
					string.byte("A"),
					string.byte("C"),
				},
				type = "set",
				values = {
					[string.byte("x")] = true,
					[string.byte("y")] = true,
					[string.byte("X")] = true,
					[string.byte("Y")] = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%cA-%cb]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					string.byte("\1"),
					string.byte("\2"),
					string.byte("\1"),
					string.byte("\2"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%a]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 1,
				classes = {
					{
						classIndex = 0,
						classes = {
						},
						hasToNegateMatch = false,
						rangeIndex = 8,
						ranges = {
							string.byte("a"),
							string.byte("z"),
							string.byte("A"),
							string.byte("Z"),
							string.byte("a"),
							string.byte("z"),
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
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%d]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 1,
				classes = {
					{
						classIndex = 0,
						classes = {
						},
						hasToNegateMatch = false,
						rangeIndex = 4,
						ranges = {
							string.byte("0"),
							string.byte("9"),
							string.byte("0"),
							string.byte("9"),
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
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%w]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 1,
				classes = {
					{
						classIndex = 0,
						classes = {
						},
						hasToNegateMatch = false,
						rangeIndex = 12,
						ranges = {
							string.byte("0"),
							string.byte("9"),
							string.byte("0"),
							string.byte("9"),
							string.byte("a"),
							string.byte("z"),
							string.byte("A"),
							string.byte("Z"),
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
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%wa]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				classIndex = 1,
				classes = {
					{
						classIndex = 0,
						classes = {
						},
						hasToNegateMatch = false,
						rangeIndex = 12,
						ranges = {
							string.byte("0"),
							string.byte("9"),
							string.byte("0"),
							string.byte("9"),
							string.byte("a"),
							string.byte("z"),
							string.byte("A"),
							string.byte("Z"),
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
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte("A")] = true,
					[string.byte("a")] = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[^^$|.%%()?:>=!<{},+*[%]a%-b]",
		flags = {
			['i'] = true,
		},
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
					[string.byte("{")] = true,
					[string.byte("|")] = true,
					[string.byte("}")] = true,
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
					[string.byte("A")] = true,
					[string.byte("B")] = true,
					[string.byte("[")] = true,
					[string.byte("]")] = true,
					[string.byte("^")] = true,
					[string.byte("a")] = true,
					[string.byte("b")] = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "(abc)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("c"),
						type = "literal",
						upperValue = string.byte("C"),
						value = string.byte("c"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(a)(b)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 2,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 2,
		},
	},
	{
		regex = "(?:abc)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("c"),
						type = "literal",
						upperValue = string.byte("C"),
						value = string.byte("c"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?=abc)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("c"),
						type = "literal",
						upperValue = string.byte("C"),
						value = string.byte("c"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?!abc)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				isNegative = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("c"),
						type = "literal",
						upperValue = string.byte("C"),
						value = string.byte("c"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?<=abc)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				fixedLength = 3,
				hasSpecialBehavior = true,
				isLookbehind = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("c"),
						type = "literal",
						upperValue = string.byte("C"),
						value = string.byte("c"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?<!abc)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				fixedLength = 3,
				hasSpecialBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("b"),
						type = "literal",
						upperValue = string.byte("B"),
						value = string.byte("b"),
					},
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("c"),
						type = "literal",
						upperValue = string.byte("C"),
						value = string.byte("c"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "a|b",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				branches = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("a"),
							type = "literal",
							upperValue = string.byte("A"),
							value = string.byte("a"),
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("b"),
							type = "literal",
							upperValue = string.byte("B"),
							value = string.byte("b"),
						},
						_index = 1,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
	},
	{
		regex = "abc|def",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				branches = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("a"),
							type = "literal",
							upperValue = string.byte("A"),
							value = string.byte("a"),
						},
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("b"),
							type = "literal",
							upperValue = string.byte("B"),
							value = string.byte("b"),
						},
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("c"),
							type = "literal",
							upperValue = string.byte("C"),
							value = string.byte("c"),
						},
						_index = 3,
					},
					{
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("d"),
							type = "literal",
							upperValue = string.byte("D"),
							value = string.byte("d"),
						},
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("e"),
							type = "literal",
							upperValue = string.byte("E"),
							value = string.byte("e"),
						},
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("f"),
							type = "literal",
							upperValue = string.byte("F"),
							value = string.byte("f"),
						},
						_index = 3,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
	},
	{
		regex = "a|[b-c]",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				branches = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = string.byte("a"),
							type = "literal",
							upperValue = string.byte("A"),
							value = string.byte("a"),
						},
						_index = 1,
					},
					{
						{
							classIndex = 0,
							classes = {
							},
							hasToNegateMatch = false,
							rangeIndex = 4,
							ranges = {
								string.byte("b"),
								string.byte("c"),
								string.byte("B"),
								string.byte("C"),
							},
							type = "set",
							values = {
							},
						},
						_index = 1,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
	},
	{
		regex = ".",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				type = "any",
			},
			_index = 1,
		},
	},
	{
		regex = "([a-z]+)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
					{
						classIndex = 0,
						classes = {
						},
						hasToNegateMatch = false,
						quantifier = {
							max = 0,
							min = 1,
							type = "quantifier",
						},
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
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "([^abc])",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
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
							[string.byte("A")] = true,
							[string.byte("B")] = true,
							[string.byte("C")] = true,
							[string.byte("a")] = true,
							[string.byte("b")] = true,
							[string.byte("c")] = true,
						},
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?:[A-Z][a-z]+)",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
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
						hasToNegateMatch = false,
						quantifier = {
							max = 0,
							min = 1,
							type = "quantifier",
						},
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
					_index = 2,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?=a)[b-c]+",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = string.byte("a"),
						type = "literal",
						upperValue = string.byte("A"),
						value = string.byte("a"),
					},
					_index = 1,
				},
				type = "group",
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				rangeIndex = 4,
				ranges = {
					string.byte("b"),
					string.byte("c"),
					string.byte("B"),
					string.byte("C"),
				},
				type = "set",
				values = {
				},
			},
			_index = 2,
		},
	},
	{
		regex = "(a|[b-z]){2,5}",
		flags = {
			['i'] = true,
		},
		parsed = {
			{
				index = 1,
				quantifier = {
					max = 5,
					min = 2,
					type = "quantifier",
				},
				tree = {
					{
						branches = {
							{
								{
									isCaseInsensitive = true,
									lowerValue = string.byte("a"),
									type = "literal",
									upperValue = string.byte("A"),
									value = string.byte("a"),
								},
								_index = 1,
							},
							{
								{
									classIndex = 0,
									classes = {
									},
									hasToNegateMatch = false,
									rangeIndex = 4,
									ranges = {
										string.byte("b"),
										string.byte("z"),
										string.byte("B"),
										string.byte("Z"),
									},
									type = "set",
									values = {
									},
								},
								_index = 1,
							},
							_index = 2,
						},
						type = "alternate",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?i)a",
		flags = {},
		parsed = {
			{
				type = "literal",
				value = string.byte("a"),
				lowerValue = string.byte("a"),
				upperValue = string.byte("A"),
				isCaseInsensitive = true,
			},
			_index = 1,
		},
	},
	{
		regex = "(?i:a)",
		flags = {},
		parsed = {
			{
				type = "group",
				hasSpecialBehavior = true,
				isNonCapturing = true,
				scopedFlags = {
					enable = { i = true },
					disable = {}
				},
				tree = {
					{
						type = "literal",
						value = string.byte("a"),
						lowerValue = string.byte("a"),
						upperValue = string.byte("A"),
						isCaseInsensitive = true,
					},
					_index = 1,
				},
			},
			_index = 1,
		},
	},
}
