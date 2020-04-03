local test = require("../../test/util")

assert(test.tableCompare({ }, { }), "#1 | Cannot compare tables")
assert(test.tableCompare({ 'a', true, false, 1, 1.5, { a = 1 } }, { 'a', true, false, 1, 1.5, { a = 1 } }), "#2 | Cannot compare tables")
assert(not test.tableCompare({ 'a', true, false, 1, 1.5, { a = 1 } }, { 'a', true, false, 1, 1.5, { a = 1.000000000000001 } }), "#3 | Cannot compare tables")
assert(not test.tableCompare(setmetatable({ }, { }), { }, true), "#4 | Cannot compare tables")
assert(not test.tableCompare({ }, setmetatable({ }, { }), true), "#5 | Cannot compare tables")
assert(test.tableCompare(nil, nil), "#6 | Cannot compare tables")

return false