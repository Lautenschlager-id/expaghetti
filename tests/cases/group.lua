return {
	{
		parsed = {
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a"),
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 1,
		},
		regex = "(a)",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b"),
					},
					_index = 1,
				},
				type = "group",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("c"),
			},
			_index = 3,
		},
		regex = "a(b)c",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b"),
					},
					{
						index = 2,
						tree = {
							{
								index = 3,
								tree = {
									{
										isCaseInsensitive = false,
										type = "literal",
										value = string.byte("("),
									},
									{
										index = 4,
										tree = {
											{
												isCaseInsensitive = false,
												type = "literal",
												value = string.byte("."),
											},
											_index = 1,
										},
										type = "group",
									},
									_index = 2,
								},
								type = "group",
							},
							{
								isCaseInsensitive = false,
								type = "literal",
								value = string.byte(")"),
							},
							_index = 2,
						},
						type = "group",
					},
					_index = 2,
				},
				type = "group",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("c"),
			},
			_index = 3,
		},
		regex = "a(b((%((%.))%)))c",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("?"),
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte(":"),
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b"),
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 2,
		},
		regex = "a(%?:b)",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					{
						index = 1,
						tree = {
							{
								isCaseInsensitive = false,
								type = "literal",
								value = string.byte("~"),
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			_index = 3,
		},
		regex = "a(?:(~))b",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isAtomic = true,
				tree = {
					{
						type = "any",
					},
					{
						type = "any",
					},
					{
						index = 1,
						tree = {
							{
								type = "any",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 3,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(?>..(.)).",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				isNegative = true,
				tree = {
					{
						isNonCapturing = true,
						hasSpecialBehavior = true,
						isLookahead = true,
						tree = {
							{
								type = "any",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(?!(?=.)).",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				isNonCapturing = true,
				fixedLength = 0,
				hasSpecialBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					{
						isNonCapturing = true,
						hasSpecialBehavior = true,
						isLookahead = true,
						tree = {
							{
								type = "any",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(?<!(?=.)).",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				isNonCapturing = true,
				fixedLength = 0,
				hasSpecialBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					{
						isNonCapturing = true,
						fixedLength = 1,
						hasSpecialBehavior = true,
						isLookbehind = true,
						tree = {
							{
								type = "any",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(?<!(?<=.)).",
	},
	{
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					_index = 0,
				},
				type = "group",
			},
			_index = 1,
		},
		regex = "(?:)",
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 2,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 3,
		},
		regex = "(.)(?:.)(.)",
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					{
						type = "any",
					},
					{
						index = 2,
						tree = {
							{
								type = "any",
							},
							{
								index = 3,
								tree = {
									{
										type = "any",
									},
									_index = 1,
								},
								type = "group",
							},
							_index = 2,
						},
						type = "group",
					},
					_index = 2,
				},
				type = "group",
			},
			{
				index = 4,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 3,
		},
		regex = "(.)(?:.(.(.)))(.)",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				index = 1,
				tree = {
					{
						hasSpecialBehavior = true,
						index = 2,
						name = "named",
						tree = {
							{
								type = "any",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 2,
		},
		regex = ".((?<named>.))",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				index = 1,
				tree = {
					{
						hasSpecialBehavior = true,
						index = 2,
						name = "n4m3d_",
						tree = {
							{
								type = "any",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 2,
		},
		regex = ".((?<n4m3d_>.))",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				hasSpecialBehavior = true,
				index = 1,
				name = "_007",
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 2,
		},
		regex = ".(?<_007>.)",
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 2,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 1,
				type = "backreference",
			},
			{
				index = 2,
				type = "backreference",
			},
			{
				index = 3,
				type = "backreference",
			},
			_index = 5,
		},
		regex = "(.)(.)%1%2%3",
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("%"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("1"),
			},
			{
				index = 3,
				type = "backreference",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("0"),
			},
			_index = 5,
		},
		regex = "(.)%%1%30",
	},
	{
		errorMessage = "Invalid regular expression: Unterminated group",
		regex = "a(",
	},
	{
		errorMessage = "Invalid regular expression: Unexpected group close",
		regex = "a)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group behavior",
		regex = "(??)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group name",
		regex = "(?<b)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group name",
		regex = "(?<>)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group name",
		regex = "(?<007>)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group name",
		regex = "(?<_ 007>)",
	},
	{
		errorMessage = "Invalid regular expression: Duplicate group name 'abc'",
		regex = "(?<abc>)(?<abc>)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group name",
		regex = "(?<o%w>)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group behavior",
		regex = "(?%w)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid group name",
		regex = "(?<%>>)",
	},
	{
		errorMessage = "Invalid regular expression: Invalid backreference: expected '<'",
		regex = "%k",
	},
	{
		errorMessage = "Invalid regular expression: Invalid backreference name",
		regex = "%k<",
	},
	{
		errorMessage = "Invalid regular expression: Invalid backreference name",
		regex = "%k<>",
	},
	{
		errorMessage = "Invalid regular expression: Invalid backreference name",
		regex = "%k<$.>",
	},
	{
		errorMessage = "Invalid regular expression: Invalid backreference name",
		regex = "%k<oi%>",
	},
}
