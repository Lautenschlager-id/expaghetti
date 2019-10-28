local utf8 = require("helper/utf8")
local util = require("helper/util")
local enum = require("enum")

local parse = require("parser")

local setFactory = require("handler/set")
local quantifierFactory = require("handler/quantifier")

local matchFactory = require("handler/match")
local backtrackFactory = require("handler/backtrack")

local strlower = string.lower
local tblconcat = table.concat

local isBoundary = function(currentPosition, initPos, endPos, lastChar, char)
	return (currentPosition > initPos and setFactory.match(enum.class.w, lastChar)) ~= (currentPosition < endPos and setFactory.match(enum.class.w, char))
end

local match
match = function(str, regex, flags, options)
	if type(regex) == "string" then
		regex = parse(regex, flags, options)
	end
	if regex._index == 0 then return { '' } end

	local flagsSet = (flags and util.createSet(flags) or { })
	local isInsensitive = not not flagsSet[enum.flag.insensitive]

	local rawStr, len
	if type(str) == "string" then
		rawStr = rawStr
		if flagsSet[enum.flag.unicode] then
			str, len = utf8.create(str)
		else
			str, len = util.strToArr(str)
		end
	else
		rawStr = tblconcat(str)
		len = #str
	end

	local obj, char, lastChar
	local i, currentPosition, nextI = 1, 1
	local matchChar
	local tmpObj, tmpCurrentPosition, tmpChar, tmpCounter, tmpMaxValue, tmpDelimObj, tmpNextChar -- Quantifier
	local checkBacktracking, backtrackingPosition = false

	local matchHandler = matchFactory:new()
	local backtrackHandler = backtrackFactory:new()

	while i <= regex._index do
		nextI = 1

		repeat
			obj = regex:get(i)
			char = str[currentPosition]
			lastChar = str[currentPosition - 1]

			if type(obj) == "string" then
				if not char or obj ~= char and (not isInsensitive or (obj ~= strlower(char))) then
					checkBacktracking = true
					break
				end
				--matchChar = char
				currentPosition = currentPosition + 1
			else
				if obj.type == "anchor" then
					if obj == enum.anchor.BEGINNING then
						if currentPosition ~= 1 then -- add multiline
							checkBacktracking = true
							break
						end
					elseif obj == enum.anchor.END then
						if currentPosition ~= len + 1 then -- add multiline
							checkBacktracking = true
							break
						end
					elseif obj == enum.anchor.BOUNDARY then
						if not isBoundary(currentPosition, 1, len + 1, lastChar, char) then
							checkBacktracking = true
							break
						end
					elseif obj == enum.anchor.NOTBOUNDARY then
						if isBoundary(currentPosition, 1, len + 1, lastChar, char) then
							checkBacktracking = true
							break
						end	
					end
				elseif obj.type == "position_capture" then
					matchChar = currentPosition
				else
					--[[if not char then -- many non-capturing indexes can be ignored with this condition
						checkBacktracking = true
						break
					end]]
					if obj.type == "set" then
						if not setFactory.match(obj, char, isInsensitive) then
							checkBacktracking = true
							break
						end

						--matchChar = char
						currentPosition = currentPosition + 1
					elseif obj.type == "quantifier" then
						tmpObj = regex:get(i + 1) -- Will be iterated
						tmpMaxValue = (obj[2] or (quantifierFactory.isConst(obj) and obj[1]) or nil) -- Maximum value of the quantifier, nil if N
						-- Values for manipulation of data
						tmpCurrentPosition = currentPosition
						tmpChar = char

						if obj.effect == enum.magic.LAZY_QUANTIFIER then
							tmpDelimObj = nil-- regex:get(i + 2) -- Edge
							--[[
							if tmpDelimObj.type == "quantifier" then -- or any that is not index-consuming
								tmpDelimObj = regex:get(i + 3)
							end
							]]

							tmpNextChar = str[tmpCurrentPosition]

							repeat
								--if not match(tmpChar, tmpObj)
								if tmpChar ~= tmpObj then break end -- literal char only

								tmpChar = tmpNextChar
								if not backtrackHandler.executing then
									backtrackHandler:push(i, tmpCurrentPosition)
								end

								tmpCurrentPosition = tmpCurrentPosition + 1
								tmpNextChar = str[tmpCurrentPosition]
							until tmpNextChar == tmpDelimObj -- tmpDelimObj.match(tmpNextChar) would be the essential
						elseif obj.effect == enum.magic.POSSESSIVE_QUANTIFIER then
							tmpCounter = 0

							repeat
								--if not match(tmpChar, tmpObj)
								if tmpChar ~= tmpObj then break end -- literal char only

								tmpCurrentPosition = tmpCurrentPosition + 1
								tmpChar = str[tmpCurrentPosition]
								tmpCounter = tmpCounter + 1
							until tmpCounter == tmpMaxValue
						else -- Greedy
							repeat
								--if not match(tmpChar, tmpObj)
								if tmpChar ~= tmpObj then break end -- literal char only

								if not backtrackHandler.executing then
									backtrackHandler:push(i)
								end

								tmpCurrentPosition = tmpCurrentPosition + 1
								tmpChar = str[tmpCurrentPosition]
							until false
						end

						currentPosition, tmpCurrentPosition = tmpCurrentPosition, (tmpCurrentPosition - currentPosition)

						-- Less than the minimum
						if (obj[1] and tmpCurrentPosition < obj[1]) then
							checkBacktracking = true
							break
						end

						nextI = 2
					elseif obj.type == "group" then
						if not obj.effect then
							--matchChar = match(str, obj.tree, flags, options)
							-- TODO: add to %reference
							if not matchChar then
								checkBacktracking = true
								break
							end
						elseif obj.effect == enum.magic.NON_CAPTURING_GROUP then
							--if not match(str, obj.tree, flags, options) then return end
						else
							-- TODO
						end
					elseif obj.type == "alternate" then -- Missing backtracking
						local tmp
						for t = 1, obj.trees._index do
							matchChar = match(str, obj.trees[t], flags, options)
							if matchChar then break end
						end
						return matchChar
					end
				end
			end

			if matchChar then
				matchHandler:push(matchChar)
				matchChar = nil
			end
		until true

		if checkBacktracking then
			checkBacktracking = false

			if not backtrackHandler._lastIndex then return end
			if backtrackHandler:pop():getLength() == 0 then return end
			backtrackHandler.executing = true

			backtrackingPosition = currentPosition
			currentPosition = currentPosition - 1

			nextI = 0
		elseif backtrackingPosition and currentPosition > backtrackingPosition then
			backtrackingPosition = nil
			backtrackHandler.executing = false
		end

		i = i + nextI
	end

	if matchCounter == 0 then
		return { rawStr } -- Assuming it works as ^exp (waiting for the matching system)
	end
	return matchHandler:get()
end

return match