@echo off

REM Go to the repository root
cd /d "%~dp0\..\.."

if exist dist rmdir /S /Q dist

for /R "expaghetti" %%F in (*.lua) do (
    echo Processing %%F
    lua scripts\luvit\build.lua "%%F"
)

for /R "expaghetti" %%F in (*) do (
    if /I not "%%~xF"==".lua" (
        xcopy /Y /I "%%F" "dist\%%~pF%%~nxF" >nul
    )
)