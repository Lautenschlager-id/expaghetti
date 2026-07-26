--[[
	Helper function for pretty printing tables.
]]

--[[ Globals ]]--
local type = type
local tostring = tostring
local next = next

local strformat = string.format
local strrep = string.rep
local strfind = string.find
local tblconcat = table.concat

--[[ Module ]]--
local PrettyPrint = {}

--[[ Private Functions ]]--
local tableToString
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

	local t
	for k, v in next, tbl do
		counter = counter + 1
		out[counter] = (indent and strrep("\t", _depth) or '') .. ((type(k) ~= "number" and (strfind(tostring(k), "^[%w_]") and (tostring(k) .. " = ") or ("[" .. strformat("%q", tostring(k)) .. "] = ")) or numIndex and ("[" .. tostring(k) .. "] = ") or ''))

		t = type(v)
		if t == "table" and not (stop > 0 and _depth >= stop) then
			out[counter] = out[counter] .. tableToString(v, indent, numIndex, stop - 1, _depth + 1, (_ref or tbl))
		elseif t == "number" or t == "boolean" then
			out[counter] = out[counter] .. tostring(v)
		elseif t == "string" then
			out[counter] = out[counter] .. strformat("%q", v)
		else
			out[counter] = out[counter] .. tostring(v)
		end
	end

	return "{" .. (indent and ("\n" .. tblconcat(out, ",\n") .. "\n") or tblconcat(out, ',')) .. (indent and strrep("\t", _depth - 1) or '') .. "}"
end

--[[ Return ]]--
return function(t, ...)
	return --"<" .. tostring(t) .. ">" ..
		tableToString(t, ...)
end