package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local matcher = require("matcher")

_G.printdebug = true
local h, i, e = matcher("(?=(a(?1)?b))a+b+", "aab")
print("matched:", h, i, e)
