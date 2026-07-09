return {
	{
		regex = "abc",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "a",
				type = "literal",
				upperValue = "A",
				value = "a",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "b",
				type = "literal",
				upperValue = "B",
				value = "b",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "c",
				type = "literal",
				upperValue = "C",
				value = "c",
			},
			_index = 3,
		},
	},
	{
		regex = "ABC",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "a",
				type = "literal",
				upperValue = "A",
				value = "A",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "b",
				type = "literal",
				upperValue = "B",
				value = "B",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "c",
				type = "literal",
				upperValue = "C",
				value = "C",
			},
			_index = 3,
		},
	},
	{
		regex = "%+%*%.",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "+",
				type = "literal",
				upperValue = "+",
				value = "+",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "*",
				type = "literal",
				upperValue = "*",
				value = "*",
			},
			{
				isCaseInsensitive = true,
				lowerValue = ".",
				type = "literal",
				upperValue = ".",
				value = ".",
			},
			_index = 3,
		},
	},
	{
		regex = "%cA%cb",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "\1",
				type = "literal",
				upperValue = "\1",
				value = "\1",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "\2",
				type = "literal",
				upperValue = "\2",
				value = "\2",
			},
			_index = 2,
		},
	},
	{
		regex = "[abc]",
		flags = {
			['i'] = true,
			['u'] = true,
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
					A = true,
					B = true,
					C = true,
					a = true,
					b = true,
					c = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[a-z]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					"a",
					"z",
					"A",
					"Z",
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
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					"a",
					"z",
					"A",
					"Z",
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
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					"a",
					"c",
					"A",
					"C",
				},
				type = "set",
				values = {
					X = true,
					Y = true,
					x = true,
					y = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[^a-cXY]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 4,
				ranges = {
					"a",
					"c",
					"A",
					"C",
				},
				type = "set",
				values = {
					X = true,
					Y = true,
					x = true,
					y = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%a]",
		flags = {
			['i'] = true,
			['u'] = true,
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
							"a",
							"z",
							"A",
							"Z",
							"a",
							"z",
							"A",
							"Z",
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
		regex = "(abc)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?:abc)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				disableCapture = true,
				hasBehavior = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
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
			['u'] = true,
		},
		parsed = {
			{
				disableCapture = true,
				hasBehavior = true,
				isLookahead = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
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
			['u'] = true,
		},
		parsed = {
			{
				disableCapture = true,
				hasBehavior = true,
				isLookahead = true,
				isNegative = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
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
			['u'] = true,
		},
		parsed = {
			{
				trees = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = "a",
							type = "literal",
							upperValue = "A",
							value = "a",
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = true,
							lowerValue = "b",
							type = "literal",
							upperValue = "B",
							value = "b",
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
			['u'] = true,
		},
		parsed = {
			{
				trees = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = "a",
							type = "literal",
							upperValue = "A",
							value = "a",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "b",
							type = "literal",
							upperValue = "B",
							value = "b",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "c",
							type = "literal",
							upperValue = "C",
							value = "c",
						},
						_index = 3,
					},
					{
						{
							isCaseInsensitive = true,
							lowerValue = "d",
							type = "literal",
							upperValue = "D",
							value = "d",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "e",
							type = "literal",
							upperValue = "E",
							value = "e",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "f",
							type = "literal",
							upperValue = "F",
							value = "f",
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
		regex = ".",
		flags = {
			['i'] = true,
			['u'] = true,
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
			['u'] = true,
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
							"a",
							"z",
							"A",
							"Z",
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
		regex = "(?=a)[b-c]+",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				disableCapture = true,
				hasBehavior = true,
				isLookahead = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
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
					"b",
					"c",
					"B",
					"C",
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
			['u'] = true,
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
						trees = {
							{
								{
									isCaseInsensitive = true,
									lowerValue = "a",
									type = "literal",
									upperValue = "A",
									value = "a",
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
										"b",
										"z",
										"B",
										"Z",
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
}
