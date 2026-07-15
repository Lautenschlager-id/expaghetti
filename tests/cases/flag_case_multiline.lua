return {
	{
		regex = "^abc$",
		flags = {
			["m"] = true
		},
		parsed = {
			{
				isBeginning = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "literal",
				value = string.byte("a"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("b"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("c"),
				isCaseInsensitive = false
			},
			{
				isBeginning = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 5
		}
	},
	{
		regex = "(?m)^abc$",
		flags = {},
		parsed = {
			{
				isBeginning = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "literal",
				value = string.byte("a"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("b"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("c"),
				isCaseInsensitive = false
			},
			{
				isBeginning = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 5
		}
	},
	{
		regex = "(?m:^abc$)",
		flags = {},
		parsed = {
			{
				type = "group",
				scopedFlags = {
					disable = {},
					enable = {
						["m"] = true
					}
				},
				hasBehavior = true,
				tree = {
					{
						isBeginning = true,
						type = "anchor",
						isMultiline = true
					},
					{
						type = "literal",
						value = string.byte("a"),
						isCaseInsensitive = false
					},
					{
						type = "literal",
						value = string.byte("b"),
						isCaseInsensitive = false
					},
					{
						type = "literal",
						value = string.byte("c"),
						isCaseInsensitive = false
					},
					{
						isBeginning = false,
						type = "anchor",
						isMultiline = true
					},
					_index = 5
				},
				disableCapture = true
			},
			_index = 1
		}
	},
	{
		regex = "(?-m)^abc$",
		flags = {
			["m"] = true
		},
		parsed = {
			{
				isBeginning = true,
				type = "anchor"
			},
			{
				type = "literal",
				value = string.byte("a"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("b"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("c"),
				isCaseInsensitive = false
			},
			{
				isBeginning = false,
				type = "anchor"
			},
			_index = 5
		}
	},
	{
		regex = "(?-m:^abc$)",
		flags = {
			["m"] = true
		},
		parsed = {
			{
				type = "group",
				scopedFlags = {
					disable = {
						["m"] = true
					},
					enable = {}
				},
				hasBehavior = true,
				tree = {
					{
						isBeginning = true,
						type = "anchor"
					},
					{
						type = "literal",
						value = string.byte("a"),
						isCaseInsensitive = false
					},
					{
						type = "literal",
						value = string.byte("b"),
						isCaseInsensitive = false
					},
					{
						type = "literal",
						value = string.byte("c"),
						isCaseInsensitive = false
					},
					{
						isBeginning = false,
						type = "anchor"
					},
					_index = 5
				},
				disableCapture = true
			},
			_index = 1
		}
	},
	{
		regex = "(?m)(?-m)^abc$",
		flags = {},
		parsed = {
			{
				isBeginning = true,
				type = "anchor"
			},
			{
				type = "literal",
				value = string.byte("a"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("b"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("c"),
				isCaseInsensitive = false
			},
			{
				isBeginning = false,
				type = "anchor"
			},
			_index = 5
		}
	},
	{
		regex = "(?m)^abc(?-m)$",
		flags = {},
		parsed = {
			{
				isBeginning = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "literal",
				value = string.byte("a"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("b"),
				isCaseInsensitive = false
			},
			{
				type = "literal",
				value = string.byte("c"),
				isCaseInsensitive = false
			},
			{
				isBeginning = false,
				type = "anchor"
			},
			_index = 5
		}
	}
}
