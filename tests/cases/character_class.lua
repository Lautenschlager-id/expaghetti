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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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

				classIndex = 0,
				classes = { },

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
				},

				classIndex = 0,
				classes = { }
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

				classIndex = 0,
				classes = { },

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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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
				},

				classIndex = 0,
				classes = { }
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

				classIndex = 0,
				classes = { },

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
				},

				classIndex = 0,
				classes = { }
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

				classIndex = 0,
				classes = { },

				['_'] = true
			}
		}
	},
}