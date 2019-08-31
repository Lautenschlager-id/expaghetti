local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local parse = require("parser")
local setFactory = require("handler/set")

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

	local matchHandler = matchFactory:new()

	local currentPosition, obj, char, tmpChar = 1

	for e = 1, regex._index do
		obj = regex:get(e)
		char = str[currentPosition]

		if type(obj) == "string" then
			if obj ~= char then return end
			--tmpChar = char
			currentPosition = currentPosition + 1
		else
			if obj.type == "anchor" then
				if obj == enum.anchor.BEGINNING then
					if currentPosition ~= 1 then return end -- add multiline
				elseif obj == enum.anchor.END then
					if currentPosition ~= len + 1 then return end -- add multiline
				elseif obj == enum.anchor.BOUNDARY then -- todo
				elseif obj == enum.anchor.NOTBOUNDARY then -- todo
				end
			elseif obj.type == "position_capture" then
				tmpChar = currentPosition
			elseif obj.type == "set" then
				if not setFactory.match(obj, str[currentPosition], isInsensitive) then return end
				--tmpChar = char
				currentPosition = currentPosition + 1
			end
		end

		if tmpChar then
			matchHandler:push(tmpChar)
			tmpChar = nil
		end
	end

	if matchCounter == 0 then
		return rawStr
	end
	return util.unpack(matchHandler:get())
end

return match