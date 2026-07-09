return {
	{
		parsed = {
			{
				trees = {
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("a"),
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("b"),
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("c"),
						},
						_index = 1,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("d"),
						},
						_index = 1,
					},
					_index = 4,
				},
				type = "alternate",
			},
			_index = 1,
		},
		regex = "a|b|c|d",
	},
	{
		parsed = {
			{
				trees = {
					{
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
							value = string.byte("c"),
						},
						_index = 3,
					},
					{
						_index = 0,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("d"),
						},
						{
							index = 1,
							tree = {
								{
									trees = {
										{
											{
												isCaseInsensitive = false,
												type = "literal",
												value = string.byte("e"),
											},
											_index = 1,
										},
										{
											{
												quantifier = {
													max = 0,
													min = 1,
													type = "quantifier",
												},
												type = "any",
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
						_index = 2,
					},
					_index = 3,
				},
				type = "alternate",
			},
			_index = 1,
		},
		regex = "abc||d(e|.+)",
	},
	{
		parsed = {
			{
				trees = {
					{
						_index = 0,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("a"),
						},
						{
							index = 1,
							tree = {
								{
									trees = {
										{
											{
												index = 2,
												tree = {
													{
														trees = {
															{
																{
																	isCaseInsensitive = false,
																	type = "literal",
																	value = string.byte("b"),
																},
																_index = 1,
															},
															{
																{
																	isCaseInsensitive = false,
																	type = "literal",
																	value = string.byte("c"),
																},
																_index = 1,
															},
															{
																_index = 0,
															},
															{
																_index = 0,
															},
															{
																_index = 0,
															},
															{
																{
																	isCaseInsensitive = false,
																	type = "literal",
																	value = string.byte("d"),
																},
																{
																	index = 3,
																	tree = {
																		{
																			trees = {
																				{
																					{
																						isCaseInsensitive = false,
																						type = "literal",
																						value = string.byte("e"),
																					},
																					_index = 1,
																				},
																				{
																					_index = 0,
																				},
																				_index = 2,
																			},
																			type = "alternate",
																		},
																		_index = 1,
																	},
																	type = "group",
																},
																_index = 2,
															},
															_index = 6,
														},
														type = "alternate",
													},
													_index = 1,
												},
												type = "group",
											},
											_index = 1,
										},
										{
											{
												quantifier = {
													max = 0,
													min = 1,
													type = "quantifier",
												},
												type = "any",
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
						_index = 2,
					},
					{
						{
							type = "any",
						},
						_index = 1,
					},
					{
						_index = 0,
					},
					_index = 4,
				},
				type = "alternate",
			},
			_index = 1,
		},
		regex = "|a((b|c||||d(e|))|.+)|.|",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
			},
			{
				disableCapture = true,
				hasBehavior = true,
				quantifier = {
					max = 0,
					min = 1,
					mode = "possessive",
					type = "quantifier",
				},
				tree = {
					{
						trees = {
							{
								{
									isCaseInsensitive = false,
									type = "literal",
									value = string.byte("?"),
								},
								_index = 1,
							},
							{
								{
									isCaseInsensitive = false,
									type = "literal",
									value = string.byte("|"),
								},
								{
									isCaseInsensitive = false,
									type = "literal",
									value = string.byte(")"),
								},
								_index = 2,
							},
							_index = 2,
						},
						type = "alternate",
					},
					_index = 1,
				},
				type = "group",
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("c"),
			},
			_index = 3,
		},
		regex = "a(?:%?|%|%))++c",
	},
	{
		parsed = {
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("a"),
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
					[string.byte("b")] = true,
					[string.byte("c")] = true,
					[string.byte("|")] = true,
				},
			},
			{
				isCaseInsensitive = false,
				type = "literal",
				value = string.byte("d"),
			},
			_index = 3,
		},
		regex = "a[b|c]d",
	},
	{
		parsed = {
			{
				index = 1,
				tree = {
					{
						trees = {
							{
								{
									index = 2,
									tree = {
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("a"),
										},
										_index = 1,
									},
									type = "group",
								},
								_index = 1,
							},
							{
								{
									index = 3,
									tree = {
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("b"),
										},
										_index = 1,
									},
									type = "group",
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
		regex = "((a)|(b))",
	},
	{
		parsed = {
			{
				trees = {
					{
						_index = 0,
					},
					{
						_index = 0,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
		regex = "|",
	},
	{
		parsed = {
			{
				trees = {
					{
						_index = 0,
					},
					{
						{
							isCaseInsensitive = false,
							type = "literal",
							value = string.byte("+"),
						},
						_index = 1,
					},
					_index = 2,
				},
				type = "alternate",
			},
			_index = 1,
		},
		regex = "|%+",
	},
	{
		errorMessage = "Invalid regular expression: Unterminated group",
		regex = "|(|",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "|+",
	},
	{
		errorMessage = "Invalid regular expression: Nothing to repeat",
		regex = "|++",
	},
}
