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
		regex = "[]a]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				[']'] = true,
				['a'] = true
			}
		}
	},
	{
		regex = "[]]a]",
		parsed = {
			_index = 3,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				[']'] = true
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = ']'
			}
		}
	},
	{
		regex = "[^]a]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				[']'] = true,
				['a'] = true
			}
		}
	},
	{
		regex = "[^]]a]",
		parsed = {
			_index = 3,
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				[']'] = true
			},
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = ']'
			}
		}
	},
	{
		regex = "[^a]]",
		parsed = {
			_index = 2,
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				['a'] = true
			},
			{
				type = "literal",
				value = ']'
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
	{
		regex = "[%w.%a^%U]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = { },
				classIndex = 3,
				classes = {
					{
						type = "set",

						hasToNegateMatch = false,

						rangeIndex = 6,
						ranges = {
							'0',
							'9',

							'a',
							'z',

							'A',
							'Z'
						},

						classIndex = 0,
						classes = { },

						['_'] = true
					},
					{
						type = "set",

						hasToNegateMatch = false,

						rangeIndex = 4,
						ranges = {
							'a',
							'z',

							'A',
							'Z'
						},

						classIndex = 0,
						classes = { }
					},
					{
						type = "set",

						hasToNegateMatch = true,

						rangeIndex = 2,
						ranges = {
							'A',
							'Z'
						},

						classIndex = 0,
						classes = { }
					}
				},
				['.'] = true,
				['^'] = true
			}
		}
	},
	{
		regex = "[%w.-~%aa^%U]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					'.', '~'
				},
				classIndex = 3,
				classes = {
					{
						type = "set",

						hasToNegateMatch = false,

						rangeIndex = 6,
						ranges = {
							'0',
							'9',

							'a',
							'z',

							'A',
							'Z'
						},

						classIndex = 0,
						classes = { },

						['_'] = true
					},
					{
						type = "set",

						hasToNegateMatch = false,

						rangeIndex = 4,
						ranges = {
							'a',
							'z',

							'A',
							'Z'
						},

						classIndex = 0,
						classes = { }
					},
					{
						type = "set",

						hasToNegateMatch = true,

						rangeIndex = 2,
						ranges = {
							'A',
							'Z'
						},

						classIndex = 0,
						classes = { }
					}
				},
				['^'] = true,
				['a'] = true
			}
		}
	},
	{
		regex = "[^%UU-ZZ-]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 2,
				ranges = {
					'U', 'Z'
				},
				classIndex = 1,
				classes = {
					{
						type = "set",

						hasToNegateMatch = true,

						rangeIndex = 2,
						ranges = {
							'A',
							'Z'
						},

						classIndex = 0,
						classes = { }
					}
				},
				['Z'] = true,
				['-'] = true
			}
		}
	},
	{
		regex = "[^^$|.%%()?:>=!<{},+*[%]a%-b]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = true,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				['^'] = true,
				['$'] = true,
				['|'] = true,
				['.'] = true,
				['%'] = true,
				['('] = true,
				[')'] = true,
				['?'] = true,
				[':'] = true,
				['>'] = true,
				['='] = true,
				['!'] = true,
				['<'] = true,
				['{'] = true,
				['}'] = true,
				[','] = true,
				['+'] = true,
				['*'] = true,
				['['] = true,
				[']'] = true,
				['a'] = true,
				['-'] = true,
				['b'] = true
			}
		}
	},
	{
		regex = "[%^^$|.%%()?:>=!<{},+*[%]a%-b]",
		parsed = {
			_index = 1,
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = { },
				classIndex = 0,
				classes = { },
				['^'] = true,
				['$'] = true,
				['|'] = true,
				['.'] = true,
				['%'] = true,
				['('] = true,
				[')'] = true,
				['?'] = true,
				[':'] = true,
				['>'] = true,
				['='] = true,
				['!'] = true,
				['<'] = true,
				['{'] = true,
				['}'] = true,
				[','] = true,
				['+'] = true,
				['*'] = true,
				['['] = true,
				[']'] = true,
				['a'] = true,
				['-'] = true,
				['b'] = true
			}
		}
	},
	{
		regex = "%c %[[%^%%w[-%]]%]",
		parsed = {
			_index = 4,
			{
				type = "literal",
				value = '`'
			},
			{
				type = "literal",
				value = '['
			},
			{
				type = "set",
				hasToNegateMatch = false,
				rangeIndex = 2,
				ranges = {
					'[', ']'
				},
				classIndex = 0,
				classes = { },
				['^'] = true,
				['%'] = true,
				['w'] = true
			},
			{
				type = "literal",
				value = ']'
			}
		}
	},
	{
		regex = "[",
		errorMessage = "Invalid regular expression: Missing ']' to close set"
	},
	{
		regex = "[^",
		errorMessage = "Invalid regular expression: Missing ']' to close set"
	},
	{
		regex = "[]",
		errorMessage = "Invalid regular expression: Missing ']' to close set"
	},
	{
		regex = "[^]",
		errorMessage = "Invalid regular expression: Missing ']' to close set"
	},
	{
		regex = "[%]",
		errorMessage = "Invalid regular expression: Missing ']' to close set"
	},
	{
		regex = "[b-a]",
		errorMessage = "Invalid regular expression: Range out of order in set"
	},
}