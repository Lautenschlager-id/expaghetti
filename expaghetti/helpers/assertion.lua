--[[
	Argument validation helpers.

	Provides assertion functions for validating function arguments.
]]

--[[ Globals ]]--
local error = error
local string_format = string.format
local type = type

--[[ Module ]]--

--- Asserts that a value is a string.
--- Raises a descriptive argument error if the value is not a string.
---@param value any The value to validate.
---@param parameterName string The name of the parameter being validated.
---@param acceptNil boolean|nil Whether nil should be accepted.
local isString = function(value, parameterName, acceptNil)
	if type(value) == "string" or (acceptNil and value == nil) then return end
	error(
		string_format("bad argument '%s' (string expected, got %s)", parameterName, type(value)),
		2
	)
end

--- Asserts that a value is a number.
--- Raises a descriptive argument error if the value is not a number.
---@param value any The value to validate.
---@param parameterName string The name of the parameter being validated.
---@param acceptNil boolean|nil Whether nil should be accepted.
local isNumber = function(value, parameterName, acceptNil)
	if type(value) == "number" or (acceptNil and value == nil) then return end
	error(
		string_format("bad argument '%s' (number expected, got %s)", parameterName, type(value)),
		2
	)
end

--- Asserts that a value is a table.
--- Raises a descriptive argument error if the value is not a table.
---@param value any The value to validate.
---@param parameterName string The name of the parameter being validated.
---@param acceptNil boolean|nil Whether nil should be accepted.
local isTable = function(value, parameterName, acceptNil)
	if type(value) == "table" or (acceptNil and value == nil) then return end
	error(
		string_format("bad argument '%s' (table expected, got %s)", parameterName, type(value)),
		2
	)
end

--- Asserts that a value is either a string or a table.
--- Raises a descriptive argument error if the value is neither a string nor a table.
---@param value any The value to validate.
---@param parameterName string The name of the parameter being validated.
---@param acceptNil boolean|nil Whether nil should be accepted.
local isStringOrTable = function(value, parameterName, acceptNil)
	if type(value) == "string" or type(value) == "table" or (acceptNil and value == nil) then return end
	error(
		string_format("bad argument '%s' (string or table expected, got %s)", parameterName, type(value)),
		2
	)
end

--- Asserts that a value is a string, function, or table.
--- Raises a descriptive argument error if the value is none of the accepted types.
---@param value any The value to validate.
---@param parameterName string The name of the parameter being validated.
---@param acceptNil boolean|nil Whether nil should be accepted.
local isStringOrFunctionOrTable = function(value, parameterName, acceptNil)
	if type(value) == "string" or type(value) == "function" or type(value) == "table" or (acceptNil and value == nil) then return end
	error(
		string_format("bad argument '%s' (string or function or table expected, got %s)", parameterName, type(value)),
		2
	)
end

return {
	isNumber = isNumber,
	isString = isString,
	isStringOrFunctionOrTable = isStringOrFunctionOrTable,
	isStringOrTable = isStringOrTable,
	isTable = isTable,
}