package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local matcher = require("matcher")

local tests = {
    {"((?>cat|ca))t", "cat"},
    {"((?>cat|ca))t", "catt"},
    {"((?>a+))%1", "aaa"},
    {"((?>a))%1", "aa"},
}
for _, t in ipairs(tests) do
    local h, i, e, m = matcher(t[1], t[2])
    print(t[1], t[2], "->", h, i, e)
    if m then
        for k, v in pairs(m.groupCapturesInitStringPositions) do
            print("  group", k, "ini:", v[1])
        end
    end
end
