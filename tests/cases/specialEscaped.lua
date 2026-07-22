return {
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("\1"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("\2"),
			},
			_index = 2,
		},
		regex = "%cA%cb",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("\26"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("\26"),
			},
			_index = 2,
		},
		regex = "%cZ%cz",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("`"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(">"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("q"),
			},
			_index = 3,
		},
		regex = "%c %c~%c1",
	},
	{
		errorMessage = "Invalid regular expression: Expected a valid control character after '%c'",
		regex = "%c",
	},
	{
		errorMessage = "Invalid regular expression: Expected a valid control character after '%c'",
		regex = "%c\xFF",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("\xFF"),
			},
			_index = 1,
		},
		regex = "%e00FF",
	},
	{
		errorMessage = "Invalid regular expression: Expected a 4-digit hexadecimal value after '%e'",
		regex = "%eFFF",
	},
	{
		errorMessage = "Invalid regular expression: Expected a 4-digit hexadecimal value after '%e'",
		regex = "%eFFFF",
	},
	{
		errorMessage = "Invalid regular expression: Expected a 4-digit hexadecimal value after '%e'",
		regex = "%e",
	},
}
