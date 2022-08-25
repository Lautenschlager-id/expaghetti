return {
	{
		regex = "a[aB%cAc[D]b",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				['a'] = true,
				['B'] = true,
				['c'] = true,
				['['] = true,
				['D'] = true,
				['\1'] = true
			},
			{
				type = "literal",
				value = 'b'
			}
		}
	},
}