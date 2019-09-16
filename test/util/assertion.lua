local test = require("../../test/util")

-- Error message
test.assertion.error = '.'
assert(test.assertion.get(), "#1 | Cannot get assertion error message")
assert(not test.assertion.get(), "#2 | Cannot get assertion error message")

-- Object
assert(test.assertion.object('a', 'a'), "#1 | Cannot assert between objects")
assert(test.assertion.object('ab', 'a'), "#2 | Cannot assert between objects")
assert(test.assertion.object('ab', { 'a', 'b' }, true), "#3 | Cannot assert between objects")
assert(not test.assertion.object('ab', { 'a', 'b', 'c' }, true), "#4 | Cannot assert between objects")
assert(test.assertion.get() == "'ab' has failed.\n\tGot:\n\t\t{\n\t\t\t[1] = \"a\",\n\t\t\t[2] = \"b\"\n\t\t}\n\tExpected:\n\t\t{\n\t\t\t[1] = \"a\",\n\t\t\t[2] = \"b\",\n\t\t\t[3] = \"c\"\n\t\t}", "#3 | Cannot get assertion error message")

-- Value
assert(test.assertion.value(string.lower, 'a', 'lower', 'A'), "#1 | Cannot assert between values")
assert(not test.assertion.value(string.upper, 'a', 'upper', 'A'), "#2 | Cannot assert between values")
assert(test.assertion.get() ~= "'upper' has failed.\n\tGot:\n\t\ta\n\tExpected:\n\t\tA", "#4 | Cannot get assertion error message")


return false