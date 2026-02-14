@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Hytale Server Downloader
REM Downloads and extracts the latest pre-release server
REM ============================================

REM Use HYTALE_DOWNLOADER_PATH env var if set, otherwise default
if not defined HYTALE_DOWNLOADER_PATH set "HYTALE_DOWNLOADER_PATH=C:\hytale-downloader"
set "DOWNLOADER_PATH=%HYTALE_DOWNLOADER_PATH%"
set "DOWNLOAD_DIR=%DOWNLOADER_PATH%\downloads"
set "EXTRACT_DIR=%DOWNLOADER_PATH%\extracted"
set "PATCHLINE=pre-release"

REM Create directories
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"

set "DOWNLOADER_EXE=%DOWNLOADER_PATH%\hytale-downloader-windows-amd64.exe"

if not exist "%DOWNLOADER_EXE%" (
    echo ERROR: Hytale downloader not found at: %DOWNLOADER_EXE%
    exit /b 1
)

echo ============================================
echo   Hytale Server Downloader
echo ============================================
echo.
echo Patchline: %PATCHLINE%
echo.

REM Generate timestamp for unique filename
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "TIMESTAMP=%%i"
if "%TIMESTAMP%"=="" set "TIMESTAMP=download"
set "DOWNLOAD_ZIP=%DOWNLOAD_DIR%\server-%PATCHLINE%-%TIMESTAMP%.zip"

echo Downloading server package...
echo Download path: %DOWNLOAD_ZIP%
echo.

REM Change to downloader directory for credentials file
REM Capture output to parse version
set "DL_OUTPUT=%TEMP%\hytale-dl-output-%TIMESTAMP%.txt"
pushd "%DOWNLOADER_PATH%"
"%DOWNLOADER_EXE%" -patchline %PATCHLINE% -download-path "%DOWNLOAD_ZIP%" -skip-update-check > "%DL_OUTPUT%" 2>&1
set "DL_RESULT=!ERRORLEVEL!"
type "%DL_OUTPUT%"
popd

if not exist "%DOWNLOAD_ZIP%" (
    echo ERROR: Download failed - zip file not found at: %DOWNLOAD_ZIP%
    if exist "%DL_OUTPUT%" del "%DL_OUTPUT%"
    exit /b 1
)

echo.
echo Download complete!
echo.

REM Parse version from downloader output (e.g., "version 2026.01.29-301e13929")
set "SERVER_VERSION="
for /f "tokens=2 delims=()" %%v in ('findstr /i "version" "%DL_OUTPUT%"') do (
    set "VER_LINE=%%v"
    for /f "tokens=2" %%w in ("!VER_LINE!") do (
        set "SERVER_VERSION=%%w"
    )
)
if exist "%DL_OUTPUT%" del "%DL_OUTPUT%"

if "%SERVER_VERSION%"=="" (
    set "SERVER_VERSION=%TIMESTAMP%"
    echo Could not parse version, using timestamp: %SERVER_VERSION%
) else (
    echo Server version: %SERVER_VERSION%
)

REM Rename zip to version
set "VERSIONED_ZIP=%DOWNLOAD_DIR%\%SERVER_VERSION%.zip"
if not "%DOWNLOAD_ZIP%"=="%VERSIONED_ZIP%" (
    if exist "%VERSIONED_ZIP%" del /f "%VERSIONED_ZIP%"
    move "%DOWNLOAD_ZIP%" "%VERSIONED_ZIP%" >nul 2>&1
    if exist "%VERSIONED_ZIP%" set "DOWNLOAD_ZIP=%VERSIONED_ZIP%"
)

REM Extract the main server zip
set "SERVER_EXTRACT_PATH=%EXTRACT_DIR%\%SERVER_VERSION%"
if exist "%SERVER_EXTRACT_PATH%" (
    echo Removing existing extracted folder...
    rmdir /s /q "%SERVER_EXTRACT_PATH%"
)

echo.
echo Extracting server package to: %SERVER_EXTRACT_PATH%
powershell -NoProfile -Command "Expand-Archive -Path '%DOWNLOAD_ZIP%' -DestinationPath '%SERVER_EXTRACT_PATH%' -Force"
if !ERRORLEVEL! neq 0 (
    echo ERROR: Failed to extract server package
    exit /b 1
)
echo Main package extracted!
echo.

REM Find and extract Assets.zip
set "ASSETS_ZIP="
for /r "%SERVER_EXTRACT_PATH%" %%f in (Assets.zip) do (
    if exist "%%f" set "ASSETS_ZIP=%%f"
)

if defined ASSETS_ZIP (
    echo Extracting Assets.zip...
    set "ASSETS_DIR=%SERVER_EXTRACT_PATH%\Assets"
    powershell -NoProfile -Command "Expand-Archive -Path '!ASSETS_ZIP!' -DestinationPath '!ASSETS_DIR!' -Force"
    if !ERRORLEVEL! neq 0 (
        echo WARNING: Failed to extract Assets.zip
    ) else (
        echo Assets extracted!
    )
) else (
    echo Warning: Assets.zip not found in extracted files
)

echo.
echo ============================================
echo   Download Complete
echo ============================================
echo.
echo Version:      %SERVER_VERSION%
echo Extracted to: %SERVER_EXTRACT_PATH%
echo.
echo Next step: Run Update-Lib.cmd to decompile and update lib folder
echo.

REM Save version for Update-Lib.cmd
echo %SERVER_VERSION%> "%DOWNLOAD_DIR%\LATEST_VERSION.txt"

exit /b 0
