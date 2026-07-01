package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local m = require("expaghetti/matcher")
local hasMatched, s, e = m("(?=(a))\\1", "a")
print("Result:", hasMatched, s, e)
