local utf8 = require("utf8")
local util = require("util")
local enum = require("enum")

local setFactory = require("handler/set")

local magicSet = util.createSet(util.toArray(enum.magic))

local match = function(str, regex, isUTF8)
	local strLen, regexLen
	if isUTF8 then
		str, strLen = utf8(str)
		regex, regexLen = utf8(regex)
	else
		str, strLen = util.strToTbl(str)
		regex, regexLen = util.strToTbl(regex)
	end

	local lastChar, nextChar
	local isEscaped, isMagic, char
	local skip = false

	local setHandler = setFactory:new()

	for i = 1, regexLen do
		repeat
			if skip then
				skip = false
				break
			end

			char = regex[i]
			nextChar = regex[i + 1]

			isMagic = magicSet[char]
			isEscaped = lastChar and lastChar == '%'

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
	end
end

-- Debugging
match("abacate", "[abc][^m][0-9a][a-zA-Z69]", false)