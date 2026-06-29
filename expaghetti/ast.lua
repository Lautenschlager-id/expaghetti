local elementsEnum = require("./enums/elements")

local AST = {}

function AST.Anchor(isBeginning)
	return {
		type = elementsEnum.anchor,
		isBeginning = isBeginning,
		quantifier = false,
	}
end

function AST.Any()
	return {
		type = elementsEnum.any,
	}
end

function AST.Literal(value)
	return {
		type = elementsEnum.literal,
		value = value
	}
end

function AST.Group()
	return {
		type = elementsEnum.group,
	}
end

function AST.Set()
	return {
		type = elementsEnum.set,
		hasToNegateMatch = false,
		rangeIndex = 0,
		ranges = {},
		classIndex = 0,
		classes = {},
	}
end

function AST.Quantifier(min, max)
	return {
		type = elementsEnum.quantifier,
		min = min or 0,
		max = max or 0,
		mode = nil,
	}
end

function AST.Alternate(trees)
	return {
		type = elementsEnum.alternate,
		trees = trees,
	}
end

return AST
