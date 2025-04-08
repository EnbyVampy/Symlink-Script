@echo off
:: Make sure errors don't close the window
setlocal EnableDelayedExpansion
title Create Symlink Tool

echo Running... Please wait.

:: Open File Dialog to select source (file or folder)
echo Selecting source file/folder...
powershell -NoProfile -STA -Command ^
  "$source = (New-Object -ComObject Shell.Application).BrowseForFolder(0, 'Select the SOURCE file or folder', 0).Self.Path; if ($source) { Write-Output $source }" > "%temp%\source_path.txt"

set /p source=<"%temp%\source_path.txt"
del "%temp%\source_path.txt"

if "%source%"=="" (
    echo No source selected. Exiting.
    pause
    exit /b
)

:: Open Folder Dialog to select destination folder
echo Selecting destination folder...
powershell -NoProfile -STA -Command ^
  "$target = (New-Object -ComObject Shell.Application).BrowseForFolder(0, 'Select the DESTINATION folder for the symlink', 0).Self.Path; if ($target) { Write-Output $target }" > "%temp%\link_path.txt"

set /p linkdir=<"%temp%\link_path.txt"
del "%temp%\link_path.txt"

if "%linkdir%"=="" (
    echo No destination selected. Exiting.
    pause
    exit /b
)

:: Prompt for symlink name
set /p linkname=Enter the name of the symlink (e.g. MyLink): 

if "%linkname%"=="" (
    echo No symlink name provided. Exiting.
    pause
    exit /b
)

set "link=%linkdir%\%linkname%"

:: Check if source is a directory
powershell -Command ^
  "if ((Test-Path -LiteralPath '%source%') -and (Get-Item -LiteralPath '%source%').PSIsContainer) { exit 0 } else { exit 1 }"
if %errorlevel%==0 (
    echo Creating directory symbolic link...
    mklink /D "%link%" "%source%"
) else (
    echo Creating file symbolic link...
    mklink "%link%" "%source%"
)

echo.
echo ✅ Symlink created: 
echo     %link% -> %source%
pause
