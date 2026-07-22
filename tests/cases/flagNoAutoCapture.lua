return {
	{
		regex = "(abc)",
		flags = {
			["n"] = true
		},
		parsed = {
			{
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("c")
					},
					_index = 3
				},
				disableCapture = true,
				type = "group"
			},
			_index = 1
		}
	},
	{
		regex = "(?n)(abc)",
		flags = {},
		parsed = {
			{
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("c")
					},
					_index = 3
				},
				disableCapture = true,
				type = "group"
			},
			_index = 1
		}
	},
	{
		regex = "(?n:(abc))",
		flags = {},
		parsed = {
			{
				scopedFlags = {
					enable = {
						["n"] = true
					},
					disable = {}
				},
				disableCapture = true,
				type = "group",
				hasBehavior = true,
				tree = {
					{
						tree = {
							{
								isCaseInsensitive = false,
								type = "literal",
								value = string.byte("a")
							},
							{
								isCaseInsensitive = false,
								type = "literal",
								value = string.byte("b")
							},
							{
								isCaseInsensitive = false,
								type = "literal",
								value = string.byte("c")
							},
							_index = 3
						},
						disableCapture = true,
						type = "group"
					},
					_index = 1
				}
			},
			_index = 1
		}
	},
	{
		regex = "(?n)((abc)|(def))",
		flags = {},
		parsed = {
			{
				tree = {
					{
						type = "alternate",
						trees = {
							{
								{
									tree = {
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("a")
										},
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("b")
										},
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("c")
										},
										_index = 3
									},
									disableCapture = true,
									type = "group"
								},
								_index = 1
							},
							{
								{
									tree = {
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("d")
										},
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("e")
										},
										{
											isCaseInsensitive = false,
											type = "literal",
											value = string.byte("f")
										},
										_index = 3
									},
									disableCapture = true,
									type = "group"
								},
								_index = 1
							},
							_index = 2
						}
					},
					_index = 1
				},
				disableCapture = true,
				type = "group"
			},
			_index = 1
		}
	},
	{
		regex = "(?n)(?<left>abc)(?<right>def)",
		flags = {},
		parsed = {
			{
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("c")
					},
					_index = 3
				},
				type = "group",
				name = "left",
				hasBehavior = true
			},
			{
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("d")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("e")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("f")
					},
					_index = 3
				},
				type = "group",
				name = "right",
				hasBehavior = true
			},
			_index = 2
		}
	},
	{
		regex = "(?n)(?:abc)(?-n)(def)",
		flags = {},
		parsed = {
			{
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("a")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("b")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("c")
					},
					_index = 3
				},
				disableCapture = true,
				type = "group",
				hasBehavior = true
			},
			{
				index = 1,
				tree = {
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("d")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("e")
					},
					{
						isCaseInsensitive = false,
						type = "literal",
						value = string.byte("f")
					},
					_index = 3
				},
				type = "group"
			},
			_index = 2
		}
	}
}
