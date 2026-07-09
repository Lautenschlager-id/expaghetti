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
		errorMessage = "Invalid regular expression: Parameter passed to \"%c\" must be valid",
		regex = "%c",
	},
	{
		errorMessage = "Invalid regular expression: Parameter passed to \"%c\" must be valid",
		regex = "%cÿ",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("ÿ"),
			},
			_index = 1,
		},
		regex = "%e00FF",
	},
	{
		errorMessage = "Invalid regular expression: A valid 4 characters hexadecimal value must be passed to \"%e\"",
		regex = "%eFFF",
	},
	{
		errorMessage = "Invalid regular expression: A valid 4 characters hexadecimal value must be passed to \"%e\"",
		regex = "%eFFFF",
	},
	{
		errorMessage = "Invalid regular expression: A valid 4 characters hexadecimal value must be passed to \"%e\"",
		regex = "%e",
	},
}
