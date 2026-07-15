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
				disableCapture = true,
				hasBehavior = true,
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
				disableCapture = true,
				hasBehavior = true,
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
				disableCapture = true,
				hasBehavior = true,
				isLookahead = true,
				isNegative = true,
				tree = {
					{
						disableCapture = true,
						hasBehavior = true,
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
				disableCapture = true,
				fixedLength = 0,
				hasBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					{
						disableCapture = true,
						hasBehavior = true,
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
				disableCapture = true,
				fixedLength = 0,
				hasBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					{
						disableCapture = true,
						fixedLength = 1,
						hasBehavior = true,
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
				disableCapture = true,
				hasBehavior = true,
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
				disableCapture = true,
				hasBehavior = true,
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
				disableCapture = true,
				hasBehavior = true,
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
						hasBehavior = true,
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
						hasBehavior = true,
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
				hasBehavior = true,
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
				type = "capture_reference",
			},
			{
				index = 2,
				type = "capture_reference",
			},
			{
				index = 3,
				type = "capture_reference",
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
				type = "capture_reference",
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
		errorMessage = "Invalid regular expression: There is no group to close",
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
		errorMessage = "Invalid regular expression: Duplicated group name <abc>",
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
		errorMessage = "Invalid regular expression: Invalid backreference call: Missing '<'",
		regex = "%k",
	},
	{
		errorMessage = "Invalid regular expression: Unterminated backreference: Missing '>'",
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
