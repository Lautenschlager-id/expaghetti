local operator = { }
operator.__index = operator
operator.__tostring = "operator"

operator.new = function(char, isLazy)
	return setmetatable({
		operator = char,
		isLazy = (isLazy and (char ~= isLazy))
	}, self)
end

return operator