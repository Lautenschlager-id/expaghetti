return {
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("^"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("$"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("|"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("."),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("%"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("("),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(")"),
			},
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
				value = string.byte(">"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("="),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("!"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("<"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("+"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("*"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("["),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("]"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("-"),
			},
			_index = 21,
		},
		regex = "%^%$%|%.%%%(%)%?%:%>%=%!%<%{%}%,%+%*%[%]%-",
	},
	{
		errorMessage = "Invalid regular expression: Invalid escape \"%@\"",
		regex = "%a%b%c%!%@%#%$%%",
	},
	{
		errorMessage = "Invalid regular expression: Attempt to escape null",
		regex = "%.%",
	},
	{
		errorMessage = "Invalid regular expression: Invalid escape \"%B\"",
		regex = ".%B+",
	},
}
