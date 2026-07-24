--[[
    API: replace and gsub
]]

local matcher = require("matcher.init")
local ESCAPE = require("enums.magic").ESCAPE

local string_byte = string.byte
local string_sub = string.sub
local table_concat = table.concat
local math_max = math.max
local type = type
local tostring = tostring

local BYTE_0 = string_byte('0')
local BYTE_9 = string_byte('9')
local BYTE_ESCAPE = string_byte(ESCAPE)

local function applyTemplate(template, matchObj)
	local templateLength = #template
	local segments = {}
	local segmentCount = 0
	local segmentStart = 1

	local templateIndex = 1
	while templateIndex <= templateLength do
		local currentByte = string_byte(template, templateIndex)

		if currentByte == BYTE_ESCAPE and templateIndex < templateLength then
			local nextByte = string_byte(template, templateIndex + 1)
			if nextByte >= BYTE_0 and nextByte <= BYTE_9 then
				if templateIndex > segmentStart then
					segmentCount = segmentCount + 1
					segments[segmentCount] = string_sub(template, segmentStart, templateIndex - 1)
				end

				local groupIndex = nextByte - BYTE_0
				segmentCount = segmentCount + 1
				if groupIndex == 0 then
					segments[segmentCount] = matchObj.value
				else
					local groupArr = matchObj.groups[groupIndex]
					if groupArr and #groupArr > 0 then
						segments[segmentCount] = groupArr[#groupArr].value
					else
						segments[segmentCount] = ""
					end
				end

				templateIndex = templateIndex + 2
				segmentStart = templateIndex
			else
				templateIndex = templateIndex + 1
			end
		else
			templateIndex = templateIndex + 1
		end
	end

	if segmentStart <= templateLength then
		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(template, segmentStart, templateLength)
	end

	return table_concat(segments, "", 1, segmentCount)
end

return function(utils)
	return function(pattern, targetString, replacement, flags, start, config, limit)
		local err
		pattern, flags, err = utils.compilePattern(pattern, flags, config)
		if err then return nil, err end
		local segments = {}
		local segmentCount = 0
		local currentIndex = (start or 1) - 1
		local targetLength = #targetString
		local lastCopied = 0
		local replaceCount = 0
		local replacementType = type(replacement)

		while currentIndex <= targetLength do
			if limit and replaceCount >= limit then
				break
			end
			
			local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, flags, currentIndex, config)
			if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
			if not hasMatched then
				break
			end

			segmentCount = segmentCount + 1
			segments[segmentCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

			local matchObj = utils.buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)

			if replacementType == "string" then
				segmentCount = segmentCount + 1
				segments[segmentCount] = applyTemplate(replacement, matchObj)
			elseif replacementType == "function" then
				local substitution = replacement(matchObj)
				segmentCount = segmentCount + 1
				if substitution ~= nil then
					segments[segmentCount] = tostring(substitution)
				else
					segments[segmentCount] = matchObj.value
				end
			elseif replacementType == "table" then
				local lookupKey = matchObj.value
				if matchObj.groups[1] and #matchObj.groups[1] > 0 then
					lookupKey = matchObj.groups[1][#matchObj.groups[1]].value
				end
				
				local substitution = replacement[lookupKey]
				segmentCount = segmentCount + 1
				if substitution ~= nil then
					segments[segmentCount] = tostring(substitution)
				else
					segments[segmentCount] = matchObj.value
				end
			end

			replaceCount = replaceCount + 1

			lastCopied = math_max(lastCopied, matchEnd)
			if matchEnd < matchStart then
				currentIndex = math_max(currentIndex + 1, matchStart)
			else
				currentIndex = matchEnd
			end
		end

		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(targetString, lastCopied + 1)
		
		return table_concat(segments, "", 1, segmentCount), replaceCount
	end
end
