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
				type = "capture_reference"
			},
			{
				index = 1,
				type = "capture_reference"
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
				type = "capture_reference"
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
				type = "capture_reference"
			},
			_index = 2
		},
		regex = "((a)b)%2"
	},
	{
		parsed = {
			{
				type = "group",
				hasBehavior = true,
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
				index = "word",
				type = "capture_reference"
			},
			_index = 2
		},
		regex = "(?<word>a)%k<word>"
	},
	{
		parsed = {
			{
				type = "group",
				hasBehavior = true,
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
				hasBehavior = true,
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
				index = "a",
				type = "capture_reference"
			},
			{
				index = "b",
				type = "capture_reference"
			},
			_index = 4
		},
		regex = "(?<a>a)(?<b>b)%k<a>%k<b>"
	},
	{
		parsed = {
			{
				type = "group",
				hasBehavior = true,
				name = "word",
				tree = {
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
				index = "word",
				type = "capture_reference"
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
				type = "capture_reference",
			},
			_index = 13,
		},
	},
	{
		regex = "(?<abc>(?<def>(?<ghi>%k<abc>)))%k<ghi>%k<def>",
		parsed = {
			{
				hasBehavior = true,
				name = "abc",
				tree = {
					{
						hasBehavior = true,
						name = "def",
						tree = {
							{
								hasBehavior = true,
								name = "ghi",
								tree = {
									{
										index = "abc",
										type = "capture_reference",
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
				index = "ghi",
				type = "capture_reference",
			},
			{
				index = "def",
				type = "capture_reference",
			},
			_index = 3,
		},
	},
}
