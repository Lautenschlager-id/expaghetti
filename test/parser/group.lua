local test = require("../../test/util")

-- Capturing
test.assertion.object(
	"(abc)",
	{
		type = "group",
		_behind = false,
		effect = nil,
		_index = 3,
		tree = {
			_index = 3,
			stack = {
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Non-capturing
test.assertion.object(
	"(?:abc)",
	{
		type = "group",
		_behind = false,
		effect = ':',
		_index = 3,
		tree = {
			_index = 3,
			stack = {
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Position capture
test.assertion.object(
	"()",
	{
		type = "position_capture"
	}
)

-- Capture by reference
test.assertion.object(
	"%1",
	{
		type = "capture_reference",
		value = 1
	}
)

-- Positive lookahead
test.assertion.object(
	"(?=abc)",
	{
		type = "group",
		_behind = false,
		effect = '=',
		_index = 3,
		tree = {
			_index = 3,
			stack = {
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Negative lookahead
test.assertion.object(
	"(?!abc)",
	{
		type = "group",
		_behind = false,
		effect = '!',
		_index = 3,
		tree = {
			_index = 3,
			stack = {
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Positive lookbehind
test.assertion.object(
	"(?<=abc)",
	{
		type = "group",
		_behind = true,
		effect = '=',
		_index = 3,
		tree = {
			_index = 3,
			stack = {
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Negative lookbehind
test.assertion.object(
	"(?<!abc)",
	{
		type = "group",
		_behind = true,
		effect = '!',
		_index = 3,
		tree = {
			_index = 3,
			stack = {
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Nested
test.assertion.object(
	"(abc(abc)abc)",
	{
		type = "group",
		_behind = false,
		effect = nil,
		_index = 11,
		tree = {
			_index = 7,
			stack = {
				'a',
				'b',
				'c',
				{
					type = "group",
					_behind = false,
					effect = nil,
					_index = 3,
					tree = {
						_index = 3,
						stack = {
							'a',
							'b',
							'c'
						}		
					}
				},
				'a',
				'b',
				'c'
			}
		}
	}
)

-- Nested with effect
test.assertion.object(
	"(abc(?<=abc)abc)",
	{
		type = "group",
		_behind = false,
		effect = nil,
		_index = 14,
		tree = {
			_index = 7,
			stack = {
				'a',
				'b',
				'c',
				{
					type = "group",
					_behind = true,
					effect = '=',
					_index = 3,
					tree = {
						_index = 3,
						stack = {
							'a',
							'b',
							'c'
						}		
					}
				},
				'a',
				'b',
				'c'
			}
		}
	}
)

test.assertion.object(
	"(abc(?<=abc(?:bc(?!c)))abc)",
	{
		type = "group",
		_behind = false,
		effect = nil,
		_index = 25,
		tree = {
			_index = 7,
			stack = {
				'a',
				'b',
				'c',
				{
					type = "group",
					_behind = true,
					effect = '=',
					_index = 14,
					tree = {
						_index = 4,
						stack = {
							'a',
							'b',
							'c',
							{
								type = "group",
								_behind = false,
								effect = ':',
								_index = 7,
								tree = {
									_index = 3,
									stack = {
										'b',
										'c',
										{
											type = "group",
											_behind = false,
											effect = '!',
											_index = 1,
											tree = {
												_index = 1,
												stack = {
													'c'
												}
											}
										}
									}
								}
							}
						}
					}
				},
				'a',
				'b',
				'c'
			}
		}
	}
)

return test.assertion.get()