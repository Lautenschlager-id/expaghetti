local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local queueFactory = require("handler/queue")
local setFactory = require("handler/set")
local groupFactory = require("handler/group")
local quantifierFactory = require("handler/quantifier")
local alternateFactory = require("handler/alternate")

local magicSet = util.createSet(util.toArray(enum.magic))

local strlower = string.lower
local tblconcat = table.concat

local cache = { }

local parse
parse = function(regex, flags, options)
	if not regex then return end

	local flagsCode = (flags and util.flagsCode(flags) or '')
	local flagsSet = (flags and util.createSet(flags) or { })

	local optionsCode = (options and util.flagsCode(options) or '')
	local optionsSet = (options and util.createSet(options) or { })

	flagsCode = flagsCode .. optionsCode

	local rawRegex, len
	if type(regex) == "string" then
		if cache[regex] and cache[regex][flagsCode] then
			return cache[regex][flagsCode]
		else
			rawRegex = regex
			if flagsSet[enum.flag.unicode] then
				regex, len = utf8.create(regex)
			else
				regex, len = util.strToArr(regex)
			end
		end
	else
		rawRegex = tblconcat(regex.tree or regex)
		if cache[rawRegex] and cache[rawRegex][flagsCode] then
			return cache[rawRegex][flagsCode]
		end
		len = #regex
	end

	local isInsensitive = not not flagsSet[enum.flag.insensitive]

	local lastChar, nextChar
	local isEscaped, isMagic, char = false, false
	local i, nextI = 1
	local tmpGroup, tmpNum

	local queueHandler = queueFactory:new()
	local setHandler = setFactory:new()
	local groupHandler = groupFactory:new()
	local quantifierHandler = quantifierFactory:new()
	local alternateHandler = alternateFactory:new()

	-- Builds the regex
	while i <= len do
		nextI = 1

		repeat
			char = regex[i]

			if char == enum.magic.ESCAPE and not isEscaped then
				if i == len then
					--error("malformed pattern (ends with '%')")
				end
				isEscaped = true
				break
			end

			nextChar = regex[i + 1]
			isMagic = magicSet[char]

			if isEscaped and not optionsSet[enum.option.DISABLE_ESCAPE] then
				isEscaped = groupHandler.isOpen
				if not isEscaped then -- if it's open then go for literal
					if enum.class[char] then
						char = enum.class[char] -- set
					elseif char == enum.specialClass.controlChar then -- %c
						if not nextChar then
							--error("Missing %c parameter")
						end
						char = util.charToCtrlChar(nextChar) -- %cI = \009
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
					elseif char == enum.specialClass.boundary and not optionsSet[enum.option.DISABLE_ANCHOR] then
						char = enum.anchor.BOUNDARY
					elseif char == enum.specialClass.notBoundary and not optionsSet[enum.option.DISABLE_ANCHOR] then
						char = enum.anchor.NOTBOUNDARY
					elseif not setHandler.isOpen and not optionsSet[enum.option.DISABLE_GROUP] then
						tmpNum = tonumber(char)
						if tmpNum then -- %1 (group reference)
							-- What to do with %0?
							char = { type = "capture_reference", value = tmpNum }
						end
					end
				end
			elseif isMagic and not optionsSet[enum.option.DISABLE_MAGIC] then -- and not escaped
				if char == enum.magic.OPEN_GROUP and not setHandler.isOpen and not optionsSet[enum.option.DISABLE_GROUP] then
					groupHandler.nest = groupHandler.nest + 1
					if groupHandler.nest == 1 then
						groupHandler:open()
						break
					end
				elseif char == enum.magic.CLOSE_GROUP and not setHandler.isOpen and not optionsSet[enum.option.DISABLE_GROUP] then
					groupHandler.nest = groupHandler.nest - 1
					if groupHandler.nest == 0 then
						if groupHandler:hasValue() then -- normal
							tmpGroup = groupHandler:get()
							tmpGroup.tree = parse(tmpGroup.tree, flags, options)
							queueHandler:push(tmpGroup)
							tmpGroup = nil -- don't trust lua's gc
						else -- (), pos capture
							if not groupHandler._effect then -- not (?:!=<)
								queueHandler:push({ type = "position_capture" })
							end
						end
						groupHandler:close()
						break
					end
				elseif not groupHandler.isOpen then -- It gets handled later
					if char == enum.magic.OPEN_SET and not optionsSet[enum.option.DISABLE_SET] then
						if not setHandler.isOpen then -- sets can have [ ] too
							setHandler:open()
							break
						end
					elseif char == enum.magic.CLOSE_SET and not optionsSet[enum.option.DISABLE_SET] then
						if setHandler.isOpen and setHandler:hasValue() then -- sets can have ] if it's right after the opening [
							queueHandler:push(setHandler:get()) -- set (Can it detect that it is a set or has to be explict?)
							setHandler:close()
							break
						end
					elseif not setHandler.isOpen then
						if char == enum.magic.OPEN_QUANTIFIER and not optionsSet[enum.option.DISABLE_QUANTFIFIER] then
							quantifierHandler:open()
							break
						elseif char == enum.magic.CLOSE_QUANTIFIER and not optionsSet[enum.option.DISABLE_QUANTFIFIER] then
							queueHandler:push(quantifierHandler:get()) -- quantifier
							quantifierHandler:close()
							break
						elseif char == enum.magic.ANY then
							char = enum.specialClass.any
						elseif char == enum.magic.LAZY and (lastChar == enum.magic.ZERO_OR_MORE or lastChar == enum.magic.ONE_OR_MORE or lastChar == enum.magic.ZERO_OR_ONE) then -- lazy of +, *, ?
							break -- Not linking with the if below because its flexible enough to have a different representative character.
						elseif char == enum.magic.ZERO_OR_MORE or char == enum.magic.ONE_OR_MORE or char == enum.magic.ZERO_OR_ONE then -- +, *, ?
							quantifierHandler:open():push((char == enum.magic.ONE_OR_MORE and 1 or 0)):isLazy(nextChar == enum.magic.LAZY)
							if char == enum.magic.ZERO_OR_ONE then
								quantifierHandler:next():push(1)
							end
							queueHandler:push(quantifierHandler:get())
							quantifierHandler:close()
							break
						elseif char == enum.magic.ALTERNATE and not optionsSet[enum.option.DISABLE_ALTERNATE] then
							alternateHandler:push(queueHandler._index)
							break
						elseif not optionsSet[enum.option.DISABLE_ANCHOR] then
							if char == enum.magic.BEGINNING then
								char = enum.anchor.BEGINNING
							elseif char == enum.magic.END then
								char = enum.anchor.END
							end
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
					if isEscaped then
						isEscaped = false
						groupHandler:push(enum.magic.ESCAPE)
					end
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
				queueHandler:push((isInsensitive and type(char) == "string") and strlower(char) or char)
			end
		until true

		lastChar = char
		i = i + nextI
	end

	local tree
	if alternateHandler:exists() then
		-- Builds the or object
		tree = { alternateHandler:build(queueHandler) }
	else
		tree = queueHandler
	end

	if not cache[rawRegex] then
		cache[rawRegex] = { }
	end
	cache[rawRegex][flagsCode] = tree

	return tree
end

return parse