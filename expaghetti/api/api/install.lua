--[[
    API: install and uninstall
]]

--[[ Globals ]]--
local next = next

--[[ Module ]]--
local install = function(self)
	local originalString = self._originalString
	if originalString then return end

	originalString = {}
	for method, fn in next, string do
		originalString[method] = fn
	end
	self._originalString = originalString
	
	string.test = function(targetString, pattern, flags, startPosition)
		return self:test(pattern, targetString, flags, startPosition)
	end

	string.match = function(targetString, pattern, flags, startPosition)
		return self:match(pattern, targetString, flags, startPosition)
	end

	string.matchAll = function(targetString, pattern, flags, startPosition)
		return self:matchAll(pattern, targetString, flags, startPosition)
	end
	
	string.gmatch = function(targetString, pattern, flags, startPosition)
		return self:gmatch(pattern, targetString, flags, startPosition)
	end

	string.find = function(targetString, pattern, flags, startPosition)
		return self:find(pattern, targetString, flags, startPosition)
	end

	string.replace = function(targetString, pattern, replacement, flags, startPosition)
		return self:replace(pattern, targetString, replacement, flags, startPosition)
	end

	string.gsub = function(targetString, pattern, replacement, flags, limit, startPosition)
		return self:gsub(pattern, targetString, replacement, flags, limit, startPosition)
	end

	string.split = function(targetString, pattern, flags, startPosition)
		return self:split(pattern, targetString, flags, startPosition)
	end
end

local uninstall = function(self)
	local originalString = self._originalString
	if not originalString then return end

	for method, _ in next, string do
		if originalString[method] == nil then
			string[method] = nil
		end
	end

	for method, fn in next, originalString do
		string[method] = fn
	end

	self._originalString = nil
end

return {
	install = install,
	uninstall = uninstall
}
