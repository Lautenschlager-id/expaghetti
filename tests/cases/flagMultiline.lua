return {
	{
		parsed = {
			{
				isStart = true,
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
				isStart = false,
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
				isStart = true,
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
				isStart = false,
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
						isStart = true,
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
						isStart = false,
						isMultiline = true,
						type = "anchor"
					},
					_index = 5
				},
				type = "group",
				isNonCapturing = true,
				hasSpecialBehavior = true,
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
				isStart = true,
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
				isStart = false,
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
						isStart = true,
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
						isStart = false,
						type = "anchor"
					},
					_index = 5
				},
				type = "group",
				isNonCapturing = true,
				hasSpecialBehavior = true,
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
				isStart = true,
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
				isStart = false,
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
				isStart = true,
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
				isStart = false,
				type = "anchor"
			},
			_index = 5
		},
		regex = "(?m)^abc(?-m)$",
		flags = {}
	}
}
