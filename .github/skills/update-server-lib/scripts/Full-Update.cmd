@echo off
setlocal

REM ============================================
REM Hytale Server Full Update
REM Downloads, decompiles, and updates lib
REM ============================================

set "SCRIPT_DIR=%~dp0"

echo ============================================
echo   Hytale Server Full Update
echo ============================================
echo.

echo ^>^>^> Step 1/2: Downloading server...
echo.

call "%SCRIPT_DIR%Download-Server.cmd"
if errorlevel 1 (
    echo.
    echo ERROR: Download step failed
    exit /b 1
)

echo.
echo ^>^>^> Step 2/2: Updating lib folder...
echo.

call "%SCRIPT_DIR%Update-Lib.cmd"
if errorlevel 1 (
    echo.
    echo ERROR: Update step failed
    exit /b 1
)

echo.
echo ============================================
echo   Full Update Complete!
echo ============================================
echo.
echo Your lib folder is now updated with:
echo   - Latest HytaleServer.jar
echo   - Decompiled source code (for reference)
echo   - Server assets
echo   - UI assets
echo.
echo Run 'Build and Deploy Plugin' task to test your plugin!
echo.

endlocal
