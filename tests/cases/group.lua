return {
	{
		regex = "(a)",
		parsed = {
			_index = 1,
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "literal",
						value = 'a'
					}
				}
			}
		}
	},
	{
		regex = "a(b)c",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "literal",
						value = 'b'
					}
				}
			},
			{
				type = "literal",
				value = 'c'
			}
		}
	},
	{
		regex = "a(b((%((%.))%)))c",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "group",
				tree = {
					_index = 2,
					{
						type = "literal",
						value = 'b'
					},
					{
						type = "group",
						tree = {
							_index = 2,
							{
								type = "group",
								tree = {
									_index = 2,
									{
										type = "literal",
										value = '('
									},
									{
										type = "group",
										tree = {
											_index = 1,
											{
												type = "literal",
												value = '.'
											}
										}
									}
								}
							},
							{
								type = "literal",
								value = ')'
							}
						},
					}
				}
			},
			{
				type = "literal",
				value = 'c'
			}
		}
	},
	{
		regex = "a()b()c",
		parsed = {
			_index = 5,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "position_capture"
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "position_capture"
			},
			{
				type = "literal",
				value = 'c'
			}
		}
	},
	{
		regex = "a(%?:b)",
		parsed = {
			_index = 2,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "group",
				tree = {
					_index = 3,
					{
						type = "literal",
						value = '?'
					},
					{
						type = "literal",
						value = ':'
					},
					{
						type = "literal",
						value = 'b'
					},
				}
			}
		}
	},
	{
		regex = "a(?:(~))b",
		parsed = {
			_index = 3,
			{
				type = "literal",
				value = 'a'
			},
			{
				type = "group",
				hasBehavior = true,
				disableCapture = true,
				tree = {
					_index = 1,
					{
						type = "group",
						tree = {
							_index = 1,
							{
								type = "literal",
								value = '~'
							}
						}
					}
				}
			},
			{
				type = "literal",
				value = 'b'
			}
		}
	},
	{
		regex = ".(?>..(.)).",
		parsed = {
			_index = 3,
			{
				type = "any"
			},
			{
				type = "group",
				hasBehavior = true,
				isAtomic = true,
				tree = {
					_index = 3,
					{
						type = "any"
					},
					{
						type = "any"
					},
					{
						type = "group",
						tree = {
							_index = 1,
							{
								type = "any"
							}
						}
					}
				}
			},
			{
				type = "any"
			}
		}
	},
	{
		regex = ".(?!(?=.)).",
		parsed = {
			_index = 3,
			{
				type = "any"
			},
			{
				type = "group",
				hasBehavior = true,
				isLookahead = true,
				isNegative = true,
				tree = {
					_index = 1,
					{
						type = "group",
						hasBehavior = true,
						isLookahead = true,
						tree = {
							_index = 1,
							{
								type = "any"
							}
						}
					}
				}
			},
			{
				type = "any"
			}
		}
	},
	{
		regex = ".(?<!(?=.)).",
		parsed = {
			_index = 3,
			{
				type = "any"
			},
			{
				type = "group",
				hasBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					_index = 1,
					{
						type = "group",
						hasBehavior = true,
						isLookahead = true,
						tree = {
							_index = 1,
							{
								type = "any"
							}
						}
					}
				}
			},
			{
				type = "any"
			}
		}
	},
	{
		regex = ".(?<!(?<=.)).",
		parsed = {
			_index = 3,
			{
				type = "any"
			},
			{
				type = "group",
				hasBehavior = true,
				isLookbehind = true,
				isNegative = true,
				tree = {
					_index = 1,
					{
						type = "group",
						hasBehavior = true,
						isLookbehind = true,
						tree = {
							_index = 1,
							{
								type = "any"
							}
						}
					}
				}
			},
			{
				type = "any"
			}
		}
	},
	{
		regex = "(?:)",
		parsed = {
			_index = 1,
			{
				type = "group",
				hasBehavior = true,
				disableCapture = true,
			}
		}
	},
	{
		regex = "a(",
		errorMessage = "Invalid regular expression: Unterminated group"
	},
	{
		regex = "a)",
		errorMessage = "Invalid regular expression: No group to close"
	},
	{
		regex = "(??)",
		errorMessage = "Invalid regular expression: Invalid group behavior"
	},
	{
		regex = "(?<b)",
		errorMessage = "Invalid regular expression: Invalid group name"
	},
}