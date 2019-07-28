local utf8 = require("utf8")
local util = require("util")
local enum = require("enum")

local setFactory = require("handler/set")
local groupFactory = require("handler/group")

local strbyte = string.byte
local strchar = string.char
local strupper = string.upper

local magicSet = util.createSet(util.toArray(enum.magic))

local buildRegex
buildRegex = function(regex, isUTF8)
	if not regex then return end

	local len
	if type(regex) == "string" then
		if isUTF8 then
			regex, len = utf8(regex)
		else
			regex, len = util.strToTbl(regex)
		end
	else
		len = #regex
	end

	local lastChar, nextChar
	local isEscaped, isMagic, char

	local setHandler = setFactory:new()
	local groupHandler = groupFactory:new()

	-- Transforms character classes into sets
	local i, setLen = 1
	while i <= len do
		char = regex[i]

		isEscaped = lastChar and lastChar == enum.magic.ESCAPE
		if isEscaped then
			if enum.class[char] then
				setLen = util.insert(regex, i - 1,  enum.class[char], 2) -- 'pos - 1' because of the magic escape
			elseif char == enum.specialClass.controlChar and regex[i + 1] then
				local tmp = strbyte(strupper(regex[i + 1]))
				if tmp >= 65 and tmp <= 90 then -- A to Z
					setLen = util.insert(regex, i - 1, { strchar(tmp - 64) }, 3) -- %cI = \009
					-- util.insert doesn't seem to work as expected when 'ignore' > '#tbl' and has to be reworked.
				end
			end
		end
		if setLen then
			i = i + setLen
			len = len + setLen
			setLen = nil
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
				if char == enum.magic.OPEN_SET and not groupHandler.isOpen then
					setHandler:open()
					break
				elseif char == enum.magic.CLOSE_SET and not groupHandler.isOpen then
					setHandler:get() -- TODO add to the task queue
					setHandler:close()
					break
				elseif char == enum.magic.OPEN_GROUP then
					groupHandler:open()
					break
				elseif char == enum.magic.CLOSE_GROUP then
					buildRegex(groupHandler:get(), isUTF8) -- TODO add to the task queue
					groupHandler:close()
					break
				end
			end

			if setHandler.isOpen then
				if char == enum.magic.NEGATED_SET then -- [^]
					setHandler:negate()
				elseif lastChar == enum.magic.RANGE or nextChar == enum.magic.RANGE then -- l-m ↓
					break -- handled in the next condition
				elseif char == enum.magic.RANGE then -- l-n
					setHandler:range(lastChar, nextChar)
				else
					setHandler:push(char)
				end
			elseif groupHandler.isOpen then
				if lastChar == enum.magic.OPEN_GROUP and char == enum.magic.GROUP_BEHAVIOR then -- (?
					groupHandler.watchEffect = true
				elseif groupHandler.watchEffect then
					if char == enum.magic.NON_CAPTURING_GROUP or char == enum.magic.POS_LOOKAHEAD or char == enum.magic.NEG_LOOKAHEAD then -- (?:), (?=), (?!)
						groupHandler:setEffect(char)
					end
					groupHandler.watchEffect = false
				else
					groupHandler:push(char)
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
buildRegex("a(?:bsdb[^a-z])a", false)