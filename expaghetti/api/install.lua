--[[
    API: install and uninstall
]]

return function(Engine)
	function Engine:install()
		if self._originalString then return end
		self._originalString = {}
		for k, v in pairs(string) do
			self._originalString[k] = v
		end
		
		string.test = function(str, pat, flags, start) return self:test(pat, str, flags, start) end
		string.match = function(str, pat, flags, start) return self:match(pat, str, flags, start) end
		string.matchAll = function(str, pat, flags, start) return self:matchAll(pat, str, flags, start) end
		string.gmatch = function(str, pat, flags, start) return self:gmatch(pat, str, flags, start) end
		string.find = function(str, pat, flags, start) return self:find(pat, str, flags, start) end
		string.replace = function(str, pat, repl, flags, start) return self:replace(pat, str, repl, flags, start) end
		string.gsub = function(str, pat, repl, flags, limit, start) return self:gsub(pat, str, repl, flags, limit, start) end
		string.split = function(str, pat, flags, start) return self:split(pat, str, flags, start) end
	end

	function Engine:uninstall()
		if not self._originalString then return end
		for k, _ in pairs(string) do
			if self._originalString[k] == nil then
				string[k] = nil
			end
		end
		for k, v in pairs(self._originalString) do
			string[k] = v
		end
		self._originalString = nil
	end
end
