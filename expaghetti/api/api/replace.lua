--[[
	Replaces pattern matches within a target string.

	Supports replacement strings, callback functions, and lookup
	tables for flexible substitution.
]]

--[[ Globals ]]--
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
local math_huge = math.huge
local math_max = math.max
local tostring = tostring
local type = type

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local buildMatchObject = require("helpers.api").buildMatchObject
local matcher = require("matcher.init")
local parserReplacementTemplate = require("parser.replacement")

--[[ Enums ]]--
local ELEMENT_LITERAL = require("enums.elements").LITERAL

--[[ Aliases ]]--
local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrFunctionOrTable = Assertion.isStringOrFunctionOrTable
local AssertionIsStringOrTable = Assertion.isStringOrTable

--[[ Module ]]--

--- Evaluates a parsed replacement template for a match.
--- Produces the replacement string by resolving literals and
--- backreferences against the provided match.
---@param tree AST The parsed replacement template.
---@param match Match The match used to evaluate the template.
---@return string replacement The evaluated replacement string.
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

return function(config, compilePattern)
	--- Replaces pattern matches within a target string.
	--- Returns the resulting string together with the number of
	--- replacements performed.
	---@param pattern string|Pattern The pattern to search for.
	---@param targetString string The string to search.
	---@param replacement string|function|table The replacement specification.
	---@param flags string|table|nil Optional regular expression flags.
	---@param maxOccurrences integer|nil The maximum number of replacements to perform.
	---@param startPosition integer|nil The position at which to begin searching.
	---@return string|nil result The resulting string.
	---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
	return function(pattern, targetString, replacement, flags, maxOccurrences, startPosition)
		AssertionIsStringOrTable(pattern, "pattern")
		AssertionIsString(targetString, "targetString")
		AssertionIsStringOrFunctionOrTable(replacement, "replacement")
		AssertionIsStringOrTable(flags, "flags", true)
		AssertionIsNumber(startPosition, "startPosition", true)
		AssertionIsNumber(maxOccurrences, "maxOccurrences", true)

		local tree, parsedFlags, errorMessage = compilePattern(pattern, flags)
		if errorMessage then
			return nil, errorMessage
		end

		maxOccurrences = maxOccurrences or math_huge

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
				return nil, errorMessage
			end
		end

		local targetLength = #targetString
		while currentIndex <= targetLength do
			if replaceCount >= maxOccurrences then
				break
			end

			local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)
			if not hasMatched then
				if matchStart then
					return nil, matchStart
				end
				break
			end

			segmentCount = segmentCount + 1
			segments[segmentCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

			local match = buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
			local matchValue = match.value

			local substitution
			if isStringReplacement then
				substitution = applyReplacementTemplate(replacementTree, match)
			elseif replacementType == "function" then
				substitution = replacement(match)
				substitution = substitution and tostring(substitution)
			elseif replacementType == "table" then
				local lookupKey = matchValue
				local matchGroups = match.groups
				local firstGroup = matchGroups and matchGroups[1]
				if firstGroup then
					lookupKey = firstGroup[#firstGroup].value
				end

				substitution = replacement[lookupKey]
				substitution = substitution and tostring(substitution)
			end

			if substitution then
				segmentCount = segmentCount + 1
				segments[segmentCount] = substitution
				replaceCount = replaceCount + 1
			else
				segmentCount = segmentCount + 1
				segments[segmentCount] = matchValue
			end

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
end