return {
	{
		regex = "abc",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "a",
				type = "literal",
				upperValue = "A",
				value = "a",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "b",
				type = "literal",
				upperValue = "B",
				value = "b",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "c",
				type = "literal",
				upperValue = "C",
				value = "c",
			},
			_index = 3,
		},
	},
	{
		regex = "ABC",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "a",
				type = "literal",
				upperValue = "A",
				value = "A",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "b",
				type = "literal",
				upperValue = "B",
				value = "B",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "c",
				type = "literal",
				upperValue = "C",
				value = "C",
			},
			_index = 3,
		},
	},
	{
		regex = "%+%*%.",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "+",
				type = "literal",
				upperValue = "+",
				value = "+",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "*",
				type = "literal",
				upperValue = "*",
				value = "*",
			},
			{
				isCaseInsensitive = true,
				lowerValue = ".",
				type = "literal",
				upperValue = ".",
				value = ".",
			},
			_index = 3,
		},
	},
	{
		regex = "%cA%cb",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isCaseInsensitive = true,
				lowerValue = "\1",
				type = "literal",
				upperValue = "\1",
				value = "\1",
			},
			{
				isCaseInsensitive = true,
				lowerValue = "\2",
				type = "literal",
				upperValue = "\2",
				value = "\2",
			},
			_index = 2,
		},
	},
	{
		regex = "[abc]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
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
					A = true,
					B = true,
					C = true,
					a = true,
					b = true,
					c = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[a-z]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					"a",
					"z",
					"A",
					"Z",
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[A-Z]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					"a",
					"z",
					"A",
					"Z",
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[a-cXY]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = false,
				rangeIndex = 4,
				ranges = {
					"a",
					"c",
					"A",
					"C",
				},
				type = "set",
				values = {
					X = true,
					Y = true,
					x = true,
					y = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[^a-cXY]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 0,
				classes = {
				},
				hasToNegateMatch = true,
				rangeIndex = 4,
				ranges = {
					"a",
					"c",
					"A",
					"C",
				},
				type = "set",
				values = {
					X = true,
					Y = true,
					x = true,
					y = true,
				},
			},
			_index = 1,
		},
	},
	{
		regex = "[%a]",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				classIndex = 1,
				classes = {
					{
						classIndex = 0,
						classes = {
						},
						hasToNegateMatch = false,
						rangeIndex = 8,
						ranges = {
							"a",
							"z",
							"A",
							"Z",
							"a",
							"z",
							"A",
							"Z",
						},
						type = "set",
						values = {
						},
					},
				},
				hasToNegateMatch = false,
				rangeIndex = 0,
				ranges = {
				},
				type = "set",
				values = {
				},
			},
			_index = 1,
		},
	},
	{
		regex = "(abc)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?:abc)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?=abc)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?!abc)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				isNegative = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "b",
						type = "literal",
						upperValue = "B",
						value = "b",
					},
					{
						isCaseInsensitive = true,
						lowerValue = "c",
						type = "literal",
						upperValue = "C",
						value = "c",
					},
					_index = 3,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "a|b",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				branches = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = "a",
							type = "literal",
							upperValue = "A",
							value = "a",
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = true,
							lowerValue = "b",
							type = "literal",
							upperValue = "B",
							value = "b",
						},
						_index = 1,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
	},
	{
		regex = "abc|def",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				branches = {
					{
						{
							isCaseInsensitive = true,
							lowerValue = "a",
							type = "literal",
							upperValue = "A",
							value = "a",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "b",
							type = "literal",
							upperValue = "B",
							value = "b",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "c",
							type = "literal",
							upperValue = "C",
							value = "c",
						},
						_index = 3,
					},
					{
						{
							isCaseInsensitive = true,
							lowerValue = "d",
							type = "literal",
							upperValue = "D",
							value = "d",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "e",
							type = "literal",
							upperValue = "E",
							value = "e",
						},
						{
							isCaseInsensitive = true,
							lowerValue = "f",
							type = "literal",
							upperValue = "F",
							value = "f",
						},
						_index = 3,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
	},
	{
		regex = ".",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				type = "any",
			},
			_index = 1,
		},
	},
	{
		regex = "([a-z]+)",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				index = 1,
				tree = {
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
						rangeIndex = 4,
						ranges = {
							"a",
							"z",
							"A",
							"Z",
						},
						type = "set",
						values = {
						},
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = "(?=a)[b-c]+",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				isNonCapturing = true,
				hasSpecialBehavior = true,
				isLookahead = true,
				tree = {
					{
						isCaseInsensitive = true,
						lowerValue = "a",
						type = "literal",
						upperValue = "A",
						value = "a",
					},
					_index = 1,
				},
				type = "group",
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
				rangeIndex = 4,
				ranges = {
					"b",
					"c",
					"B",
					"C",
				},
				type = "set",
				values = {
				},
			},
			_index = 2,
		},
	},
	{
		regex = "(a|[b-z]){2,5}",
		flags = {
			['i'] = true,
			['u'] = true,
		},
		parsed = {
			{
				index = 1,
				quantifier = {
					max = 5,
					min = 2,
					type = "quantifier",
				},
				tree = {
					{
						branches = {
							{
								{
									isCaseInsensitive = true,
									lowerValue = "a",
									type = "literal",
									upperValue = "A",
									value = "a",
								},
								_index = 1,
							},
							{
								{
									classIndex = 0,
									classes = {
									},
									hasToNegateMatch = false,
									rangeIndex = 4,
									ranges = {
										"b",
										"z",
										"B",
										"Z",
									},
									type = "set",
									values = {
									},
								},
								_index = 1,
							},
							_index = 2,
						},
						type = "alternate",
					},
					_index = 1,
				},
				type = "group",
			},
			_index = 1,
		},
	},
	{
		regex = ".*",
		flags = {
			["s"] = true,
			i = true
		},
		parsed = {
			{
				quantifier = {
					min = 0,
					type = "quantifier",
					max = 0
				},
				isDotAll = true,
				type = "any"
			},
			_index = 1
		}
	},
	{
		regex = "(?is).",
		flags = {},
		parsed = {
			{
				type = "any",
				isDotAll = true
			},
			_index = 1
		}
	},
	{
		regex = "^abc$",
		flags = {
			["m"] = true,
			i = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				upperValue = 65,
				value = string.byte("a"),
				type = "literal",
				isCaseInsensitive = true,
				lowerValue = 97
			},
			{
				upperValue = 66,
				value = string.byte("b"),
				type = "literal",
				isCaseInsensitive = true,
				lowerValue = 98
			},
			{
				upperValue = 67,
				value = string.byte("c"),
				type = "literal",
				isCaseInsensitive = true,
				lowerValue = 99
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 5
		}
	},
	{
		regex = "(?im)^abc$",
		flags = {},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				upperValue = 65,
				value = string.byte("a"),
				type = "literal",
				isCaseInsensitive = true,
				lowerValue = 97
			},
			{
				upperValue = 66,
				value = string.byte("b"),
				type = "literal",
				isCaseInsensitive = true,
				lowerValue = 98
			},
			{
				upperValue = 67,
				value = string.byte("c"),
				type = "literal",
				isCaseInsensitive = true,
				lowerValue = 99
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 5
		}
	},
	{
		regex = "(abc)",
		flags = {
			["n"] = true,
			i = true
		},
		parsed = {
			{
				type = "group",
				tree = {
					{
						upperValue = 65,
						value = string.byte("a"),
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = 97
					},
					{
						upperValue = 66,
						value = string.byte("b"),
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = 98
					},
					{
						upperValue = 67,
						value = string.byte("c"),
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = 99
					},
					_index = 3
				},
				isNonCapturing = true
			},
			_index = 1
		}
	},
	{
		regex = "(?in)(abc)",
		flags = {},
		parsed = {
			{
				type = "group",
				tree = {
					{
						upperValue = 65,
						value = string.byte("a"),
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = 97
					},
					{
						upperValue = 66,
						value = string.byte("b"),
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = 98
					},
					{
						upperValue = 67,
						value = string.byte("c"),
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = 99
					},
					_index = 3
				},
				isNonCapturing = true
			},
			_index = 1
		}
	},
	{
		regex = ".*",
		flags = {
			["s"] = true,
			u = true
		},
		parsed = {
			{
				quantifier = {
					min = 0,
					type = "quantifier",
					max = 0
				},
				isDotAll = true,
				type = "any"
			},
			_index = 1
		}
	},
	{
		regex = "(?s:.)",
		flags = {
			u = true
		},
		parsed = {
			{
				hasSpecialBehavior = true,
				type = "group",
				tree = {
					{
						type = "any",
						isDotAll = true
					},
					_index = 1
				},
				isNonCapturing = true,
				scopedFlags = {
					disable = {},
					enable = {
						["s"] = true
					}
				}
			},
			_index = 1
		}
	},
	{
		regex = "^abc$",
		flags = {
			["m"] = true,
			u = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				value = "a",
				type = "literal",
				isCaseInsensitive = false
			},
			{
				value = "b",
				type = "literal",
				isCaseInsensitive = false
			},
			{
				value = "c",
				type = "literal",
				isCaseInsensitive = false
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 5
		}
	},
	{
		regex = "(?m:^abc$)",
		flags = {
			u = true
		},
		parsed = {
			{
				hasSpecialBehavior = true,
				type = "group",
				tree = {
					{
						isStart = true,
						type = "anchor",
						isMultiline = true
					},
					{
						value = "a",
						type = "literal",
						isCaseInsensitive = false
					},
					{
						value = "b",
						type = "literal",
						isCaseInsensitive = false
					},
					{
						value = "c",
						type = "literal",
						isCaseInsensitive = false
					},
					{
						isStart = false,
						type = "anchor",
						isMultiline = true
					},
					_index = 5
				},
				isNonCapturing = true,
				scopedFlags = {
					disable = {},
					enable = {
						["m"] = true
					}
				}
			},
			_index = 1
		}
	},
	{
		regex = "(abc)",
		flags = {
			["n"] = true,
			u = true
		},
		parsed = {
			{
				type = "group",
				tree = {
					{
						value = "a",
						type = "literal",
						isCaseInsensitive = false
					},
					{
						value = "b",
						type = "literal",
						isCaseInsensitive = false
					},
					{
						value = "c",
						type = "literal",
						isCaseInsensitive = false
					},
					_index = 3
				},
				isNonCapturing = true
			},
			_index = 1
		}
	},
	{
		regex = "(?n:(abc))",
		flags = {
			u = true
		},
		parsed = {
			{
				hasSpecialBehavior = true,
				type = "group",
				tree = {
					{
						type = "group",
						tree = {
							{
								value = "a",
								type = "literal",
								isCaseInsensitive = false
							},
							{
								value = "b",
								type = "literal",
								isCaseInsensitive = false
							},
							{
								value = "c",
								type = "literal",
								isCaseInsensitive = false
							},
							_index = 3
						},
						isNonCapturing = true
					},
					_index = 1
				},
				isNonCapturing = true,
				scopedFlags = {
					disable = {},
					enable = {
						["n"] = true
					}
				}
			},
			_index = 1
		}
	},
	{
		regex = "^.*$",
		flags = {
			["s"] = true,
			["m"] = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				quantifier = {
					min = 0,
					type = "quantifier",
					max = 0
				},
				isDotAll = true,
				type = "any"
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 3
		}
	},
	{
		regex = "(?ms)^.*$",
		flags = {},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				quantifier = {
					min = 0,
					type = "quantifier",
					max = 0
				},
				isDotAll = true,
				type = "any"
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 3
		}
	},
	{
		regex = "(.+).",
		flags = {
			["n"] = true,
			["s"] = true
		},
		parsed = {
			{
				type = "group",
				tree = {
					{
						quantifier = {
							min = 1,
							type = "quantifier",
							max = 0
						},
						isDotAll = true,
						type = "any"
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				type = "any",
				isDotAll = true
			},
			_index = 2
		}
	},
	{
		regex = "(?sn)(.+).",
		flags = {},
		parsed = {
			{
				type = "group",
				tree = {
					{
						quantifier = {
							min = 1,
							type = "quantifier",
							max = 0
						},
						isDotAll = true,
						type = "any"
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				type = "any",
				isDotAll = true
			},
			_index = 2
		}
	},
	{
		regex = "^(.+)$",
		flags = {
			["n"] = true,
			["m"] = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "group",
				tree = {
					{
						type = "any",
						quantifier = {
							min = 1,
							type = "quantifier",
							max = 0
						}
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 3
		}
	},
	{
		regex = "(?mn)^(.+)$",
		flags = {},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "group",
				tree = {
					{
						type = "any",
						quantifier = {
							min = 1,
							type = "quantifier",
							max = 0
						}
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 3
		}
	},
	{
		regex = "^(.+).$",
		flags = {
			["s"] = true,
			i = true,
			["n"] = true,
			u = true,
			["m"] = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "group",
				tree = {
					{
						quantifier = {
							min = 1,
							type = "quantifier",
							max = 0
						},
						isDotAll = true,
						type = "any"
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				type = "any",
				isDotAll = true
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 4
		}
	},
	{
		regex = "(?imsn)^(.+).$",
		flags = {
			u = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				type = "group",
				tree = {
					{
						quantifier = {
							min = 1,
							type = "quantifier",
							max = 0
						},
						isDotAll = true,
						type = "any"
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				type = "any",
				isDotAll = true
			},
			{
				isStart = false,
				type = "anchor",
				isMultiline = true
			},
			_index = 4
		}
	},
	{
		regex = "(?ims)^.*(?-s).(?-m)$",
		flags = {
			u = true
		},
		parsed = {
			{
				isStart = true,
				type = "anchor",
				isMultiline = true
			},
			{
				quantifier = {
					min = 0,
					type = "quantifier",
					max = 0
				},
				isDotAll = true,
				type = "any"
			},
			{
				type = "any"
			},
			{
				type = "anchor",
				isStart = false
			},
			_index = 4
		}
	},
	{
		regex = "(?in)(a)(?-n)(b)",
		flags = {
			u = true
		},
		parsed = {
			{
				type = "group",
				tree = {
					{
						upperValue = "A",
						value = "a",
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = "a"
					},
					_index = 1
				},
				isNonCapturing = true
			},
			{
				type = "group",
				index = 1,
				tree = {
					{
						upperValue = "B",
						value = "b",
						type = "literal",
						isCaseInsensitive = true,
						lowerValue = "b"
					},
					_index = 1
				}
			},
			_index = 2
		}
	}
}
