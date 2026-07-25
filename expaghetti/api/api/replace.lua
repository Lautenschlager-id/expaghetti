--[[
    API: replace and gsub
]]

--[[ Globals ]]--
local string_byte = string.byte
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
local math_huge = math.huge
local math_max = math.max
local tostring = tostring
local type = type

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local ApiHelpers = require("helpers.api")
local matcher = require("matcher.init")
local parserReplacementTemplate = require("parser.replacement")

--[[ Enums ]]--
local ELEMENT_LITERAL = require("enums.elements").LITERAL

--[[ Aliases ]]--
local buildMatchObject = ApiHelpers.buildMatchObject
local compilePattern = ApiHelpers.compilePattern

local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrFunctionOrTable = Assertion.isStringOrFunctionOrTable
local AssertionIsStringOrTable = Assertion.isStringOrTable
local AssertionIsTable = Assertion.isTable

local prettyPrint = require("prettyPrint")

--[[ Module ]]--
local applyReplacementTemplate = function(tree, match)
	local segments = {}
	local segmentCount = 0

	for index = 1, tree._index do
		local element = tree[index]

		if element.type == ELEMENT_LITERAL then
			segmentCount = segmentCount + 1
			segments[segmentCount] = string_char(element.value)

		-- ELEMENT_BACKREFERENCE
		else
			local groupArray = match.groups[element.index]
			segmentCount = segmentCount + 1
			segments[segmentCount] = groupArray and groupArray[#groupArray].value or ""
		end
	end

	return table_concat(segments)
end

return function(pattern, targetString, replacement, flags, startPosition, config, maxOcurrences)
	AssertionIsStringOrTable(pattern, "pattern")
	AssertionIsString(targetString, "targetString")
	AssertionIsStringOrFunctionOrTable(replacement, "replacement")
	AssertionIsStringOrTable(flags, "flags", true)
	AssertionIsNumber(startPosition, "startPosition", true)
	AssertionIsTable(config, "config")
	AssertionIsNumber(maxOcurrences, "maxOcurrences", true)

	local tree, parsedFlags, errorMessage = compilePattern(pattern, flags, config)
	if errorMessage then
		return nil, errorMessage
	end

	maxOcurrences = maxOcurrences or math_huge

	local segments = {}
	local segmentCount = 0

	local currentIndex = (startPosition or 1) - 1

	local lastCopied = 0
	local replaceCount = 0
	local replacementType = type(replacement)
	local isStringReplacement, replacementTree = replacementType == "string"
	if isStringReplacement then
		replacementTree, errorMessage = parserReplacementTemplate(replacement, parsedFlags)
		if errorMessage then
			return nil, "Expaghetti Error: " .. errorMessage
		end
	end

	local targetLength = #targetString
	while currentIndex <= targetLength do
		if replaceCount >= maxOcurrences then
			break
		end
		
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)
		if not hasMatched then
			if matchStart then
				return nil, "Expaghetti Error: " .. matchStart
			end
			break
		end

		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

		local match = buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
		local matchValue = match.value
		if isStringReplacement then
			segmentCount = segmentCount + 1
			segments[segmentCount] = applyReplacementTemplate(replacementTree, match)
		elseif replacementType == "function" then
			local substitution = replacement(match)
			segmentCount = segmentCount + 1
			segments[segmentCount] = substitution ~= nil and tostring(substitution) or matchValue
		elseif replacementType == "table" then
			local lookupKey = matchValue
			local matchGroups = match.groups
			local firstGroup = matchGroups and matchGroups[1]
			if firstGroup then -- TO DO: Check if #firstGroup > 0 is necessary
				lookupKey = firstGroup[#firstGroup].value
			end
			
			local substitution = replacement[lookupKey]
			segmentCount = segmentCount + 1
			segments[segmentCount] = substitution ~= nil and tostring(substitution) or matchValue
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
	
	return table_concat(segments), replaceCount
end
