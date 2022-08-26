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
}