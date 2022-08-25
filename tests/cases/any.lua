return {
	{
		regex = '..',
		parsed = {
			_index = 2,
			{
				type = "any"
			},
			{
				type = "any"
			}
		}
	},
	{
		regex = '.%..%.',
		parsed = {
			_index = 4,
			{
				type = "any"
			},
			{
				type = "literal",
				value = '.'
			},
			{
				type = "any"
			},
			{
				type = "literal",
				value = '.'
			}
		}
	}
}