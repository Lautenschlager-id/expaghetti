return {
	{
		parsed = {
			{
				upperOpen = string.byte("("),
				lowerOpen = string.byte("("),
				upperClose = string.byte(")"),
				lowerClose = string.byte(")"),
				type = "balanced"
			},
			_index = 1
		},
		regex = "%b()"
	},
	{
		parsed = {
			{
				tree = {
					{
						isCaseInsensitive = false,
						value = string.byte("a"),
						type = "literal"
					},
					{
						upperOpen = string.byte("("),
						lowerOpen = string.byte("("),
						upperClose = string.byte(")"),
						lowerClose = string.byte(")"),
						type = "balanced"
					},
					{
						isCaseInsensitive = false,
						value = string.byte("b"),
						type = "literal"
					},
					_index = 3
				},
				index = 1,
				type = "group"
			},
			_index = 1
		},
		regex = "(a%b()b)"
	},
	{
		parsed = {
			{
				upperOpen = string.byte("<"),
				lowerOpen = string.byte("<"),
				upperClose = string.byte(">"),
				lowerClose = string.byte(">"),
				type = "balanced"
			},
			{
				upperOpen = string.byte("\""),
				lowerOpen = string.byte("\""),
				upperClose = string.byte("\""),
				lowerClose = string.byte("\""),
				type = "balanced"
			},
			_index = 2
		},
		regex = "%b<>%b\"\""
	},
	{
		parsed = {
			{
				upperOpen = string.byte("%"),
				lowerOpen = string.byte("%"),
				upperClose = string.byte("a"),
				lowerClose = string.byte("a"),
				type = "balanced"
			},
			_index = 1
		},
		regex = "%b%a"
	},
	{
		regex = "%b",
		errorMessage = "Invalid regular expression: Balanced pattern requires two delimiters",
	},
	{
		regex = "%b(",
		errorMessage = "Invalid regular expression: Balanced pattern requires two delimiters",
	},
	{
		flags = {
			i = true
		},
		regex = "%bab",
		parsed = {
			{
				upperOpen = string.byte("A"),
				lowerClose = string.byte("b"),
				lowerOpen = string.byte("a"),
				upperClose = string.byte("B"),
				type = "balanced"
			},
			_index = 1
		}
	},
	{
		flags = {
			u = true
		},
		regex = "%bab",
		parsed = {
			{
				upperOpen = "a",
				lowerClose = "b",
				lowerOpen = "a",
				upperClose = "b",
				type = "balanced"
			},
			_index = 1
		}
	},
	{
		flags = {
			u = true,
			i = true
		},
		regex = "%bab",
		parsed = {
			{
				upperOpen = "A",
				lowerClose = "b",
				lowerOpen = "a",
				upperClose = "B",
				type = "balanced"
			},
			_index = 1
		}
	}
}
