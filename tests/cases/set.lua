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
	{
		regex = "[a-b-c-d]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					'a', 'b',
					'c', 'd'
				},
				classIndex = 0,
				classes = { },
				['-'] = true
			}
		}
	},
	{
		regex = "[-a-b-c-d-]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					'a', 'b',
					'c', 'd'
				},
				classIndex = 0,
				classes = { },
				['-'] = true
			}
		}
	},
	{
		regex = "[%cA-%cb]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					'\1', '\2'
				},
				classIndex = 0,
				classes = { }
			}
		}
	},
}