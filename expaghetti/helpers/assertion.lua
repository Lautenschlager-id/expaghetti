local Assertion = {}

local type = type
local error = error
local format = string.format

function Assertion.isString(value, parameterName, acceptNil)
    if type(value) ~= "string" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (string expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

function Assertion.isNumber(value, parameterName, acceptNil)
    if type(value) ~= "number" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (number expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

function Assertion.isBoolean(value, parameterName, acceptNil)
    if type(value) ~= "boolean" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (boolean expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

function Assertion.isTable(value, parameterName, acceptNil)
    if type(value) ~= "table" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (table expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

function Assertion.isFunction(value, parameterName, acceptNil)
    if type(value) ~= "function" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (function expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

function Assertion.isStringOrTable(value, parameterName, acceptNil)
    if type(value) ~= "string" and type(value) ~= "table" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (string or table expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

function Assertion.isStringOrFunctionOrTable(value, parameterName, acceptNil)
    if type(value) ~= "string" and type(value) ~= "function" and type(value) ~= "table" and (not acceptNil or value ~= nil) then
        error(
            format(
                "bad argument '%s' (string or function or table expected, got %s)",
                parameterName,
                type(value)
            )
        )
    end
end

return Assertion