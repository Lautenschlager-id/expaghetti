package.path = package.path .. ";../?.lua;../expaghetti/?.lua"

--[[ Globals ]]--
local error = error
local next = next
local pcall = pcall
local string_format = string.format
local table_concat = table.concat
local tostring = tostring

--[[ Dependencies ]]--
local parser = require("expaghetti.parser.init")
local compareTables = require("tests.helpers.compareTables")
local prettyPrint = require("tests.helpers.prettyPrint")
local performance = require("tests.helpers.performance")
local testRunner = require("tests.helpers.testRunner")

--[[ Aliases ]]--
local describe = testRunner.describe
local it = testRunner.it
local assert = testRunner.assert

--[[ Module ]]--
local cases = {
	"literal",
	"escaped",
	"characterClass",

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
	"frontier",
}

performance(function()

print("Running parser tests...")

for case = 1, #cases do
	local caseName = cases[case]

	describe("Testing cases of " .. caseName, function()
		for caseIndex, caseObj in next, require("tests.parserCases." .. caseName) do
			caseObj.flags = caseObj.flags or {} 

			local flagKeys = {}
			for flag in next, caseObj.flags do
				flagKeys[#flagKeys + 1] = flag
			end
			local flagSuffix = ""
			if next(caseObj.flags) then
				flagSuffix = string_format(" with flags %q", table_concat(flagKeys, ", "))
			end
			local name = string_format("Checking generated tree for the regex %q%s", caseObj.regex, flagSuffix)

			it(name, function()
				-- if it crashes, it() catches it natively
				local tree, errorMessage = parser(caseObj.regex, caseObj.flags)

				if not tree then
					if caseObj.errorMessage then
						assert.equal(errorMessage, caseObj.errorMessage, "Expected error message mismatch")
					else
						error(string_format("Failure to parse regex %q:\n\t\t\t\t\t%s", caseObj.regex, tostring(errorMessage)))
					end
				else
					if caseObj.errorMessage then
						error("Error message expected, got valid tree.")
					else
						tree._metadata = nil
						compareTables(caseObj.parsed, tree)
					end
				end
			end)
		end
	end)
end

testRunner.run()

end, {
	runs = 1
})