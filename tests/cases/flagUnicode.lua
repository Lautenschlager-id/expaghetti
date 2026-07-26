return {
	{
		regex = "maçã",
		flags = {
			['u'] = true,
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
	},
	{
		regex = "%+%*%.",
		flags = {
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "+",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "*",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = ".",
			},
			_index = 3,
		},
	},
	{
		regex = "\001\002",
		flags = {
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "\1",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = "\2",
			},
			_index = 2,
		},
	},
	{
		regex = "[abc]",
		flags = {
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
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					"a",
					"z",
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[ª-º]",
		flags = {
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					"ª",
					"º",
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[^ª-º]",
		flags = {
			['u'] = true,
		},
		parsed = {
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
			_index = 1,
		},
	},
	{
		regex = "[%a]",
		flags = {
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
						rangeIndex = 2,
						ranges = {
							"0",
							"9",
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
		regex = "(?:abc)",
		flags = {
			['u'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = "a",
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = "b",
					},
					{
						isCaseInsensitive = false,
						type = "literal",
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
			['u'] = true,
		},
		parsed = {
			{
				branches = {
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = "a",
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
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
		regex = ".",
		flags = {
			['u'] = true,
		},
		parsed = {
			{
				type = "any",
			},
			_index = 1,
		},
	},
}
