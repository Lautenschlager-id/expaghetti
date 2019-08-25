local tableToString
do
	local strrep = string.rep
	local strformat = string.format
	local tblconcat = table.concat
	local strfind = string.find

	tableToString = function(tbl, indent, numIndex, _depth, _stop)
		_depth = _depth or 1
		_stop = _stop or 0

		local out = { }
		local counter = 0
	
		for k, v in next, tbl do
			counter = counter + 1
			out[counter] = (indent and strrep("\t", _depth) or '') .. ((type(k) ~= "number" and (strfind(k, "^[%w_]") and (k .. " = ") or ("[" .. strformat("%q", k) .. "] = ")) or numIndex and ("[" .. k .. "] = ") or ''))
			local t = type(v)
			if t == "table" then
				out[counter] = out[counter] .. ((_stop > 0 and _depth > _stop) and tostring(v) or tableToString(v, indent, numIndex, _depth + 1, _stop - 1))
			elseif t == "number" or t == "boolean" then
				out[counter] = out[counter] .. tostring(v)
			elseif t == "string" then
				out[counter] = out[counter] .. strformat("%q", v)
			else
				out[counter] = out[counter] .. "nil"
			end
		end
	
		return "{" .. (indent and ("\n" .. tblconcat(out, ",\n") .. "\n") or tblconcat(out, ',')) .. (indent and strrep("\t", _depth - 1) or '') .. "}"
	end
end

local tableCompare
do
	local compare
	compare = function(src, tmp, _reverse)
		if (type(src) ~= "table" or type(tmp) ~= "table") then
			return src == tmp
		end

		for k, v in next, src do
			if type(v) == "table" then
				if type(tmp[k]) ~= "table" or not compare(v, tmp[k]) then
					return false
				end
			else
				if tmp[k] ~= v then
					return false
				end
			end
		end
		return _reverse and true or compare(tmp, src, true)
	end
	tableCompare = function(src, tmp, checkMeta)
		return compare(src, tmp) and (not checkMeta or compare(getmetatable(src), getmetatable(tmp)))
	end
end

return {
	tableToString = tableToString,
	tableCompare = tableCompare
}