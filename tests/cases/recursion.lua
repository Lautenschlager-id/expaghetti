return {
	{
		regex = "(?R)",
		parsed = {
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				isRecursionRoot = true
			},
			_index = 1
		}
	},
	{
		regex = "(?0)",
		parsed = {
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				isRecursionRoot = true
			},
			_index = 1
		}
	},
	{
		regex = "(a)(b)(?1)(?2)",
		parsed = {
			{
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					_index = 1
				},
				type = "group",
				index = 1
			},
			{
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("b")
					},
					_index = 1
				},
				type = "group",
				index = 2
			},
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				targetIndex = 1
			},
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				targetIndex = 2
			},
			_index = 4
		}
	},
	{
		regex = "((?1))",
		parsed = {
			{
				tree = {
					{
						tree = {
							_index = 0
						},
						type = "group",
						hasSpecialBehavior = true,
						isRecursion = true,
						targetIndex = 1
					},
					_index = 1
				},
				type = "group",
				index = 1
			},
			_index = 1
		}
	},
	{
		regex = "((?R))",
		parsed = {
			{
				tree = {
					{
						tree = {
							_index = 0
						},
						type = "group",
						hasSpecialBehavior = true,
						isRecursion = true,
						isRecursionRoot = true
					},
					_index = 1
				},
				type = "group",
				index = 1
			},
			_index = 1
		}
	},
	{
		regex = "(?<expr>a)(?&expr)",
		parsed = {
			{
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					_index = 1
				},
				name = "expr",
				index = 1,
				type = "group",
				hasSpecialBehavior = true
			},
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				targetIndex = 1
			},
			_index = 2
		}
	},
	{
		regex = "(?<a>a)(?<b>b)(?&a)(?&b)",
		parsed = {
			{
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					_index = 1
				},
				name = "a",
				index = 1,
				type = "group",
				hasSpecialBehavior = true
			},
			{
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("b")
					},
					_index = 1
				},
				name = "b",
				index = 2,
				type = "group",
				hasSpecialBehavior = true
			},
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				targetIndex = 1
			},
			{
				tree = {
					_index = 0
				},
				type = "group",
				hasSpecialBehavior = true,
				isRecursion = true,
				targetIndex = 2
			},
			_index = 4
		}
	},
	{
		regex = "(?<expr>(?R))",
		parsed = {
			{
				tree = {
					{
						tree = {
							_index = 0
						},
						type = "group",
						hasSpecialBehavior = true,
						isRecursion = true,
						isRecursionRoot = true
					},
					_index = 1
				},
				name = "expr",
				index = 1,
				type = "group",
				hasSpecialBehavior = true
			},
			_index = 1
		}
	},
	{
		regex = "((?R)|a)",
		parsed = {
			{
				tree = {
					{
						type = "alternate",
						branches = {
							{
								{
									tree = {
										_index = 0
									},
									type = "group",
									hasSpecialBehavior = true,
									isRecursion = true,
									isRecursionRoot = true
								},
								_index = 1
							},
							{
								{
									type = "literal",
									isCaseInsensitive = false,
									value = string.byte("a")
								},
								_index = 1
							},
							_index = 2
						}
					},
					_index = 1
				},
				type = "group",
				index = 1
			},
			_index = 1
		}
	},
	{
		regex = "(a(?1)b)",
		parsed = {
			{
				tree = {
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("a")
					},
					{
						tree = {
							_index = 0
						},
						type = "group",
						hasSpecialBehavior = true,
						isRecursion = true,
						targetIndex = 1
					},
					{
						type = "literal",
						isCaseInsensitive = false,
						value = string.byte("b")
					},
					_index = 3
				},
				type = "group",
				index = 1
			},
			_index = 1
		}
	},
	{
		regex = "(?R",
		errorMessage = "Invalid regular expression: Invalid group behavior",
	},
	{
		regex = "(?0",
		errorMessage = "Invalid regular expression: Invalid group behavior",
	},
	{
		regex = "(?1",
		errorMessage = "Invalid regular expression: Invalid group behavior",
	},
	{
		regex = "(?&",
		errorMessage = "Invalid regular expression: Invalid group recursion name",
	},
	{
		regex = "(?&name",
		errorMessage = "Invalid regular expression: Invalid group recursion name",
	},
}
