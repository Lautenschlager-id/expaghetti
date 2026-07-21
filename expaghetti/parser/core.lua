----------------------------------------------------------------------------------------------------
local Anchor = require("magic.anchor")
local Alternate = require("magic.alternate")
local Any = require("magic.any")
local Group = require("magic.group.group")
local Literal = require("magic.literal")
local Quantifier = require("magic.Quantifier")
local Set = require("magic.set")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("enums.errors")
----------------------------------------------------------------------------------------------------

--- Parses a regex pattern into an Abstract Syntax Tree (AST) sequentially.
---@param state table The ParserState object containing the parsing context and pattern characters.
---@return table|boolean tree The generated AST tree, or false if parsing failed.
---@return string|table|nil errorMessage An error message or error token if parsing failed.
local parserCore = function(state)
	local tree = {
		_index = 0
	}

	local stopParsing, errorMessage

	while state.index <= state.patternLength do
		local currentIndex = state.index
		local nextIndex, element = state:readElement(currentIndex)
		if not nextIndex then
			return false, element
		end

		if state:isElement(element) then
			-- If the element is already parsed (like an escaped literal), append it to the tree directly.
			state.index = nextIndex
			tree._index = tree._index + 1
			tree[tree._index] = element
		else
			if Set.isToken(element) then
				errorMessage = Set.parse(state, tree)
			elseif Group.isOpeningToken(element) then
				errorMessage = Group.parse(state, tree)
			elseif Group.isClosingToken(element) then
				-- Reached the end of a group. `stopParsing` signals the loop to break,
				-- returning the subtree back up to the parent caller.
				stopParsing, errorMessage = Group.parseClosing(state)
				if not errorMessage and stopParsing then
					break
				end
			elseif Anchor.isToken(element) then
				errorMessage = Anchor.parse(state, element, tree)
			elseif Any.isToken(element) then
				errorMessage = Any.parse(state, tree)
			elseif Alternate.isToken(element) then
				-- Alternations (`|`) effectively split the current tree. The left side becomes 
				-- a branch, and the parser continues for the right side branch.
				tree, stopParsing, errorMessage = Alternate.parse(state, tree)
				if not errorMessage and stopParsing then
					break
				end
			else
				errorMessage = Literal.parse(state, element, tree)
			end
		end

		-- Eagerly check if the newly added element is followed by a quantifier (*, +, ?, or {n,m}).
		-- This groups the element and its quantifier together in the AST immediately.
		if not errorMessage and tree[tree._index] then
			errorMessage = Quantifier.lookForElementOperation(state, tree[tree._index])
		end

		if errorMessage then
			return false, errorMessage
		end
	end

	if state.isGroup and not state.isAlternate then
		local currentToken = state.patternChars[state.index]
		if not Group.isClosingToken(currentToken) then
			return false, errorsEnum.unterminatedGroup
		end
	end

	return tree
end

return parserCore
