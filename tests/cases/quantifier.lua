return {
	{
		regex = "ab+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil
				}
			}
		}
	},
	{
		regex = "ab*",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = nil
				}
			}
		}
	},
	{
		regex = "ab?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 1
				}
			}
		}
	},
	{
		regex = "a+b*c?",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a',
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil
				}
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = nil
				}
			},
			{
				type = "literal",
				value = 'c',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 1
				}
			}
		}
	},
	{
		regex = "ab+?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab*?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = nil,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab??",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 1,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "a+?b*?c??",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a',
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil,
					mode = "lazy"
				}
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = nil,
					mode = "lazy"
				}
			},
			{
				type = "literal",
				value = 'c',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 1,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab++",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab*+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = nil,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab?+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 1,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "a++b*+c?+",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a',
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil,
					mode = "possessive"
				}
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = nil,
					mode = "possessive"
				}
			},
			{
				type = "literal",
				value = 'c',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 1,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{3,12}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 3,
					max = 12
				}
			}
		}
	},
	{
		regex = "ab{12,15}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 12,
					max = 15
				}
			}
		}
	},
	{
		regex = "ab{5,}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 5,
					max = nil
				}
			}
		}
	},
	{
		regex = "ab{404,}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 404,
					max = nil
				}
			}
		}
	},
	{
		regex = "ab{,4}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 4
				}
			}
		}
	},
	{
		regex = "ab{,404}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 404
				}
			}
		}
	},
	{
		regex = "ab{5}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 5,
					max = 5
				}
			}
		}
	},
	{
		regex = "ab{50}",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 50,
					max = 50
				}
			}
		}
	},
	{
		regex = "ab{3,12}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 3,
					max = 12,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{12,15}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 12,
					max = 15,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{5,}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 5,
					max = nil,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{404,}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 404,
					max = nil,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{,4}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 4,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{,404}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 404,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{5}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 5,
					max = 5,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{50}?",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 50,
					max = 50,
					mode = "lazy"
				}
			}
		}
	},
	{
		regex = "ab{3,12}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 3,
					max = 12,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{12,15}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 12,
					max = 15,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{5,}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 5,
					max = nil,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{404,}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 404,
					max = nil,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{,4}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 4,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{,404}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = nil,
					max = 404,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{5}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 5,
					max = 5,
					mode = "possessive"
				}
			}
		}
	},
	{
		regex = "ab{50}+",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "literal",
				value = 'b',
				quantifier = {
					type = "quantifier",
					min = 50,
					max = 50,
					mode = "possessive"
				}
			}
		}
	},
}