package.path = package.path
	.. ";../?.lua"
	.. ";../expaghetti/?.lua"
----------------------------------------------------------------------------------------------------
local next = next
local pcall = pcall
local strformat = string.format
local tostring = tostring
----------------------------------------------------------------------------------------------------
local parser = require("../expaghetti/parser")
----------------------------------------------------------------------------------------------------
local compareTables = require("./assertion").compareTables
----------------------------------------------------------------------------------------------------
local cases = {
	"literal",
	"escaped",
	"character_class",
	"special_escaped",
	"any",
	"set",
	"delimiter",
	"group",
	"quantifier",
	"alternate",
	"flag"
}

local success, error = 0, 0
for case = 1, #cases do
	case = cases[case]

	print(strformat("\n\n############### Testing cases of %q ###############", case))
	for caseIndex, caseObj in next, require("./cases/" .. case) do
		print(strformat("Checking generated tree for the regex %q", caseObj.regex))

		local hasParsed, tree, errorMessage = pcall(parser, caseObj.regex, caseObj.flags)

		if not tree then
			if caseObj.errorMessage then
				if errorMessage ~= caseObj.errorMessage then
					print("\tF", "\t", strformat(
						"Expected error message\n\t\t\t\t\t%q,\n\t\t\t\tbut got\n\t\t\t\t\t%q",
						caseObj.errorMessage, tostring(errorMessage)
					))
					error = error + 1
				else
					print("\t.", "\t", true)
					success = success + 1
				end
			else
				print("\tF", "\t", strformat(
					"Failure to parse regex %q:\n\t\t\t\t\t%s",
					caseObj.regex, errorMessage
				))
				error = error + 1
			end
		else
			if caseObj.errorMessage then
				print("\tF", "\t", "Error message expected, got valid tree.")
				error = error + 1
			else
				local hasCompared, errorMessage = pcall(compareTables, caseObj.parsed, tree)
				if hasCompared then
					print("\t.", "\t", true)
					success = success + 1
				else
					print("\tF", "\t", errorMessage)
					error = error + 1
				end
			end
		end
	end
end

print("\n\n------------------------------------")
print(strformat("Success : %03d\nError : %03d", success, error))
print("------------------------------------")