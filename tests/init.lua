package.path = package.path
	.. ";../?.lua"
	.. ";../expaghetti/?.lua"
----------------------------------------------------------------------------------------------------
local next = next
local pcall = pcall
local strformat = string.format
local tostring = tostring
----------------------------------------------------------------------------------------------------
local parser = require("parser.init")
----------------------------------------------------------------------------------------------------
local compareTables = require("./assertion").compareTables
local prettyPrint = require("./prettyPrint")
----------------------------------------------------------------------------------------------------
local performance = require("performance")
----------------------------------------------------------------------------------------------------
local cases = {
	"literal",
	"escaped",
	"characterClass",
	"specialEscaped",
	"any",
	"set",
	"delimiter",

	"group",
	"alternate",
	"quantifier",

	"flagCaseInsensitive",
	"flagUnicode",
	"flagMultiline",
	"flagDotall",
	"flagNoAutoCapture",
	"flagCombined",

	"comment",
	"positionCapture",
	"backreference",
	"recursion",
	"balanced",
	"boundary",
}

local breakOnFirstError = true

performance.logPerformanceAtTheEnd(function()

local success, error, stop = 0, 0
for case = 1, #cases do
	case = cases[case]

	print(strformat("\n\n############### Testing cases of %q ###############", case))
	for caseIndex, caseObj in next, require("./cases/" .. case) do
		local flagKeys = {}
		for flag in next, caseObj.flags or {} do
			flagKeys[#flagKeys + 1] = flag
		end
		print(strformat("Checking generated tree for the regex %q%s", caseObj.regex, not caseObj.flags and "" or string.format(" with flags %q", table.concat(flagKeys, ", "))))

		local hasParsed, tree, errorMessage = pcall(parser, caseObj.regex, caseObj.flags)

		if not hasParsed then
			print("\tF", "\t", "Parser crashed: " .. tostring(tree))
			error = error + 1
		elseif not tree then
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
				tree._metadata = nil
				local hasCompared, errorMessage = pcall(compareTables, caseObj.parsed, tree)
				if hasCompared then
					print("\t.", "\t", true)
					success = success + 1
				else
					print("\tF", "\t", errorMessage)
					print(prettyPrint(tree, true))
					error = error + 1
				end
			end
		end

		if error > 0 and breakOnFirstError then
			stop = true
			break
		end
	end

	if stop then
		break
	end
end

print("\n\n------------------------------------")
print(strformat("Success : %03d\nError : %03d", success, error))
print("------------------------------------")

end, {
	runs = 1
})