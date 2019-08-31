local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local parse = require("parser")

local match
local match = function(str, regex, flags, options)
	regex = parse(regex, flags, options)
	
	local flagsSet = (flags and util.createSet(flags) or { })
	
	local rawStr, len = str
	if flagsSet[enum.flag.unicode] then
		str, len = utf8.create(str)
	else
		str, len = util.strToArr(str)
	end

	local matches, matchCounter = { }, 0
	
	local currentPosition, obj = 1

	for e = 1, regex._index do
		obj = regex:get(e)
		if type(obj) == "string" then
			if str[currentPosition] ~= obj then return end
			currentPosition = currentPosition + 1
		else
			if obj.type == "position_capture" then
				matchCounter = matchCounter + 1
				matches[matchCounter] = currentPosition
			end
		end
	end

	if matchCounter == 0 then
		return rawStr
	end
	return util.unpack(matches)
end

return match