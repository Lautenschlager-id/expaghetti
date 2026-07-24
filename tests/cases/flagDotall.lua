return {
	{
		regex = ".",
		parsed = {
			{
				type = "any",
				isDotAll = true
			},
			_index = 1
		},
		flags = {
			["s"] = true
		}
	},
	{
		regex = "(?s).",
		parsed = {
			{
				type = "any",
				isDotAll = true
			},
			_index = 1
		},
		flags = {}
	},
	{
		regex = "(?s:.).",
		parsed = {
			{
				scopedFlags = {
					enable = {
						["s"] = true
					},
					disable = {}
				},
				isNonCapturing = true,
				type = "group",
				tree = {
					{
						type = "any",
						isDotAll = true
					},
					_index = 1
				},
				hasSpecialBehavior = true
			},
			{
				type = "any"
			},
			_index = 2
		},
		flags = {}
	},
	{
		regex = "(?s).*(abc)(?<=.).+(?-s).",
		parsed = {
			{
				quantifier = {
					max = 0,
					type = "quantifier",
					min = 0
				},
				isDotAll = true,
				type = "any"
			},
			{
				index = 1,
				type = "group",
				tree = {
					{
						value = string.byte("a"),
						isCaseInsensitive = false,
						type = "literal"
					},
					{
						value = string.byte("b"),
						isCaseInsensitive = false,
						type = "literal"
					},
					{
						value = string.byte("c"),
						isCaseInsensitive = false,
						type = "literal"
					},
					_index = 3
				}
			},
			{
				isLookbehind = true,
				isNonCapturing = true,
				type = "group",
				tree = {
					{
						type = "any",
						isDotAll = true
					},
					_index = 1
				},
				hasSpecialBehavior = true,
				fixedLength = 1
			},
			{
				quantifier = {
					max = 0,
					type = "quantifier",
					min = 1
				},
				isDotAll = true,
				type = "any"
			},
			{
				type = "any"
			},
			_index = 5
		},
		flags = {}
	}
}
