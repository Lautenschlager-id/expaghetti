local utf8 = require("utf8")
local util = require("util")
local enum = require("enum")

local setFactory = require("handler/set")

local magicSet = util.createSet(util.toArray(enum.magic))

local buildRegex = function(regex, isUTF8)
	local len
	if isUTF8 then
		regex, len = utf8(regex)
	else
		regex, len = util.strToTbl(regex)
	end

	local lastChar, nextChar
	local isEscaped, isMagic, char

	local setHandler = setFactory:new()

	-- Transforms character classes into sets
	local i, setLen = 1
	while i <= len do
		char = regex[i]

		isEscaped = lastChar and lastChar == enum.magic.ESCAPE
		if isEscaped and enum.class[char] then
			setLen = util.insert(regex, i - 1,  enum.class[char], 2) -- 'pos - 1' because of the magic escape
			i = i + setLen
			len = len + setLen
		end

		lastChar = char -- Could be handled when transformed but it's worthless
		i = i + 1
	end

	-- Builds the regex
	i = 1
	lastChar = nil
	while i <= len do
		repeat
			char = regex[i]
			nextChar = regex[i + 1]

			isMagic = magicSet[char]
			isEscaped = lastChar and lastChar == enum.magic.ESCAPE

			if not isEscaped and isMagic then
				if char == enum.magic.OPEN_SET then
					setHandler:open()
					break
				elseif char == enum.magic.CLOSE_SET then
					setHandler:close()
					break
				end
			end

			if setHandler.isOpen then
				if char == enum.magic.NEGATED_SET then
					setHandler:negate()
				elseif lastChar == enum.magic.RANGE or nextChar == enum.magic.RANGE then
					break -- handled in the next condition
				elseif char == enum.magic.RANGE then
					setHandler:range(lastChar, nextChar)
				else
					setHandler:push(char)
				end
			end
		until true
		lastChar = char
		i = i + 1
	end
end

local match = function(str, regex, isUTF8)
	regex = buildRegex(regex, isUTF8)

	local len
	if isUTF8 then
		str, len = utf8(str)
	else
		str, len = util.strToTbl(str)
	end

	-- TODO
end

-- Debugging
match("abacate", "oi%aoi%d%L%u", false)