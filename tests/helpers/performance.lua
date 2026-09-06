--[[ Globals ]]--
local collectgarbage = collectgarbage
local os_clock = os.clock
local print = print
local string_format = string.format

--[[ Module ]]--
local originalPrint = print

local foo = function() end

local formatKB = function(kilobytes)
	if kilobytes > 1024 then
		return string_format("%.2f MB", kilobytes / 1024)
	end

	return string_format("%.2f KB", kilobytes)
end

return function(testFunction, options)
	options = options or {}

	local runs = options.runs or 1
	local collect = options.collectGarbage ~= false

	-- Default: if benchmarking multiple runs, silence output after the first run.
	local mutePrint = options.mutePrint
	if mutePrint == nil then
		mutePrint = runs > 1
	end

	if collect then
		collectgarbage("collect")
	end

	local initialMemory = collectgarbage("count")
	local peakMemory = initialMemory

	local cpuStart = os_clock()

	for runIndex = 1, runs do
		if mutePrint and runIndex == 2 then
			_G.print = foo
		end

		testFunction(runIndex)

		local current = collectgarbage("count")
		if current > peakMemory then
			peakMemory = current
		end
	end

	_G.print = originalPrint

	local cpuElapsed = os_clock() - cpuStart

	if collect then
		collectgarbage("collect")
	end

	local finalMemory = collectgarbage("count")

	print("")
	print("========== Performance ==========")
	print(string_format("Runs		: %d", runs))
	print(string_format("CPU Time	: %.6f sec", cpuElapsed))
	print(string_format("Avg / Run	: %.6f ms", cpuElapsed * 1000 / runs))
	print(string_format("Memory Δ	: %s", formatKB(finalMemory - initialMemory)))
	print(string_format("Memory 	: %s", formatKB(peakMemory - initialMemory)))
	print("=================================")
end