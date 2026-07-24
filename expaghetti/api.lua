--[[
    Public API wrapper functions.
]]

local matcher = require("matcher.init")

local Api = {}

--[[ Flags Normalization ]]--
local function normalizeFlags(flags)
	if not flags then
		return {}
	end
	
	local flagType = type(flags)
	if flagType == "table" then
		local normalized = {}
		for k, v in pairs(flags) do
			if type(k) == "number" and type(v) == "string" then
				-- Array of flag chars: { "i", "m" }
				normalized[v] = true
			elseif type(k) == "string" and v then
				-- Dictionary of flag chars: { i = true, m = true }
				normalized[k] = true
			end
		end
		return normalized
	elseif flagType == "string" then
		-- String of flag chars: "imu"
		local normalized = {}
		for char in flags:gmatch(".") do
			normalized[char] = true
		end
		return normalized
	end
	
	return {}
end

Api.normalizeFlags = normalizeFlags

--[[ API Implementation ]]--

function Api.test(pattern, string, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local hasMatched = matcher(pattern, string, options, 0, config)
	return hasMatched == true
end

function Api.match(pattern, string, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local hasMatched, iniStr, endStr, matcherMetadata = matcher(pattern, string, options, 0, config)
	
	if hasMatched then
		local captures = {}
		if matcherMetadata and matcherMetadata.captureStarts then
			local starts = matcherMetadata.captureStarts
			local ends = matcherMetadata.captureEnds
			local counts = matcherMetadata.captureCounts
			
			for group, count in pairs(counts) do
				if count > 0 then
					local s = starts[group][count]
					local e = ends[group][count]
					captures[group] = string.sub(string, s, e)
				end
			end
		end
		return string.sub(string, iniStr, endStr), captures
	end
	return nil
end

function Api.matchAll(pattern, string, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local results = {}
	local currentIndex = 0
	local length = #string
	
	while currentIndex <= length do
		local hasMatched, iniStr, endStr, matcherMetadata = matcher(pattern, string, options, currentIndex, config)
		if not hasMatched then
			break
		end
		
		local captures = {}
		if matcherMetadata and matcherMetadata.captureStarts then
			local starts = matcherMetadata.captureStarts
			local ends = matcherMetadata.captureEnds
			local counts = matcherMetadata.captureCounts
			
			for group, count in pairs(counts) do
				if count > 0 then
					local s = starts[group][count]
					local e = ends[group][count]
					captures[group] = string.sub(string, s, e)
				end
			end
		end
		
		table.insert(results, {
			match = string.sub(string, iniStr, endStr),
			captures = captures,
			index = iniStr,
			lastIndex = endStr
		})
		
		if endStr < iniStr then
			-- Empty match
			currentIndex = math.max(currentIndex + 1, iniStr + 1)
		else
			currentIndex = endStr + 1
		end
	end
	
	return results
end

function Api.gmatch(pattern, string, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local currentIndex = 0
	local length = #string
	
	return function()
		if currentIndex > length then
			return nil
		end
		
		local hasMatched, iniStr, endStr, matcherMetadata = matcher(pattern, string, options, currentIndex, config)
		
		if hasMatched then
			if endStr < iniStr then
				currentIndex = math.max(currentIndex + 1, iniStr + 1)
			else
				currentIndex = endStr + 1
			end
			
			local captures = {}
			local numCaptures = 0
			if matcherMetadata and matcherMetadata.captureStarts then
				local starts = matcherMetadata.captureStarts
				local ends = matcherMetadata.captureEnds
				local counts = matcherMetadata.captureCounts
				
				for group, count in pairs(counts) do
					if count > 0 then
						local s = starts[group][count]
						local e = ends[group][count]
						captures[group] = string.sub(string, s, e)
						if type(group) == "number" then
							numCaptures = math.max(numCaptures, group)
						end
					end
				end
			end
			
			if numCaptures > 0 then
				local unpacked = {}
				for i = 1, numCaptures do
					unpacked[i] = captures[i]
				end
				return unpack(unpacked)
			else
				return string.sub(string, iniStr, endStr)
			end
		end
		
		return nil
	end
end

function Api.find(pattern, string, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local hasMatched, iniStr, endStr = matcher(pattern, string, options, 0, config)
	if hasMatched then
		return iniStr, endStr
	end
	return nil
end

function Api.replace(pattern, string, replacement, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local results = {}
	local currentIndex = 0
	local length = #string
	local lastCopied = 0
	local replaceCount = 0
	
	while currentIndex <= length do
		local hasMatched, iniStr, endStr, matcherMetadata = matcher(pattern, string, options, currentIndex, config)
		if not hasMatched then
			break
		end
		
		table.insert(results, string.sub(string, lastCopied + 1, iniStr - 1))
		
		local captures = {}
		if matcherMetadata and matcherMetadata.captureStarts then
			local starts = matcherMetadata.captureStarts
			local ends = matcherMetadata.captureEnds
			local counts = matcherMetadata.captureCounts
			for group, count in pairs(counts) do
				if count > 0 then
					captures[group] = string.sub(string, starts[group][count], ends[group][count])
				end
			end
		end
		
		if type(replacement) == "string" then
			local matchedStr = string.sub(string, iniStr, endStr)
			local sub = string.gsub(replacement, "%%(%d)", function(d)
				local n = tonumber(d)
				if n == 0 then return matchedStr end
				return captures[n] or ""
			end)
			table.insert(results, sub)
		elseif type(replacement) == "function" then
			local matchedStr = string.sub(string, iniStr, endStr)
			local sub = replacement(matchedStr, captures)
			if sub ~= nil then
				table.insert(results, tostring(sub))
			else
				table.insert(results, matchedStr)
			end
		elseif type(replacement) == "table" then
			local matchedStr = string.sub(string, iniStr, endStr)
			local key = captures[1] or matchedStr
			local sub = replacement[key]
			if sub ~= nil then
				table.insert(results, tostring(sub))
			else
				table.insert(results, matchedStr)
			end
		end
		
		replaceCount = replaceCount + 1
		
		lastCopied = math.max(lastCopied, endStr)
		if endStr < iniStr then
			currentIndex = math.max(currentIndex + 1, iniStr + 1)
		else
			currentIndex = endStr + 1
		end
	end
	
	table.insert(results, string.sub(string, lastCopied + 1))
	return table.concat(results), replaceCount
end

function Api.split(pattern, string, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end
	
	local results = {}
	local currentIndex = 0
	local length = #string
	local lastCopied = 0
	
	while currentIndex <= length do
		local hasMatched, iniStr, endStr = matcher(pattern, string, options, currentIndex, config)
		if not hasMatched then
			break
		end
		
		table.insert(results, string.sub(string, lastCopied + 1, iniStr - 1))
		
		lastCopied = math.max(lastCopied, endStr)
		if endStr < iniStr then
			currentIndex = math.max(currentIndex + 1, iniStr + 1)
		else
			currentIndex = endStr + 1
		end
	end
	
	table.insert(results, string.sub(string, lastCopied + 1))
	return results
end

return Api
