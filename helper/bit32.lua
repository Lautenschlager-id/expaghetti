-- Other functions may be added later according to the lib needs
if _VERSION >= "Lua 5.3" then -- Bitwise operators
	local bit32 = { }

	bit32.rshift = function(x, disp)
		return x >> disp
	end

	return bit32
elseif _VERSION <= "Lua 5.1" then -- No bitwise
	local floor = math.floor
	local _32 = 2 ^ 32

	local bit32 = { }

	bit32.rshift = function(x, disp)
		return floor(x % _32 / 2 ^ disp)
	end

	return bit32
end
return bit32