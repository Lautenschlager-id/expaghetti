package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local parser = require("parser")
local expr = "(?|(a)|(b)(c)|(d))e(f)"
local tree, err = parser(expr)
local function findBranchReset(t)
    if type(t) == "table" then
        if t.isBranchReset then print("Found branch reset!") end
        for k,v in pairs(t) do findBranchReset(v) end
    end
end
findBranchReset(tree)
