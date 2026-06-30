local MatchState = {}
MatchState.__index = MatchState

function MatchState.new(flags, splitStr, strLength, stringIndex, initialStringIndex, metaData)
	local self = setmetatable({}, MatchState)
	
	self.flags = flags or {}
	self.splitStr = splitStr
	self.strLength = strLength
	self.stringIndex = stringIndex or 0
	self.initialStringIndex = initialStringIndex or self.stringIndex
	
	self.metaData = metaData or {
		groupCapturesInitStringPositions = {},
		groupCapturesEndStringPositions = {},
		positionCaptures = {},
		outerTreeReference = {}
	}
	
	return self
end

return MatchState
