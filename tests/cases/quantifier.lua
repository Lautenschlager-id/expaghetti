return {
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab*",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 1,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 1,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("c"),
			},
			_index = 3,
		},
		regex = "a+b*c?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab+?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab*?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 1,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab??",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 1,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("c"),
			},
			_index = 3,
		},
		regex = "a+?b*?c??",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab++",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab*+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 1,
					min = 0,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab?+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 1,
					min = 0,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("c"),
			},
			_index = 3,
		},
		regex = "a++b*+c?+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 12,
					min = 3,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{3,12}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 15,
					min = 12,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{12,15}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 5,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{5,}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 404,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{404,}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 4,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{,4}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 404,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{,404}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 5,
					min = 5,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{5}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 50,
					min = 50,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{50}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 12,
					min = 3,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{3,12}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 15,
					min = 12,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{12,15}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 5,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{5,}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 404,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{404,}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 4,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{,4}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 404,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{,404}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 5,
					min = 5,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{5}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 50,
					min = 50,
					mode = "lazy",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{50}?",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 12,
					min = 3,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{3,12}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 15,
					min = 12,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{12,15}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 5,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{5,}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 404,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{404,}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 4,
					min = 0,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{,4}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 404,
					min = 0,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{,404}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 5,
					min = 5,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{5}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 50,
					min = 50,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("b"),
			},
			_index = 2,
		},
		regex = "ab{50}+",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("+"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			_index = 3,
		},
		regex = "a%+++b",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 0,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("*"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("*"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			_index = 4,
		},
		regex = "a%**%*b",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 4,
					mode = "possessive",
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("\3"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("\3"),
			},
			_index = 2,
		},
		regex = "%cC{4,}+%cC",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				quantifier = {
					max = 0,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "any",
			},
			{
				quantifier = {
					max = 1,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				type = "any",
			},
			{
				quantifier = {
					max = 4,
					min = 4,
					type = "quantifier",
				},
				type = "any",
			},
			{
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				type = "any",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("+"),
			},
			{
				quantifier = {
					max = 0,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				type = "any",
			},
			_index = 7,
		},
		regex = "..*?.??.{4}.+%+.++",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("4"),
			},
			{
				type = "any",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("0"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 7,
		},
		regex = "ab{4.0}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("0"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 6,
		},
		regex = "ab{,0}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("2"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 7,
		},
		regex = "ab{2,b}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("2"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 6,
		},
		regex = "ab{2b}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("4"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("0"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 7,
		},
		regex = "ab{4%,0}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("b"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("0"),
			},
			{
				isCaseInsensitive = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				type = "literal",
				value = string.byte("}"),
			},
			_index = 6,
		},
		regex = "ab{,0}+",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".[.]+.",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 0,
					min = 0,
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".[.]*.",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 1,
					min = 0,
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".[.]?.",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 1,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			_index = 3,
		},
		regex = "[.]??[.]+[.]",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 5,
					min = 3,
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 1,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
					[string.byte(".")] = true,
				},
			},
			_index = 3,
		},
		regex = "[.]{3,5}[.]{1}+[.]",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				index = 1,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(.)+.",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				index = 1,
				quantifier = {
					max = 0,
					min = 0,
					type = "quantifier",
				},
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(.)*.",
	},
	{
		parsed = {
			{
				type = "any",
			},
			{
				index = 1,
				quantifier = {
					max = 1,
					min = 0,
					type = "quantifier",
				},
				tree = {
					{
						type = "any",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				type = "any",
			},
			_index = 3,
		},
		regex = ".(.)?.",
	},
	{
		parsed = {
			{
				index = 1,
				quantifier = {
					max = 1,
					min = 0,
					mode = "lazy",
					type = "quantifier",
				},
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
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
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
			_index = 3,
		},
		regex = "(.)??(.)+(.)",
	},
	{
		parsed = {
			{
				index = 1,
				quantifier = {
					max = 5,
					min = 3,
					type = "quantifier",
				},
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
				quantifier = {
					max = 1,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
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
			_index = 3,
		},
		regex = "(.){3,5}(.){1}+(.)",
	},
	{
		parsed = {
			{
				disableCapture = true,
				hasBehavior = true,
				tree = {
					{
						index = 1,
						tree = {
							{
								quantifier = {
									max = 0,
									min = 1,
									type = "quantifier",
								},
								type = "any",
							},
							{
								index = 2,
								quantifier = {
									max = 5,
									min = 1,
									type = "quantifier",
								},
								tree = {
									{
										isCaseInsensitive = false,
										type = "literal",
										value = string.byte("{"),
									},
									{
										isCaseInsensitive = false,
										type = "literal",
										value = string.byte("0"),
									},
									{
										isCaseInsensitive = false,
										type = "literal",
										value = string.byte(","),
									},
									{
										isCaseInsensitive = false,
										type = "literal",
										value = string.byte("0"),
									},
									{
										isCaseInsensitive = false,
										quantifier = {
											max = 0,
											min = 1,
											mode = "lazy",
											type = "quantifier",
										},
										type = "literal",
										value = string.byte("}"),
									},
									{
										index = 3,
										quantifier = {
											max = 0,
											min = 1,
											type = "quantifier",
										},
										tree = {
											{
												type = "any",
											},
											_index = 1,
										},
										type = "group",
									},
									_index = 6,
								},
								type = "group",
							},
							_index = 2,
						},
						type = "group",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 1,
		},
		regex = "(?:(.+({0,0}+?(.)+){1,5}))",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 3,
		},
		regex = "a{}",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("{"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("1"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("2"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("3"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte(","),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("4"),
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("}"),
			},
			_index = 9,
		},
		regex = "a{123,,4}",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 0,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				rangeIndex = 2,
				ranges = {
					string.byte("0"),
					string.byte("9"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%d++",
	},
	{
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				quantifier = {
					max = 0,
					min = 1,
					type = "quantifier",
				},
				rangeIndex = 2,
				ranges = {
					string.byte("0"),
					string.byte("9"),
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
		regex = "%d+",
	},
	{
		errorMessage = "Invalid regular expression: Numbers out of order in quantifier",
		regex = "a{2,1}",
	},
	{
		errorMessage = "Invalid regular expression: Numbers out of order in quantifier",
		regex = "a{12,2}",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "a+++",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "*",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "??",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "{1,2}",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "()+",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "^+.",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = ".$+",
	},
}
