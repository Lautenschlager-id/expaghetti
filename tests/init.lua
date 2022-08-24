package.path = package.path
	.. ";../?.lua"
	.. ";../expaghetti/?.lua"
----------------------------------------------------------------------------------------------------
local next = next
local pcall = pcall
local strformat = string.format
----------------------------------------------------------------------------------------------------
local parser = require("../expaghetti/parser")
----------------------------------------------------------------------------------------------------
local compareTables = require("./assertion").compareTables
----------------------------------------------------------------------------------------------------
local cases = {
	literal = require("./cases/literal")
}

for caseName, caseData in next, cases do
	for caseIndex, caseObj in next, caseData do
		print(strformat("Checking generated tree for the regex %q", caseObj.regex))

		local tree = assert(parser(caseObj.regex),
			strformat("Failure to parse regex %s", caseObj.regex))

		print("\t", pcall(compareTables, caseObj.parsed, tree))
	end
end