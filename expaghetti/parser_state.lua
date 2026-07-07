local ParserState = {}
ParserState.__index = ParserState

function ParserState.new(expr, flags, isGroup, isAlternate, index, patternChars, patternLength, metaData, hasGroupClosed)
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
	self.index = index or 1
	self.patternChars = patternChars
	self.patternLength = patternLength
	
	if metaData then
		self.metaData = metaData
	else
		self.metaData = {
			groupNames = {},
			groupIndex = 0,
			positionCaptureIndex = 0,
			groupTreesByIndex = {},
			groupTreesByName = {},
		}
	end
	
	self.hasGroupClosed = hasGroupClosed
	self.initialGroupIndex = self.metaData.groupIndex
	return self
end

function ParserState:parseSubTree(isGroup, isAlternate, hasGroupClosed, isBranchReset)
	-- To avoid circular dependency, we require parser dynamically, or inject it
	local parser = require("./parser")
	local tree, nextIndex, newHasGroupClosed = parser(
		nil, nil,
		isGroup, isAlternate,
		self.index, self.patternChars, self.patternLength,
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
