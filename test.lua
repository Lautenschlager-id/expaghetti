local strgmatch = string.gmatch
local strformat = string.format
local strsub = string.sub
local popen = io.popen

local folder = {
	"util",
	"parser",
	"matcher"
}

local getFilesWithoutExtension = (strsub(package.config, 1, 1) == "\\" and "for %%a in (\"test/%s/*\") do @echo %%~na" or "ls 'test/%s/' -1 | sed -e 's/\\..*$//'") -- Windows (\) or Linux (/)

local hasFailed, testError = false
for f = 1, #folder do
	f = folder[f]
	for file in strgmatch(popen(strformat(getFilesWithoutExtension, f)):read("*a"), "[^\n]+") do
		testError = require("test/" .. f .. "/" .. file)
		if testError and not hasFailed then
			hasFailed = true
		end
		print("[" .. f .. "/" .. file .. "] " .. (testError or "All tests have passed."))
	end
end

return (hasFailed and error()) -- ".github/workflows/test.yml"'s purpose