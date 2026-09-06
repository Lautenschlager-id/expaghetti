--[[ Globals ]]--
local next = next
local string_find = string.find
local string_format = string.format
local string_rep = string.rep
local table_concat = table.concat
local tostring = tostring
local type = type

--[[ Module ]]--
local formatTable
formatTable = function(target, useIndent, showNumericKeys, maxDepth, currentDepth, seen)
	local targetType = type(target)
	if targetType ~= "table" then
		if targetType == "string" then
			return string_format("%q", target)
		end
		return tostring(target)
	end

	currentDepth = currentDepth or 1
	maxDepth = maxDepth or 0
	seen = seen or {}

	if seen[target] then
		return "<circular reference: " .. tostring(target) .. ">"
	end
	seen[target] = true

	local out = {}
	local length = 0
	
	local indentStr = ""
	local childIndentStr = ""
	if useIndent then
		indentStr = string_rep("\t", currentDepth - 1)
		childIndentStr = string_rep("\t", currentDepth)
	end

	for key, value in next, target do
		length = length + 1
		local keyStr = ""
		
		local keyType = type(key)
		if keyType == "string" then
			if string_find(key, "^[%a_][%w_]*$") then
				keyStr = key .. " = "
			else
				keyStr = "[" .. string_format("%q", key) .. "] = "
			end
		elseif keyType == "number" then
			if showNumericKeys then
				keyStr = "[" .. tostring(key) .. "] = "
			end
		else
			keyStr = "[" .. tostring(key) .. "] = "
		end

		local valueStr = ""
		local valueType = type(value)
		if valueType == "table" and not (maxDepth > 0 and currentDepth >= maxDepth) then
			valueStr = formatTable(value, useIndent, showNumericKeys, maxDepth, currentDepth + 1, seen)
		elseif valueType == "string" then
			valueStr = string_format("%q", value)
		else
			valueStr = tostring(value)
		end

		if useIndent then
			out[length] = childIndentStr .. keyStr .. valueStr
		else
			out[length] = keyStr .. valueStr
		end
	end

	seen[target] = nil -- allow same table to be printed in different branches

	if length == 0 then
		return "{}"
	end

	if useIndent then
		return "{\n" .. table_concat(out, ",\n") .. "\n" .. indentStr .. "}"
	else
		return "{" .. table_concat(out, ",") .. "}"
	end
end

return function(target, useIndent, showNumericKeys, maxDepth)
	local prefix = ""
	if type(target) == "table" then
		prefix = "<" .. tostring(target) .. ">"
	end
	return prefix .. formatTable(target, useIndent, showNumericKeys, maxDepth, 1, {})
end