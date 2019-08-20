local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local queueFactory = require("queue")
local setFactory = require("handler/set")
local groupFactory = require("handler/group")
local quantifierFactory = require("handler/quantifier")
local anchorFactory = require("handler/anchor")
local alternateFactory = require("handler/alternate")

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
			regex, len = utf8.create(regex)
		else
			regex, len = util.strToTbl(regex)
		end
	else
		len = #regex
	end

	local lastChar, nextChar
	local isEscaped, isMagic, char
	local i, nextI = 1

	local queueHandler = queueFactory:new()
	local setHandler = setFactory:new()
	local groupHandler = groupFactory:new()
	local quantifierHandler = quantifierFactory:new()
	local anchorHandler = anchorFactory:new()
	local alternateHandler = alternateFactory:new()

	-- Builds the regex
	while i <= len do
		nextI = 1

		repeat
			char = regex[i]
			nextChar = regex[i + 1]

			isMagic = magicSet[char]
			isEscaped = lastChar and lastChar == enum.magic.ESCAPE

			if isEscaped then
				if not groupHandler.isOpen then
					if enum.class[char] then
						char = enum.class[char] -- set
					elseif char == enum.specialClass.controlChar then -- %c
						if not nextChar then
							--error("Missing %c parameter")
						end
						char = charToCtrlChar(nextChar) -- %cI = \009
					elseif char == enum.specialClass.encode then -- %eFFFF = char(0xFFFF)
						if not regex[i + 4] then
							--error("Missing %e parameters")
						end

						for c = 1, 4 do
							if not setHandler.match(enum.class.h, regex[i + c]) then
								--error("Invalid %e #" .. c .. " parameter (not a hexadecimal value)")
							end
						end

						char = utf8.char(("0x" .. regex[i + 1] .. regex[i + 2] .. regex[i + 3] .. regex[i + 4]) * 1) -- Faster than tonumber_16 && table.concat
						nextI = 5 -- p{1}F{2}F{3}F{4}F{5}
					elseif not setHandler.isOpen then
						if setHandler.match(enum.class.d, char) then -- %1 (group reference)
							-- What to do with %0?
							char = { type = "capture_reference", value = (char * 1) }
						end
					end
				end
			elseif isMagic then -- and not escaped
				if char == enum.magic.ESCAPE then
					-- This is temporary. % needs a 100% rewrite for better control.
					if (enum.class[nextChar] or nextChar == enum.specialClass.controlChar or nextChar == enum.specialClass.encode or nextChar == char or
						(not setHandler.isOpen and setHandler.match(enum.class.d, nextChar))) then
						break
					end
				elseif char == enum.magic.OPEN_GROUP and not setHandler.isOpen then
					groupHandler:open() -- Is it ready for nested groups?
					break
				elseif char == enum.magic.CLOSE_GROUP and not setHandler.isOpen then
					if groupHandler:hasValue() then -- (), pos capture
						queueHandler:push(buildRegex(groupHandler:get(), isUTF8)) -- queue (Should the queue accept queues?)
					else
						if not groupHandler._effect then -- not (?:!=<)
							queueHandler:push({ type = "pos_capture" })
						end
					end
					groupHandler:close()
					break
				elseif not groupHandler.isOpen then -- It gets handled later
					if char == enum.magic.OPEN_SET then
						if not setHandler.isOpen then -- sets can have [ ] too
							setHandler:open()
							break
						end
					elseif char == enum.magic.CLOSE_SET then
						if setHandler.isOpen and setHandler:hasValue() then -- sets can have ] if it's right after the opening [
							queueHandler:push(setHandler:get()) -- set (Can it detect that it is a set or has to be explict?)
							setHandler:close()
							break
						end
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
						elseif char == enum.magic.ZERO_OR_MORE or char == enum.magic.ONE_OR_MORE then -- + or *
							quantifierHandler:open():push((char == enum.magic.ONE_OR_MORE and 1 or 0)):isLazy(nextChar == enum.magic.LAZY)
							queueHandler:push(quantifierHandler:get())
							quantifierHandler:close()
							break
						elseif char == enum.magic.LAZY and (lastChar == enum.magic.ZERO_OR_MORE or lastChar == enum.magic.ONE_OR_MORE) then -- lazy of +, *
							break -- Not linking with the if below because its flexible enough to have a different representative character.
						elseif char == enum.magic.ZERO_OR_ONE and not (lastChar == enum.magic.ZERO_OR_MORE or lastChar == enum.magic.ONE_OR_MORE) then -- exp?, not lazy
							quantifierHandler:open():push(0):next():push(1)
							queueHandler:push(quantifierHandler:get())
							quantifierHandler:close()
							break -- Handled above
						elseif char == enum.magic.BEGINNING then
							queueHandler:push(anchorHandler:push(char):get())
							break
						elseif char == enum.magic.END then
							queueHandler:push(anchorHandler:push(char):get())
							break
						elseif char == enum.magic.ALTERNATE then
							alternateHandler:push(queueHandler._index)
							break
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
					setHandler:range(lastChar, nextChar) -- it might be necessary to rework on ranges because of %e
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
		i = i + nextI
	end

	if alternateHandler:exists() then
		-- Builds the or object
		return alternateHandler:generate(queueHandler)
	end

	return queueHandler
end

local match = function(str, regex, isUTF8)
	regex = buildRegex(regex, isUTF8)

	local len
	if isUTF8 then
		str, len = utf8.create(str)
	else
		str, len = util.strToTbl(str)
	end

	-- TODO
end

-- Debugging
buildRegex("[ab%d]", false)