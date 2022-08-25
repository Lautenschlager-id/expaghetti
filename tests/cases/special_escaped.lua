return {
	{
		regex = "%cA%cb",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = '\1'
			},
			{
				type = "literal",
				value = '\2'
			}
		}
	},
	{
		regex = "%cZ%cz",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = '\26'
			},
			{
				type = "literal",
				value = '\26'
			},
		}
	},
	{
		regex = "%c\x20%c~%c1",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = '`'
			},
			{
				type = "literal",
				value = '>'
			},
			{
				type = "literal",
				value = 'q'
			}
		}
	},
	{
		regex = "%c",
		errorMessage = "Invalid regular expression: Parameter passed to \"%c\" must be valid"
	},
	{
		regex = "%c\xFF",
		errorMessage = "Invalid regular expression: Parameter passed to \"%c\" must be valid"
	},
	{
		regex = "%e00FF",
		parsed = {
			_index = 1,
			{
				type = "literal",
				value = '\255'
			}
		}
	},
	{
		regex = "%eFFF",
		errorMessage = "Invalid regular expression: A valid 4 characters hexadecimal value must be passed to \"%e\""
	},
	{
		regex = "%eFFFF",
		errorMessage = "Invalid regular expression: A valid 4 characters hexadecimal value must be passed to \"%e\""
	},
	{
		regex = "%e",
		errorMessage = "Invalid regular expression: A valid 4 characters hexadecimal value must be passed to \"%e\""
	},
}