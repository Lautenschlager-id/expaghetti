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
				type = "position_capture",
				quantifier = false
			},
			{
				type = "literal",
				value = 'b'
			},
			{
				type = "position_capture",
				quantifier = false
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
		regex = ".((?<named>.))",
		parsed = {
			_index = 2,
			{
				type = "any"
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "group",
						hasBehavior = true,
						name = "named",
						tree = {
							_index = 1,
							{
								type = "any"
							}
						}
					}
				}
			}
		}
	},
	{
		regex = ".((?<n4m3d_>.))",
		parsed = {
			_index = 2,
			{
				type = "any"
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "group",
						hasBehavior = true,
						name = "n4m3d_",
						tree = {
							_index = 1,
							{
								type = "any"
							}
						}
					}
				}
			}
		}
	},
	{
		regex = ".(?<_007>.)",
		parsed = {
			_index = 2,
			{
				type = "any"
			},
			{
				type = "group",
				hasBehavior = true,
				name = "_007",
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
		regex = "(.)(.)%1%2%3",
		parsed = {
			_index = 5,
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "capture_reference",
				index = 1
			},
			{
				type = "capture_reference",
				index = 2
			},
			{
				type = "capture_reference",
				index = 3
			}
		}
	},
	{
		regex = "(.)%%1%30",
		parsed = {
			_index = 5,
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "literal",
				value = '%'
			},
			{
				type = "literal",
				value = '1'
			},
			{
				type = "capture_reference",
				index = 3
			},
			{
				type = "literal",
				value = '0'
			}
		}
	},
	{
		regex = "(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)%k<12>",
		parsed = {
			_index = 13,
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "group",
				tree = {
					_index = 1,
					{
						type = "any"
					}
				}
			},
			{
				type = "capture_reference",
				index = 12
			}
		}
	},
	{
		regex = "(?<abc>(?<def>(?<ghi>%k<abc>)))%k<ghi>%k<def>",
		parsed = {
			_index = 3,
			{
				type = "group",
				hasBehavior = true,
				name = "abc",
				tree = {
					_index = 1,
					{
						type = "group",
						hasBehavior = true,
						name = "def",
						tree = {
							_index = 1,
							{
								type = "group",
								hasBehavior = true,
								name = "ghi",
								tree = {
									_index = 1,
									{
										type = "capture_reference",
										index = "abc"
									}
								}
							}
						}
					}
				}
			},
			{
				type = "capture_reference",
				index = "ghi"
			},
			{
				type = "capture_reference",
				index = "def"
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
	{
		regex = "(?<>)",
		errorMessage = "Invalid regular expression: Invalid group name"
	},
	{
		regex = "(?<007>)",
		errorMessage = "Invalid regular expression: Invalid group name"
	},
	{
		regex = "(?<_ 007>)",
		errorMessage = "Invalid regular expression: Invalid group name"
	},
	{
		regex = "(?<abc>)(?<abc>)",
		errorMessage = "Invalid regular expression: Duplicated group name <abc>"
	},
	{
		regex = "(?<o%w>)",
		errorMessage = "Invalid regular expression: Invalid group name"
	},
	{
		regex = "(?%w)",
		errorMessage = "Invalid regular expression: Invalid group behavior"
	},
	{
		regex = "(?<%>>)",
		errorMessage = "Invalid regular expression: Invalid group name"
	},
	{
		regex = "%k",
		errorMessage = "Invalid regular expression: Invalid backreference call: Missing '<'"
	},
	{
		regex = "%k<",
		errorMessage = "Invalid regular expression: Unterminated backreference: Missing '>'"
	},
	{
		regex = "%k<>",
		errorMessage = "Invalid regular expression: Invalid backreference name"
	},
	{
		regex = "%k<$.>",
		errorMessage = "Invalid regular expression: Invalid backreference name"
	},
	{
		regex = "%k<oi%>",
		errorMessage = "Invalid regular expression: Invalid backreference name"
	},
}