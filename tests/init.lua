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
	literal = require("./cases/literal")
}

for caseName, caseData in next, cases do
	for caseIndex, caseObj in next, caseData do
		print(strformat("Checking generated tree for the regex %q", caseObj.regex))

		local hasParsed, tree, errorMessage = pcall(parser, caseObj.regex)
		if not tree then
			if caseObj.errorMessage then
				if errorMessage ~= caseObj.errorMessage then
					print("\tF", "\t", strformat(
						"Expected error message\n\t\t\t\t\t%q,\n\t\t\t\tbut got\n\t\t\t\t\t%q",
						caseObj.errorMessage, tostring(errorMessage)
					))
				else
					print("\t.", "\t", true)
				end
			else
				print("\tF", "\t", strformat(
					"Failure to parse regex %q:\n\t\t\t\t\t%s",
					caseObj.regex, errorMessage
				))
			end
		else
			if caseObj.errorMessage then
				print("\tF", "\t", "Error message expected, got valid tree.")
			else
				local hasCompared, errorMessage = pcall(compareTables, caseObj.parsed, tree)
				if hasCompared then
					print("\t.", "\t", true)
				else
					print("\tF", "\t", errorMessage)
				end
			end
		end
	end
end