local function benchmark()
	local str = string.rep("a", 10000000)

	-- 8. getChar(target, index) string.sub
	local t8 = os.clock()
	local sum = 0
	local target8 = str
	local getChar8 = function(target, index) return string.sub(target, index, index) end
	for i = 1, #str do
		if getChar8(target8, i) == "a" then sum = sum + 1 end
	end
	local t8_end = os.clock()

	print(string.format("8. getChar(target, index) string.sub: %.4fs", t8_end - t8))
end

benchmark()
