local elementsEnum = require("./enums/elements")

local AST = {}

function AST.Anchor(isBeginning)
	return {
		type = elementsEnum.anchor,
		isBeginning = isBeginning,
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
		unicodeRanges = {},
		byteRanges = {},
		keys = {},
		unicodeKeys = {},
		byteKeys = {},
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

AST.hasNestedQuantifier = function(tree)
	if not tree then
		return false
	end
	for elementIndex = 1, tree._index do
		local child = tree[elementIndex]
		if child.quantifier and child.quantifier.type == elementsEnum.quantifier then
			return true
		end
	end
	return false
end

AST.elementHasNestedQuantifier = function(element)
	if element.type == elementsEnum.group then
		return AST.hasNestedQuantifier(element.tree)
	end
	return false
end

AST.elementInnerQuantifierIsPossessive = function(element)
	if element.type == elementsEnum.group and element.tree then
		for elementIndex = 1, element.tree._index do
			local child = element.tree[elementIndex]
			if child.quantifier and child.quantifier.type == elementsEnum.quantifier and child.quantifier.mode == "possessive" then
				return true
			end
		end
	elseif element.quantifier and element.quantifier.type == elementsEnum.quantifier and element.quantifier.mode == "possessive" then
		return true
	end
	return false
end

return AST
