local Escaped = require("./magic/escaped")

local Tokenizer = {}

function Tokenizer.tokenize(expression, expressionLength)
	local tokens = {}
	local index = 1

	while index <= expressionLength do
		local currentCharacter = expression[index]

		if Escaped.isToken(currentCharacter) then
			local nextIndex, parsedElement = Escaped.parse(index, expression)
			if not nextIndex then
				-- parsedElement is error message
				return false, parsedElement
			end
			tokens[#tokens + 1] = {
				raw = parsedElement,
				value = parsedElement.value,
				isEscaped = true
			}
			index = nextIndex
		else
			tokens[#tokens + 1] = {
				raw = currentCharacter,
				value = currentCharacter,
				isEscaped = false
			}
			index = index + 1
		end
	end

	return #tokens, tokens
end

return Tokenizer
