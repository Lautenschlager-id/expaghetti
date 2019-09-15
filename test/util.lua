local tableToString
do
	local strrep = string.rep
	local strformat = string.format
	local tblconcat = table.concat
	local strfind = string.find

	tableToString = function(tbl, indent, numIndex, stop, _depth, _ref)
		if type(tbl) ~= "table" then
			return tostring(tbl)
		end

		if _depth and _depth > 1 and _ref == tbl then
			return tostring(_ref)
		end

		_depth = _depth or 1
		stop = stop or 0

		local out = { }
		local counter = 0
	
		for k, v in next, tbl do
			counter = counter + 1
			out[counter] = (indent and strrep("\t", _depth) or '') .. ((type(k) ~= "number" and (strfind(k, "^[%w_]") and (k .. " = ") or ("[" .. strformat("%q", k) .. "] = ")) or numIndex and ("[" .. k .. "] = ") or ''))
			local t = type(v)
			if t == "table" then
				out[counter] = out[counter] .. ((stop > 0 and _depth > stop) and tostring(v) or tableToString(v, indent, numIndex, stop - 1, _depth + 1, (_ref or tbl)))
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
	compare = function(src, tmp, _reversed)
		if type(src) ~= "table" or type(tmp) ~= "table" then
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
		return _reversed or compare(tmp, src, true)
	end
	tableCompare = function(src, tmp, checkMeta)
		return compare(src, tmp) and (not checkMeta or compare(getmetatable(src), getmetatable(tmp)))
	end
end

local assertion = {
	error = nil
}

assertion.get = function()
	local out = assertion.error or false -- forces boolean
	assertion.error = nil
	return out
end

do
	local parse = require("../parser")

	assertion.object = function(src, comp, msg, checkTree)
		if assertion.error then return end

		src = parse(src).stack
		if not checkTree then
			src = src[1]
		end

		if not tableCompare(src, comp) then
			assertion.error = msg .. "\n\tGot:\n\t\t" .. tableToString(src) .. "\n\tExpected:\n\t\t" .. tableToString(comp)
		end
	end
end

return {
	tableToString = tableToString,
	tableCompare = tableCompare,
	assertion = assertion
}