package.path = "./expaghetti/?.lua;" .. package.path
local matcher = require("matcher")
print("Result for [%l]te with i:", (matcher("[%l]te", "Ate", "i")))
print("Result for %lte with i:", (matcher("%lte", "Ate", "i")))
