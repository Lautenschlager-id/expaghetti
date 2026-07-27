local input = assert(arg[1])

-- Normalize path separators
input = input:gsub("\\", "/")

-- Extract path relative to expaghetti/
local relative = assert(
	input:match("expaghetti/(.+)$"),
	"Expected a file inside expaghetti/: " .. input
)

-- Rename expaghetti.lua -> init.lua
if relative == "expaghetti/expaghetti.lua" then
	relative = "expaghetti/init.lua"
end

-- Destination
local output = "dist/" .. relative

-- Read file
local file = assert(io.open(input, "rb"))
local text = file:read("*a")
file:close()

-- Rewrite requires
text = text:gsub(
	'require%("([^"]+)"%)',
	function(module)
		return ('require("%s")'):format(module:gsub("%.", "/"))
	end
)

-- Create output directory
local dir = assert(output:match("^(.*)/[^/]+$"))

if package.config:sub(1, 1) == "\\" then
	os.execute(('if not exist "%s" mkdir "%s"'):format(
		dir:gsub("/", "\\"),
		dir:gsub("/", "\\")
	))
else
	os.execute(('mkdir -p "%s"'):format(dir))
end

-- Write file
file = assert(io.open(output, "wb"))
file:write(text)
file:close()