local performance = {}

local originalPrint = print
local function noop() end

local function formatKB(kb)
	if kb > 1024 then
		return string.format("%.2f MB", kb / 1024)
	end

	return string.format("%.2f KB", kb)
end

function performance.logPerformanceAtTheEnd(fn, options)
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

	local cpuStart = os.clock()

	for i = 1, runs do
		if mutePrint and i == 2 then
			print = noop
		end

		fn(i)

		local current = collectgarbage("count")
		if current > peakMemory then
			peakMemory = current
		end
	end

	print = originalPrint

	local cpuElapsed = os.clock() - cpuStart

	if collect then
		collectgarbage("collect")
	end

	local finalMemory = collectgarbage("count")

	print("")
	print("========== Performance ==========")
	print(string.format("Runs		: %d", runs))
	print(string.format("CPU Time	: %.6f sec", cpuElapsed))
	print(string.format("Avg / Run	: %.6f ms", cpuElapsed * 1000 / runs))
	print(string.format("Memory Δ	: %s", formatKB(finalMemory - initialMemory)))
	print(string.format("Memory 	: %s", formatKB(peakMemory - initialMemory)))
	print("=================================")
end

return performance