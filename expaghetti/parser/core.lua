--[[
	Core parsing loop.

	Parses a regular expression into an Abstract Syntax Tree (AST).
]]

--[[ Dependencies ]]--
local Alternate = require("magic.alternate")
local Anchor = require("magic.anchor")
local Any = require("magic.any")
local Group = require("magic.group.group")
local Quantifier = require("magic.quantifier")
local Set = require("magic.set")

--[[ Aliases ]]--
local AlternateIsToken, AlternateParse = Alternate.isToken, Alternate.parse
local AnchorIsToken, AnchorParse = Anchor.isToken, Anchor.parse
local AnyIsToken, AnyParse = Any.isToken, Any.parse
local GroupIsClosingToken, GroupParseClosing = Group.isClosingToken, Group.parseClosing
local GroupIsOpeningToken, GroupParse = Group.isOpeningToken, Group.parse
local LiteralParse = require("magic.literal").parse
local QuantifierLookForElementOperation = Quantifier.lookForElementOperation
local SetIsToken, SetParse = Set.isToken, Set.parse

local ERROR_UNTERMINATED_GROUP = require("enums.errors").unterminatedGroup

--[[ Module ]]--

--- Parses a regular expression into an Abstract Syntax Tree (AST) sequentially.
---@param state ParserState The parser state.
---@return ASTTree|boolean tree The generated AST tree, or false if parsing failed.
---@return string|nil errorMessage The parser error message on failure.
return function(state)
	local tree = {
		_index = 0
	}

	while state.index <= state.patternLength do
		local stopParsing, errorMessage

		local nextIndex, element = state:readElement(state.index)
		if not nextIndex then
			return false, element
		end

		if state:isElement(element) then
			-- If the element is already parsed (like an escaped literal), append it to the tree directly.
			state.index = nextIndex

			local treeIndex = tree._index + 1
			tree._index = treeIndex
			tree[treeIndex] = element
		else
			if SetIsToken(element) then
				errorMessage = SetParse(state, tree)
			elseif GroupIsOpeningToken(element) then
				errorMessage = GroupParse(state, tree)
			elseif GroupIsClosingToken(element) then
				-- Reached the end of a group. `stopParsing` signals the loop to break,
				-- returning the subtree back up to the parent caller.
				stopParsing, errorMessage = GroupParseClosing(state)
				if not errorMessage and stopParsing then
					break
				end
			elseif AnchorIsToken(element) then
				errorMessage = AnchorParse(state, element, tree)
			elseif AnyIsToken(element) then
				errorMessage = AnyParse(state, tree)
			elseif AlternateIsToken(element) then
				-- Alternations (`|`) effectively split the current tree. The left side becomes 
				-- a branch, and the parser continues for the right side branch.
				tree, stopParsing, errorMessage = AlternateParse(state, tree)
				if not errorMessage and stopParsing then
					break
				end
			else
				errorMessage = LiteralParse(state, element, tree)
			end
		end

		-- Attach a following quantifier to the newly parsed element.
		-- This groups the element and its quantifier together in the AST immediately.
		local treeElement = not errorMessage and tree[tree._index]
		if treeElement and not treeElement.quantifier then
			errorMessage = QuantifierLookForElementOperation(state, treeElement)
		end

		if errorMessage then
			return false, errorMessage
		end
	end

	if state.isGroup and not state.isAlternate then
		local currentToken = state.patternChars[state.index]
		if not GroupIsClosingToken(currentToken) then
			return false, ERROR_UNTERMINATED_GROUP
		end
	end

	return tree
end
