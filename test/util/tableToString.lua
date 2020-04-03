local test = require("../../test/util")

assert(test.tableToString({ 'a', 'b', 'c' }) == "{\"a\",\"b\",\"c\"}", "#1 | Cannot convert table to string.")
assert(test.tableToString({ 'a', 'b', 'c' }, true) == "{\n\t\"a\",\n\t\"b\",\n\t\"c\"\n}", "#2 | Cannot convert table to string.")
assert(test.tableToString({ 'a', 'b', 'c' }, true, true) == "{\n\t[1] = \"a\",\n\t[2] = \"b\",\n\t[3] = \"c\"\n}", "#3 | Cannot convert table to string.")
assert(test.tableToString({ 'a', 'b', 'c' }, false, true) == "{[1] = \"a\",[2] = \"b\",[3] = \"c\"}", "#3 | Cannot convert table to string.")
assert(test.tableToString({ 'a', true, false, 1, 1.5, { a = 1 } }) == "{\"a\",true,false,1,1.5,{a = 1}}", "#4 | Cannot convert table to string.")
assert(test.tableToString({ 'a', true, false, 1, 1.5, { a = 1 } }, false, false, 1) == "{\"a\",true,false,1,1.5,type_table}", "#5 | Cannot convert table to string.")

return false