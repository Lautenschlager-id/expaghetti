local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local parse = require("parser")

local setFactory = require("handler/set")
local quantifierFactory = require("handler/quantifier")

local matchFactory = require("handler/match")

local tblconcat = table.concat

local match
local match = function(str, regex, flags, options)
	regex = parse(regex, flags, options)
	
	local flagsSet = (flags and util.createSet(flags) or { })
	local isInsensitive = not not flagsSet[enum.flag.insensitive]

	local rawStr, len
	if type(str) == "string" then
		rawStr = rawStr
		if flagsSet[enum.flag.unicode] then
			str, len = utf8.create(str)
		else
			str, len = util.strToArr(str)
		end
	else
		rawStr = tblconcat(str)
		len = #str
	end

	local obj, char
	local i, currentPosition, nextI = 1, 1
	local matchChar, tmpRepeat, tmpRepeatCount, tmpChar

	local matchHandler = matchFactory:new()

	while i <= regex._index do
		nextI = 1

		repeat
			obj = regex:get(i)
			char = str[currentPosition]

			if type(obj) == "string" then
				if not char or obj ~= char and (not isInsensitive or (obj ~= util.reverseCase(char))) then return end
				--matchChar = char
				currentPosition = currentPosition + 1
			else
				if obj.type == "anchor" then
					if obj == enum.anchor.BEGINNING then
						if currentPosition ~= 1 then return end -- add multiline
					elseif obj == enum.anchor.END then
						if currentPosition ~= len + 1 then return end -- add multiline
					elseif obj == enum.anchor.BOUNDARY then
						-- TODO
					elseif obj == enum.anchor.NOTBOUNDARY then
						-- TODO
					end
				elseif obj.type == "position_capture" then
					matchChar = currentPosition
				else
					if not char then return end
					if obj.type == "set" then
						if not setFactory.match(obj, char, isInsensitive) then return end
						--matchChar = char
						currentPosition = currentPosition + 1
					elseif obj.type == "quantifier" then
						tmpRepeat = regex:get(i + 1)
						tmpRepeatCount = currentPosition
						tmpChar = char

						repeat
							--if not match(tmpChar, tmpRepeat)
							if tmpChar ~= tmpRepeat then break end -- literal char only

							tmpRepeatCount = tmpRepeatCount + 1
							tmpChar = str[tmpRepeatCount]
						until false

						currentPosition, tmpRepeatCount = tmpRepeatCount, (tmpRepeatCount - currentPosition)

						if (quantifierFactory.isConst(obj) and tmpRepeatCount ~= obj[1]) or (obj[1] and tmpRepeatCount < obj[1]) or (obj[2] and tmpRepeatCount > obj[2]) then return end

						nextI = 2
					elseif obj.type == "group" then
						if not obj.effect then
							matchChar = match(str, obj.tree, flags, options)
							-- TODO: add to %reference
							if not matchChar then return end
						elseif obj.effect == enum.magic.NON_CAPTURING_GROUP then
							if not match(str, obj.tree, flags, options) then return end
						else
							-- TODO
						end
					elseif obj.type == "alternate" then
						-- TODO
					end
				end	
			end

			if matchChar then
				matchHandler:push(matchChar)
				matchChar = nil
			end
		until true

		i = i + nextI
	end

	if matchCounter == 0 then
		return rawStr -- Assuming it works as ^exp$. (waiting for the matching system)
	end
	return util.unpack(matchHandler:get())
end

return match