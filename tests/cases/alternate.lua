return {
	{
		regex = "a|b|c|d",
		parsed = {
			_index = 1,
			{
				type = "alternate",
				trees = {
					_index = 4,
					{
						_index = 1,
						{
							type = "literal",
							value = 'a'
						}
					},
					{
						_index = 1,
						{
							type = "literal",
							value = 'b'
						}
					},
					{
						_index = 1,
						{
							type = "literal",
							value = 'c'
						}
					},
					{
						_index = 1,
						{
							type = "literal",
							value = 'd'
						}
					}
				}
			}
		}
	},
	{
		regex = "abc||d(e|.+)",
		parsed = {
			_index = 1,
			{
				type = "alternate",
				trees = {
					_index = 3,
					{
						_index = 3,
						{
							type = "literal",
							value = 'a'
						},
						{
							type = "literal",
							value = 'b'
						},
						{
							type = "literal",
							value = 'c'
						}
					},
					{
						_index = 0
					},
					{
						_index = 2,
						{
							type = "literal",
							value = 'd'
						},
						{
							type = "group",
							tree = {
								_index = 1,
								{
									type = "alternate",
									trees = {
										_index = 2,
										{
											_index = 1,
											{
												type = "literal",
												value = 'e'
											}
										},
										{
											_index = 1,
											{
												type = "any",
												quantifier = {
													type = "quantifier",
													min = 1,
													max = nil
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	},
	{
		regex = "|a((b|c||||d(e|))|.+)|.|",
		parsed = {
			_index = 1,
			{
				type = "alternate",
				trees = {
					_index = 4,
					{
						_index = 0
					},
					{
						_index = 2,
						{
							type = "literal",
							value = 'a'
						},
						{
							type = "group",
							tree = {
								_index = 1,
								{
									type = "alternate",
									trees = {
										_index = 2,
										{
											_index = 1,
											{
												type = "group",
												tree = {
													_index = 1,
													{
														type = "alternate",
														trees = {
															_index = 6,
															{
																_index = 1,
																{
																	type = "literal",
																	value = 'b'
																}
															},
															{
																_index = 1,
																{
																	type = "literal",
																	value = 'c'
																}
															},
															{
																_index = 0
															},
															{
																_index = 0
															},
															{
																_index = 0
															},
															{
																_index = 2,
																{
																	type = "literal",
																	value = 'd'
																},
																{
																	type = "group",
																	tree = {
																		_index = 1,
																		{
																			type = "alternate",
																			trees = {
																				_index = 2,
																				{
																					_index = 1,
																					{
																						type = "literal",
																						value = 'e'
																					}
																				},
																				{
																					_index = 0
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										},
										{
											_index = 1,
											{
												type = "any",
												quantifier = {
													type = "quantifier",
													min = 1,
													max = nil
												}
											}
										}
									}
								}
							}
						}
					},
					{
						_index = 1,
						{
							type = "any"
						}
					},
					{
						_index = 0
					}
				}
			}
		}
	},
	{
		regex = "a(?:%?|%|%))++c",
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
						type = "alternate",
						trees = {
							_index = 2,
							{
								_index = 1,
								{
									type = "literal",
									value = '?'
								}
							},
							{
								_index = 2,
								{
									type = "literal",
									value = '|'
								},
								{
									type = "literal",
									value = ')'
								}
							}
						}
					}
				},
				quantifier = {
					type = "quantifier",
					min = 1,
					max = nil,
					mode = "possessive"
				}
			},
			{
				type = "literal",
				value = 'c'
			}
		}
	},
	{
		regex = "a[b|c]d",
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
				['b'] = true,
				['|'] = true,
				['c'] = true
			},
			{
				type = "literal",
				value = 'd'
			}
		}
	},
	{
		regex = '|',
		parsed = {
			_index = 1,
			{
				type = "alternate",
				trees = {
					_index = 2,
					{
						_index = 0
					},
					{
						_index = 0
					}
				}
			}
		}
	},
	{
		regex = '|%+',
		parsed = {
			_index = 1,
			{
				type = "alternate",
				trees = {
					_index = 2,
					{
						_index = 0
					},
					{
						_index = 1,
						{
							type = "literal",
							value = '+'
						}
					}
				}
			}
		}
	},
	{
		regex = '|(|',
		errorMessage = "Invalid regular expression: Unterminated group"
	},
	{
		regex = '|+',
		errorMessage = "Invalid regular expression: Nothing to repeat"
	},
	{
		regex = '|++',
		errorMessage = "Invalid regular expression: Nothing to repeat"
	},
}