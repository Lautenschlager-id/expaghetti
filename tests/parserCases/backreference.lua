return {
	{
		parsed = {
			{
				type = "group",
				index = 1,
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					_index = 1
				}
			},
			{
				type = "group",
				index = 2,
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("b")
					},
					_index = 1
				}
			},
			{
				index = 2,
				type = "backreference"
			},
			{
				index = 1,
				type = "backreference"
			},
			_index = 4
		},
		regex = "(a)(b)%2%1"
	},
	{
		parsed = {
			{
				type = "group",
				index = 1,
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					{
						type = "group",
						index = 2,
						tree = {
							{
								quantifier = {
									min = 1,
									type = "quantifier",
									max = 0
								},
								type = "set",
								classIndex = 0,
								rangeIndex = 2,
								hasToNegateMatch = false,
								ranges = {
									string.byte(0),
									string.byte(9)
								},
								classes = {},
								values = {}
							},
							_index = 1
						}
					},
					_index = 2
				}
			},
			{
				index = 1,
				type = "backreference"
			},
			_index = 2
		},
		regex = "(a(%d+))%1"
	},
	{
		parsed = {
			{
				type = "group",
				index = 1,
				tree = {
					{
						type = "group",
						index = 2,
						tree = {
							{
								type = "literal",
								isCaseInsensitive = false,
								value = string.byte("a")
							},
							_index = 1
						}
					},
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("b")
					},
					_index = 2
				}
			},
			{
				index = 2,
				type = "backreference"
			},
			_index = 2
		},
		regex = "((a)b)%2"
	},
	{
		parsed = {
			{
				type = "group",
				hasSpecialBehavior = true,
				index = 1,
				name = "word",
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					_index = 1
				}
			},
			{
				index = 1,
				type = "backreference"
			},
			_index = 2
		},
		regex = "(?<word>a)%k<word>"
	},
	{
		parsed = {
			{
				type = "group",
				hasSpecialBehavior = true,
				index = 1,
				name = "a",
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					_index = 1
				}
			},
			{
				type = "group",
				hasSpecialBehavior = true,
				index = 2,
				name = "b",
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("b")
					},
					_index = 1
				}
			},
			{
				index = 1,
				type = "backreference"
			},
			{
				index = 2,
				type = "backreference"
			},
			_index = 4
		},
		regex = "(?<a>a)(?<b>b)%k<a>%k<b>"
	},
	{
		parsed = {
			{
				type = "group",
				hasSpecialBehavior = true,
				index = 1,
				name = "word",
				tree = {
					{
						type = "group",
						index = 2,
						tree = {
							{
								type = "literal",
								isCaseInsensitive = false,
								value = string.byte("a")
							},
							{
								type = "literal",
								isCaseInsensitive = false,
								value = string.byte("b")
							},
							{
								type = "literal",
								isCaseInsensitive = false,
								value = string.byte("c")
							},
							_index = 3
						}
					},
					_index = 1
				}
			},
			{
				index = 1,
				type = "backreference"
			},
			_index = 2
		},
		regex = "(?<word>(abc))%k<word>"
	},
	{
		regex = "(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)%k<12>",
		parsed = {
			{
				index = 1,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 2,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 3,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 4,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 5,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 6,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 7,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 8,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 9,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 10,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 11,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 12,
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 12,
				type = "backreference",
			},
			_index = 13,
		},
	},
	{
		regex = "(?<abc>(?<def>(?<ghi>%k<abc>)))%k<ghi>%k<def>",
		parsed = {
			{
				hasSpecialBehavior = true,
				index = 1,
				name = "abc",
				tree = {
					{
						hasSpecialBehavior = true,
						index = 2,
						name = "def",
						tree = {
							{
								hasSpecialBehavior = true,
								index = 3,
								name = "ghi",
								tree = {
									{
										index = 1,
										type = "backreference",
									},
									_index = 1,
								},
								type = "group",
							},
							_index = 1,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				index = 3,
				type = "backreference",
			},
			{
				index = 2,
				type = "backreference",
			},
			_index = 3,
		},
	},
}
