return {
	{
		parsed = {
			_index = 0
		},
		regex = "(?#comment)"
	},
	{
		parsed = {
			_index = 0
		},
		regex = "(?#)"
	},
	{
		parsed = {
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
			_index = 2
		},
		regex = "a(?#comment)b"
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
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
					_index = 3
				},
				type = "group"
			},
			_index = 1
		},
		regex = "(?#comment)(abc)"
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
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
					_index = 2
				},
				type = "group"
			},
			_index = 1
		},
		regex = "((?#comment)a(?#comment)b)"
	},
	{
		parsed = {
			{
				trees = {
					{
						{
							type = "literal",
							value = string.byte("a"),
							isCaseInsensitive = false
						},
						_index = 1
					},
					{
						{
							type = "literal",
							value = string.byte("b"),
							isCaseInsensitive = false
						},
						_index = 1
					},
					_index = 2
				},
				type = "alternate"
			},
			_index = 1
		},
		regex = "a|(?#comment)b"
	},
	{
		parsed = {
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
			_index = 2
		},
		regex = "a(?#1)(?#2)(?#3)b"
	},
	{
		regex = "a(b(?#this is a random message that can never affect the pattern))c",
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
	},
	{
	regex = "(?#",
	errorMessage = "Invalid regular expression: Unterminated group",
},
}
