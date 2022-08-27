return {
	{
		regex = "maçã",
		flags = {
			['u'] = false
		},
		parsed = {
			_index = 6,
			{
				type = "literal",
				value = 'm'
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = ('ç'):sub(1, 1)
			},
			{
				type = "literal",
				value = ('ç'):sub(2, 2)
			},
			{
				type = "literal",
				value = ('ã'):sub(1, 1)
			},
			{
				type = "literal",
				value = ('ã'):sub(2, 2)
			}
		}
	},
	{
		regex = "maçã",
		flags = {
			['u'] = true
		},
		parsed = {
			_index = 4,
			{
				type = "literal",
				value = 'm'
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'ç'
			},
			{
				type = "literal",
				value = 'ã'
			}
		}
	},
	{
		regex = "\xC2\xA0[^ª-º]↓",
		flags = {
			['u'] = true
		},
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = "\xC2\xA0"
			},
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					'ª', 'º'
				},
				classIndex = 0,
				classes = { }
			},
			{
				type = "literal",
				value = '↓'
			}
		}
	},
}