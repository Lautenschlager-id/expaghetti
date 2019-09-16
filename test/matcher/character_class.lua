local test = require("../../test/util")
local set = require("../../handler/set")
local enum = require("../../enum")

local try
do
	local tries = { 'a', 'z', 'A', 'Z', '0', '9', '@', ')', '\n', ' ' }
	try = function(name, values, src)
		src = src or enum.class

		for i = 1, #tries do
			test.assertion.value(set.match, values[i] == 1, name, src[name], tries[i])
		end
	end
end

-- Regular
try('a', { 1, 1, 1, 1, 0, 0, 0, 0, 0, 0 })
try('d', { 0, 0, 0, 0, 1, 1, 0, 0, 0, 0 })
try('h', { 1, 0, 1, 0, 1, 1, 0, 0, 0, 0 })
try('x', { 1, 0, 1, 0, 1, 1, 0, 0, 0, 0 })
try('l', { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 })
try('p', { 0, 0, 0, 0, 0, 0, 1, 1, 0, 0 })
try('s', { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1 })
try('u', { 0, 0, 1, 1, 0, 0, 0, 0, 0, 0 })
try('w', { 1, 1, 1, 1, 1, 1, 0, 0, 0, 0 })

-- Negated Regular
try('A', { 0, 0, 0, 0, 1, 1, 1, 1, 1, 1 })
try('D', { 1, 1, 1, 1, 0, 0, 1, 1, 1, 1 })
try('H', { 0, 1, 0, 1, 0, 0, 1, 1, 1, 1 })
try('X', { 0, 1, 0, 1, 0, 0, 1, 1, 1, 1 })
try('L', { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 })
try('P', { 1, 1, 1, 1, 1, 1, 0, 0, 1, 1 })
try('S', { 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 })
try('U', { 1, 1, 0, 0, 1, 1, 1, 1, 1, 1 })
try('W', { 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 })

-- .
try('any', { 1, 1, 1, 1, 1, 1, 1, 1, 0, 1 }, enum.specialClass)

-- %c
test.assertion.object(
	"%cA",
	'\001'
)

test.assertion.object(
	"%ca",
	'\001'
)

test.assertion.object(
	"%cZ",
	'\026'
)

-- %e
test.assertion.object(
	"%e00A9",
	'©'
)

test.assertion.object(
	"%e0123",
	'ģ'
)

test.assertion.object(
	"%e01e2",
	'Ǣ'
)

test.assertion.object(
	"%e01e2",
	'Ǣ'
)

-- Others
test.assertion.object(
	"%%a%%",
	{
		'%',
		'a',
		'%'
	},
	true
)

test.assertion.object(
	"%(%)",
	{
		'(',
		')'
	},
	true
)

return test.assertion.get()