return {
	{
		regex = '',
		parsed = {
			_index = 0
		}
	},
	{
		regex = 'a',
		parsed = {
			_index = 1,
			{
				type = "literal",
				value = 'a'
			}
		}
	},
	{
		regex = "aBcD_!@#&}{~>:",
		parsed = {
			_index = 14,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'B'
			},
			{
				type = "literal",
				value = 'c'
			},
			{
				type = "literal",
				value = 'D'
			},
			{
				type = "literal",
				value = '_'
			},
			{
				type = "literal",
				value = '!'
			},
			{
				type = "literal",
				value = '@'
			},
			{
				type = "literal",
				value = '#'
			},
			{
				type = "literal",
				value = '&'
			},
			{
				type = "literal",
				value = '}'
			},
			{
				type = "literal",
				value = '{'
			},
			{
				type = "literal",
				value = '~'
			},
			{
				type = "literal",
				value = '>'
			},
			{
				type = "literal",
				value = ':'
			}
		}
	},
}