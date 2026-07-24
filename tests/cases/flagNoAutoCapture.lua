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
				isNonCapturing = true,
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
				isNonCapturing = true,
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
				isNonCapturing = true,
				type = "group",
				hasSpecialBehavior = true,
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
						isNonCapturing = true,
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
						branches = {
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
									isNonCapturing = true,
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
									isNonCapturing = true,
									type = "group"
								},
								_index = 1
							},
							_index = 2
						}
					},
					_index = 1
				},
				isNonCapturing = true,
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
				hasSpecialBehavior = true
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
				hasSpecialBehavior = true
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
				isNonCapturing = true,
				type = "group",
				hasSpecialBehavior = true
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
