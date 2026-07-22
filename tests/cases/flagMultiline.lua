return {
	{
		parsed = {
			{
				isBeginning = true,
				isMultiline = true,
				type = "anchor"
			},
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
			{
				isBeginning = false,
				isMultiline = true,
				type = "anchor"
			},
			_index = 5
		},
		regex = "^abc$",
		flags = {
			["m"] = true
		}
	},
	{
		parsed = {
			{
				isBeginning = true,
				isMultiline = true,
				type = "anchor"
			},
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
			{
				isBeginning = false,
				isMultiline = true,
				type = "anchor"
			},
			_index = 5
		},
		regex = "(?m)^abc$",
		flags = {}
	},
	{
		parsed = {
			{
				tree = {
					{
						isBeginning = true,
						isMultiline = true,
						type = "anchor"
					},
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
					{
						isBeginning = false,
						isMultiline = true,
						type = "anchor"
					},
					_index = 5
				},
				type = "group",
				disableCapture = true,
				hasBehavior = true,
				scopedFlags = {
					enable = {
						["m"] = true
					},
					disable = {}
				}
			},
			_index = 1
		},
		regex = "(?m:^abc$)",
		flags = {}
	},
	{
		parsed = {
			{
				isBeginning = true,
				type = "anchor"
			},
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
			{
				isBeginning = false,
				type = "anchor"
			},
			_index = 5
		},
		regex = "(?-m)^abc$",
		flags = {
			["m"] = true
		}
	},
	{
		parsed = {
			{
				tree = {
					{
						isBeginning = true,
						type = "anchor"
					},
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
					{
						isBeginning = false,
						type = "anchor"
					},
					_index = 5
				},
				type = "group",
				disableCapture = true,
				hasBehavior = true,
				scopedFlags = {
					enable = {},
					disable = {
						["m"] = true
					}
				}
			},
			_index = 1
		},
		regex = "(?-m:^abc$)",
		flags = {
			["m"] = true
		}
	},
	{
		parsed = {
			{
				isBeginning = true,
				type = "anchor"
			},
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
			{
				isBeginning = false,
				type = "anchor"
			},
			_index = 5
		},
		regex = "(?m)(?-m)^abc$",
		flags = {}
	},
	{
		parsed = {
			{
				isBeginning = true,
				isMultiline = true,
				type = "anchor"
			},
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
			{
				isBeginning = false,
				type = "anchor"
			},
			_index = 5
		},
		regex = "(?m)^abc(?-m)$",
		flags = {}
	}
}
