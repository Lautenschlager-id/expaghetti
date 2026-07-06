local ParserState = {}
ParserState.__index = ParserState

function ParserState.new(expr, flags, isGroup, isAlternate, index, expression, expressionLength, tokens, metaData, hasGroupClosed)
	local self = setmetatable({}, ParserState)
	self.expr = expr
	self.flags = {}
	if type(flags) == "string" then
		for char in flags:gmatch(".") do
			self.flags[char] = true
		end
	elseif type(flags) == "table" then
		for k, v in pairs(flags) do
			self.flags[k] = v
		end
	end
	self.isGroup = isGroup
	self.isAlternate = isAlternate
	self.index = index
	self.expression = expression
	self.expressionLength = expressionLength
	self.tokens = tokens
	self.charactersIndex = tokens and #tokens or 0
	
	self.metaData = metaData
	self.hasGroupClosed = hasGroupClosed
	self.initialGroupIndex = metaData and metaData.groupIndex or 0
	return self
end

function ParserState:parseSubTree(isGroup, isAlternate, hasGroupClosed, isBranchReset)
	-- To avoid circular dependency, we require parser dynamically, or inject it
	local parser = require("./parser")
	local tree, nextIndex, newHasGroupClosed = parser(
		nil, nil,
		isGroup, isAlternate,
		self.index, self.expression, self.expressionLength,
		self.tokens,
		self.metaData,
		hasGroupClosed,
		self.flags,
		isBranchReset
	)
	if not tree then
		return false, nextIndex
	end
	self.index = nextIndex
	if hasGroupClosed ~= nil then
		self.hasGroupClosed = newHasGroupClosed
	end
	return tree
end

return ParserState
