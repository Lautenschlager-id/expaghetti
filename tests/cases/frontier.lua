return {
	{
		regex = "%f[%a]",
		parsed = {
			{
				set = {
					rangeIndex = 0,
					ranges = {},
					type = "set",
					classIndex = 1,
					values = {},
					classes = {
						{
							rangeIndex = 4,
							ranges = {
								string.byte("a"),
								string.byte("z"),
								string.byte("A"),
								string.byte("Z")
							},
							type = "set",
							classIndex = 0,
							values = {},
							classes = {},
							hasToNegateMatch = false
						}
					},
					hasToNegateMatch = false
				},
				isNegated = false,
				type = "frontier"
			},
			_index = 1
		}
	},
	{
		regex = "%F[%a]",
		parsed = {
			{
				set = {
					rangeIndex = 0,
					ranges = {},
					type = "set",
					classIndex = 1,
					values = {},
					classes = {
						{
							rangeIndex = 4,
							ranges = {
								string.byte("a"),
								string.byte("z"),
								string.byte("A"),
								string.byte("Z")
							},
							type = "set",
							classIndex = 0,
							values = {},
							classes = {},
							hasToNegateMatch = false
						}
					},
					hasToNegateMatch = false
				},
				isNegated = true,
				type = "frontier"
			},
			_index = 1
		}
	},
	{
		regex = "a%f[%w]b",
		parsed = {
			{
				type = "literal",
				isCaseInsensitive = false,
				value = string.byte("a")
			},
			{
				set = {
					rangeIndex = 0,
					ranges = {},
					type = "set",
					classIndex = 1,
					values = {},
					classes = {
						{
							rangeIndex = 6,
							ranges = {
								string.byte("0"),
								string.byte("9"),
								string.byte("a"),
								string.byte("z"),
								string.byte("A"),
								string.byte("Z")
							},
							type = "set",
							classIndex = 0,
							values = {
								[string.byte("_")] = true
							},
							classes = {},
							hasToNegateMatch = false
						}
					},
					hasToNegateMatch = false
				},
				isNegated = false,
				type = "frontier"
			},
			{
				type = "literal",
				isCaseInsensitive = false,
				value = string.byte("b")
			},
			_index = 3
		}
	},
	{
		regex = "%f[^%d]",
		parsed = {
			{
				set = {
					rangeIndex = 0,
					ranges = {},
					type = "set",
					classIndex = 1,
					values = {},
					classes = {
						{
							rangeIndex = 2,
							ranges = {
								string.byte("0"),
								string.byte("9")
							},
							type = "set",
							classIndex = 0,
							values = {},
							classes = {},
							hasToNegateMatch = false
						}
					},
					hasToNegateMatch = true
				},
				isNegated = false,
				type = "frontier"
			},
			_index = 1
		}
	},
	{
		regex = "(%f[%a])(?:%F[%d])",
		parsed = {
			{
				tree = {
					{
						set = {
							rangeIndex = 0,
							ranges = {},
							type = "set",
							classIndex = 1,
							values = {},
							classes = {
								{
									rangeIndex = 4,
									ranges = {
										string.byte("a"),
										string.byte("z"),
										string.byte("A"),
										string.byte("Z")
									},
									type = "set",
									classIndex = 0,
									values = {},
									classes = {},
									hasToNegateMatch = false
								}
							},
							hasToNegateMatch = false
						},
						isNegated = false,
						type = "frontier"
					},
					_index = 1
				},
				index = 1,
				type = "group"
			},
			{
				tree = {
					{
						set = {
							rangeIndex = 0,
							ranges = {},
							type = "set",
							classIndex = 1,
							values = {},
							classes = {
								{
									rangeIndex = 2,
									ranges = {
										string.byte("0"),
										string.byte("9")
									},
									type = "set",
									classIndex = 0,
									values = {},
									classes = {},
									hasToNegateMatch = false
								}
							},
							hasToNegateMatch = false
						},
						isNegated = true,
						type = "frontier"
					},
					_index = 1
				},
				isNonCapturing = true,
				hasSpecialBehavior = true,
				type = "group"
			},
			_index = 2
		}
	},
	{
		regex = "%f",
		errorMessage = "Invalid regular expression: Expected a character set after frontier pattern",
	},
	{
		regex = "%F",
		errorMessage = "Invalid regular expression: Expected a character set after frontier pattern",
	},
}
