return {
	{
		regex = "^ab",
		parsed = {
			_index = 3,
			{
				type = "anchor",
				isBeginning = true,
				quantifier = false
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b'
			}
		}
	},
	{
		regex = "^%^^ab",
		parsed = {
			_index = 5,
			{
				type = "anchor",
				isBeginning = true,
				quantifier = false
			},
			{
				type = "literal",
				value = '^'
			},
			{
				type = "anchor",
				isBeginning = true,
				quantifier = false
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b'
			}
		}
	},
	{
		regex = "ab$",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "anchor",
				isBeginning = false,
				quantifier = false
			}
		}
	},
	{
		regex = "^ab$%$",
		parsed = {
			_index = 5,
			{
				type = "anchor",
				isBeginning = true,
				quantifier = false
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "anchor",
				isBeginning = false,
				quantifier = false
			},
			{
				type = "literal",
				value = '$'
			}
		}
	},
	{
		regex = "$[^$$^]^",
		parsed = {
			_index = 3,
			{
				type = "anchor",
				isBeginning = false,
				quantifier = false
			},
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				['$'] = true,
				['^'] = true
			},
			{
				type = "anchor",
				isBeginning = true,
				quantifier = false
			}
		}
	},
	{
		regex = "a%bbc",
		parsed = {
			_index = 4,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "boundary",
				shouldBeBetweenWord = false,
				quantifier = false
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "literal",
				value = 'c'
			},
		}
	},
	{
		regex = "a%Bbc",
		parsed = {
			_index = 4,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "boundary",
				shouldBeBetweenWord = true,
				quantifier = false
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "literal",
				value = 'c'
			}
		}
	},
	{
		regex = "a%%bb%B%%c",
		parsed = {
			_index = 7,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = '%'
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "boundary",
				shouldBeBetweenWord = true,
				quantifier = false
			},
			{
				type = "literal",
				value = '%'
			},
			{
				type = "literal",
				value = 'c'
			}
		}
	},
	{
		regex = "^+.",
		errorMessage = "Invalid regular expression: Nothing to repeat"
	},
	{
		regex = ".$+",
		errorMessage = "Invalid regular expression: Nothing to repeat"
	},
}