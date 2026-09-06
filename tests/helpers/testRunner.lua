--[[ Globals ]]--
local error = error
local next = next
local pcall = pcall
local string_find = string.find
local string_format = string.format
local tostring = tostring
local type = type

--[[ Module ]]--
local suites = {}
local currentSuite = nil

local assertAPI = {}
assertAPI.native = assert

local deepEqual
deepEqual = function(actualVal, expectedVal, path)
	path = path or "root"
	if type(actualVal) ~= type(expectedVal) then
		error("Type mismatch at " .. path .. ": expected " .. type(expectedVal) .. " but got " .. type(actualVal), 2)
	end
	if type(actualVal) == "table" then
		for key, value in next, actualVal do
			deepEqual(value, expectedVal[key], path .. "." .. tostring(key))
		end
		for key, _ in next, expectedVal do
			if actualVal[key] == nil then
				error("Missing key at " .. path .. ": " .. tostring(key), 2)
			end
		end
	else
		if actualVal ~= expectedVal then
			error("Mismatch at " .. path .. ": expected " .. tostring(expectedVal) .. " but got " .. tostring(actualVal), 2)
		end
	end
end

assertAPI.equal = function(actual, expected, msg)
	if actual ~= expected then
		error(msg or string_format("Expected %q but got %q", tostring(expected), tostring(actual)), 2)
	end
end

assertAPI.deepEqual = deepEqual

assertAPI.isTrue = function(actual, msg)
	if actual ~= true then
		error(msg or "Expected true but got " .. tostring(actual), 2)
	end
end

assertAPI.isFalse = function(actual, msg)
	if actual ~= false then
		error(msg or "Expected false but got " .. tostring(actual), 2)
	end
end

assertAPI.isNil = function(actual, msg)
	if actual ~= nil then
		error(msg or "Expected nil but got " .. tostring(actual), 2)
	end
end

assertAPI.isNotNil = function(actual, msg)
	if actual == nil then
		error(msg or "Expected not nil", 2)
	end
end

assertAPI.hasError = function(fn, expectedMsgPart)
	local success, err = pcall(fn)
	if success then
		error("Expected error but function succeeded", 2)
	end
	if expectedMsgPart and type(err) == "string" and not string_find(err, expectedMsgPart, 1, true) then
		error(string_format("Expected error containing %q, but got %q", expectedMsgPart, tostring(err)), 2)
	end
end

--[[ Module ]]--
local testRunner = {}
testRunner.assert = assertAPI

testRunner.describe = function(name, fn)
	local suite = { name = string_format("%q", name), tests = {} }
	suites[#suites + 1] = suite
	local prevSuite = currentSuite
	currentSuite = suite
	fn()
	currentSuite = prevSuite
end

testRunner.it = function(name, fn)
	if not currentSuite then
		error("it() must be called inside a describe()")
	end
	currentSuite.tests[#currentSuite.tests + 1] = { name = string_format("%q", name), fn = fn }
end

testRunner.run = function()
	local totalPassed = 0
	local totalFailed = 0
	local failedTests = {}

	for suiteIndex = 1, #suites do
		local suite = suites[suiteIndex]
		print("\n" .. suite.name)
		for testIndex = 1, #suite.tests do
			local test = suite.tests[testIndex]
			local success, err = pcall(test.fn)
			if success then
				print("  [PASS] " .. test.name)
				totalPassed = totalPassed + 1
			else
				print("  [FAIL] " .. test.name)
				print("    " .. tostring(err))
				totalFailed = totalFailed + 1
				failedTests[totalFailed] = { suite = suite.name, test = test.name, err = err }
			end
		end
	end

	print("\n========== Test Summary ==========")
	print("Passed: " .. totalPassed)
	print("Failed: " .. totalFailed)
	if totalFailed > 0 then
		print("\nFailed Tests:")
		for failedIndex = 1, #failedTests do
			local ft = failedTests[failedIndex]
			print(string_format("  - %s > %s: %s", ft.suite, ft.test, tostring(ft.err)))
		end
	end
	print("==================================")
	testRunner.clear()
end

testRunner.clear = function()
	suites = {}
	currentSuite = nil
end

return testRunner
