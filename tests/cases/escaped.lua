return {
	{
		regex = "%^%$%|%.%%%(%)%?%:%>%=%!%<%{%}%,%+%*%[%]%-",
		parsed = {
			_index = 21,
			{
				type = "literal",
				value = '^'
			},
			{
				type = "literal",
				value = '$'
			},
			{
				type = "literal",
				value = '|'
			},
			{
				type = "literal",
				value = '.'
			},
			{
				type = "literal",
				value = '%'
			},
			{
				type = "literal",
				value = '('
			},
			{
				type = "literal",
				value = ')'
			},
			{
				type = "literal",
				value = '?'
			},
			{
				type = "literal",
				value = ':'
			},
			{
				type = "literal",
				value = '>'
			},
			{
				type = "literal",
				value = '='
			},
			{
				type = "literal",
				value = '!'
			},
			{
				type = "literal",
				value = '<'
			},
			{
				type = "literal",
				value = '{'
			},
			{
				type = "literal",
				value = '}'
			},
			{
				type = "literal",
				value = ','
			},
			{
				type = "literal",
				value = '+'
			},
			{
				type = "literal",
				value = '*'
			},
			{
				type = "literal",
				value = '['
			},
			{
				type = "literal",
				value = ']'
			},
			{
				type = "literal",
				value = '-'
			}
		},
	},
	{
		regex = "%a%b%c%!%@%#%$%%",
		errorMessage = "Invalid regular expression: Invalid escape \"%@\"",
	},
	{
		regex = "%.%",
		errorMessage = "Invalid regular expression: Attempt to escape null"
	},
}