return {
	{
		regex = "%a",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 4,
				ranges = {
					'a',
					'z',

					'A',
					'Z'
				}
			}
		}
	},
	{
		regex = "%d",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 2,
				ranges = {
					'0',
					'9'
				}
			}
		}
	},
	{
		regex = "%h%x",
		parsed = {
			_index = 2,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 6,
				ranges = {
					'0',
					'9',

					'a',
					'f',

					'A',
					'F'
				}
			},
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 6,
				ranges = {
					'0',
					'9',

					'a',
					'f',

					'A',
					'F'
				}
			}
		}
	},
	{
		regex = "%l",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 2,
				ranges = {
					'a',
					'z'
				}
			}
		}
	},
	{
		regex = "%p",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 8,
				ranges = {
					'!',
					'/',

					':',
					'@',

					'[',
					'`',

					'{',
					'~'
				}
			}
		}
	},
	{
		regex = "%s",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 0,
				ranges = { },

				['\f'] = true,
				['\n'] = true,
				['\r'] = true,
				['\t'] = true,
				[' '] = true
			}
		}
	},
	{
		regex = "%u",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = false,

				rangeIndex = 2,
				ranges = {
					'A',
					'Z'
				}
			}
		}
	},
	{
		regex = "%w",
		parsed = {
			_index = 1,
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

				['_'] = true
			}
		}
	},
	{
		regex = "%A",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 4,
				ranges = {
					'a',
					'z',

					'A',
					'Z'
				}
			}
		}
	},
	{
		regex = "%D",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 2,
				ranges = {
					'0',
					'9'
				}
			}
		}
	},
	{
		regex = "%H%X",
		parsed = {
			_index = 2,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 6,
				ranges = {
					'0',
					'9',

					'a',
					'f',

					'A',
					'F'
				}
			},
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 6,
				ranges = {
					'0',
					'9',

					'a',
					'f',

					'A',
					'F'
				}
			}
		}
	},
	{
		regex = "%L",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 2,
				ranges = {
					'a',
					'z'
				}
			}
		}
	},
	{
		regex = "%P",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 8,
				ranges = {
					'!',
					'/',

					':',
					'@',

					'[',
					'`',

					'{',
					'~'
				}
			}
		}
	},
	{
		regex = "%S",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 0,
				ranges = { },

				['\f'] = true,
				['\n'] = true,
				['\r'] = true,
				['\t'] = true,
				[' '] = true
			}
		}
	},
	{
		regex = "%U",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 2,
				ranges = {
					'A',
					'Z'
				}
			}
		}
	},
	{
		regex = "%W",
		parsed = {
			_index = 1,
			{
				type = "set",

				hasToNegateMatch = true,

				rangeIndex = 6,
				ranges = {
					'0',
					'9',

					'a',
					'z',

					'A',
					'Z'
				},

				['_'] = true
			}
		}
	}
}