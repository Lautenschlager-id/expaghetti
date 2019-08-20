local strsub = string.sub

local createSet = function(array)
	local set = { }
	for i = 1, #array do
		set[array[i]] = i
	end
	return set
end

local strToTbl = function(str) -- string.split(str, '.')
	local tbl = { }

	local len = #str
	for i = 1, len do
		tbl[i] = strsub(str, i, i)
	end

	return tbl, len
end

local toArray = function(tbl)
	local arr = { }

	local index = 0
	for _, v in next, tbl do
		index = index + 1
		arr[index] = v
	end

	return arr
end

-----------------> DEBUG ONLY <-----------------
do
	local strrep = string.rep
	local strformat = string.format
	local tblconcat = table.concat
	local strfind = string.find
	table.tostring = function(list, indent, numIndex, _depth, _stop)
		_depth = _depth or 1
		_stop = _stop or 0

		local out = { }
		local counter = 0
	
		for k, v in next, list do
			counter = counter + 1
			out[counter] = (indent and strrep("\t", _depth) or '') .. ((type(k) ~= "number" and (strfind(k, "^[%w_]") and (k .. " = ") or ("[" .. strformat("%q", k) .. "] = ")) or numIndex and ("[" .. k .. "] = ") or ''))
			local t = type(v)
			if t == "table" then
				out[counter] = out[counter] .. ((_stop > 0 and _depth > _stop) and tostring(v) or table.tostring(v, indent, numIndex, _depth + 1, _stop - 1))
			elseif t == "number" or t == "boolean" then
				out[counter] = out[counter] .. tostring(v)
			elseif t == "string" then
				out[counter] = out[counter] .. strformat("%q", v)
			else
				out[counter] = out[counter] .. "nil"
			end
		end
	
		return "{" .. (indent and ("\n" .. tblconcat(out, ",\n") .. "\n") or table.concat(out, ',')) .. (indent and strrep("\t", _depth - 1) or '') .. "}"
	end
end
-----------------<            >-----------------

return {
	createSet = createSet,
	strToTbl = strToTbl,
	toArray = toArray,
	insert = insert
}