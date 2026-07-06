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
}