local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local queueFactory = require("queue")
local setFactory = require("handler/set")
local groupFactory = require("handler/group")
local quantifierFactory = require("handler/quantifier")
local operatorFactory = require("handler/operator")

local strbyte = string.byte
local strchar = string.char
local strupper = string.upper

local magicSet = util.createSet(util.toArray(enum.magic))

local charToCtrlChar
do
	local A, Z = strbyte('AZ', 1, 2)
	local Aminus = A - 1

	charToCtrlChar = function(char)
		local tmp = strbyte(strupper(char))
		if tmp >= A and tmp <= Z then -- A to Z
			return strchar(tmp - Aminus)
		end
	end
end

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

	local queueHandler = queueFactory:new()
	local setHandler = setFactory:new()
	local groupHandler = groupFactory:new()
	local quantifierHandler = quantifierFactory:new()
	local operatorHandler = operatorFactory:new()

	-- Builds the regex
	i = 1
	lastChar = nil
	while i <= len do
		repeat
			char = regex[i]
			nextChar = regex[i + 1]

			isMagic = magicSet[char]
			isEscaped = lastChar and lastChar == enum.magic.ESCAPE

			if isEscaped then
				if enum.class[char] then
					char = enum.class[char] -- set
				elseif char == enum.specialClass.controlChar then
					if not nextChar then
						--error("Missing %c parameter")
					end
					char = charToCtrlChar(nextChar) -- %cI = \009
				end
			elseif isMagic then -- and not escaped
				if char == enum.magic.OPEN_GROUP then
					groupHandler:open() -- Is it ready for nested groups?
					break
				elseif char == enum.magic.CLOSE_GROUP then
					queueHandler:push(buildRegex(groupHandler:get(), isUTF8)) -- queue (Should the queue accept queues?)
					groupHandler:close()
					break
				elseif not groupHandler.isOpen then -- It gets handled later
					if char == enum.magic.OPEN_SET then
						setHandler:open()
						break
					elseif char == enum.magic.CLOSE_SET then
						queueHandler:push(setHandler:get()) -- set (Can it detect that it is a set or has to be explict?)
						setHandler:close()
						break
					elseif not setHandler.isOpen then
						if char == enum.magic.OPEN_QUANTIFIER then
							quantifierHandler:open()
							break
						elseif char == enum.magic.CLOSE_QUANTIFIER then
							queueHandler:push(quantifierHandler:get()) -- quantifier
							quantifierHandler:close()
							break
						elseif char == enum.magic.ANY then
							char = enum.specialClass.any
						elseif char == enum.magic.ONE_OR_MORE or char == enum.magic.ZERO_OR_MORE or (char == enum.magic.OPTIONAL and (lastChar ~= enum.magic.ONE_OR_MORE and lastChar ~= enum.magic.ZERO_OR_MORE)) then -- + or * or exp?, not lazy
							queueHandler:push(operatorHandler:new(char, (nextChar == enum.magic.LAZY)))
							break
						elseif char == enum.magic.LAZY and (lastChar == enum.magic.ONE_OR_MORE or lastChar == enum.magic.ZERO_OR_MORE) then -- lazy of +, *
							break -- Handled above
						end
					end
				end
			end

			if groupHandler.isOpen then
				if lastChar == enum.magic.OPEN_GROUP and char == enum.magic.GROUP_BEHAVIOR then -- (?
					groupHandler.watchEffect = true
				elseif groupHandler.watchEffect then
					if char == enum.magic.LOOKBEHIND then -- (?<=), (?<!)
						groupHandler:setBehind()
					else
						if char == enum.magic.NON_CAPTURING_GROUP or char == enum.magic.POSITIVE_LOOKAHEAD or char == enum.magic.NEGATIVE_LOOKAHEAD then -- (?:), (?=), (?!)
							groupHandler:setEffect(char)
						end
						groupHandler.watchEffect = false
					end
				else
					groupHandler:push(char)
				end
			elseif setHandler.isOpen then
				if char == enum.magic.NEGATED_SET then -- [^]
					setHandler:negate()
				elseif lastChar == enum.magic.RANGE or nextChar == enum.magic.RANGE then -- l-n ↓
					break -- handled in the next condition
				elseif char == enum.magic.RANGE then -- l-n
					setHandler:range(lastChar, nextChar)
				else
					setHandler:push(char)
				end
			elseif quantifierHandler.isOpen then
				if char == enum.magic.QUANTIFIER_SEPARATOR then -- x,y
					quantifierHandler:next()
					break
				else
					quantifierHandler:push(char)
				end
			else
				queueHandler:push(char)
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
buildRegex("abacate{,2}", false)