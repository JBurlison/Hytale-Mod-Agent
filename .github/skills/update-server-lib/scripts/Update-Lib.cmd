@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Hytale Server Lib Updater
REM Decompiles and updates lib folder
REM ============================================

REM Use HYTALE_DOWNLOADER_PATH env var if set, otherwise default
if not defined HYTALE_DOWNLOADER_PATH set "HYTALE_DOWNLOADER_PATH=C:\hytale-downloader"
set "EXTRACT_DIR=%HYTALE_DOWNLOADER_PATH%\extracted"
set "PATCHER_DIR=%HYTALE_DOWNLOADER_PATH%\patcher"
set "DOWNLOAD_DIR=%HYTALE_DOWNLOADER_PATH%\downloads"

REM Get workspace root (4 levels up from script location)
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%\..\..\..\..\") do set "WORKSPACE_ROOT=%%~fI"
set "LIB_DIR=%WORKSPACE_ROOT%lib"

echo ============================================
echo   Hytale Server Lib Updater
echo ============================================
echo.
echo Workspace: %WORKSPACE_ROOT%
echo Lib Dir:   %LIB_DIR%
echo.

REM Get server version - either from argument or latest
set "SERVER_VERSION=%~1"
if "%SERVER_VERSION%"=="" (
    if exist "%DOWNLOAD_DIR%\LATEST_VERSION.txt" (
        set /p SERVER_VERSION=<"%DOWNLOAD_DIR%\LATEST_VERSION.txt"
    )
)

if "%SERVER_VERSION%"=="" (
    REM Find latest folder in extract dir
    for /f "tokens=*" %%d in ('dir /b /ad /o-n "%EXTRACT_DIR%" 2^>nul') do (
        set "SERVER_VERSION=%%d"
        goto :found_version
    )
)
:found_version

if "%SERVER_VERSION%"=="" (
    echo ERROR: No server version found. Run Download-Server.cmd first.
    exit /b 1
)

set "SERVER_EXTRACT_PATH=%EXTRACT_DIR%\%SERVER_VERSION%"
if not exist "%SERVER_EXTRACT_PATH%" (
    echo ERROR: Server version folder not found: %SERVER_EXTRACT_PATH%
    exit /b 1
)

echo Using version: %SERVER_VERSION%
echo.

REM Find HytaleServer.jar
set "HYTALE_JAR="
for /r "%SERVER_EXTRACT_PATH%" %%f in (HytaleServer.jar) do (
    if exist "%%f" set "HYTALE_JAR=%%f"
)

if not defined HYTALE_JAR (
    echo ERROR: HytaleServer.jar not found in: %SERVER_EXTRACT_PATH%
    exit /b 1
)

echo Found HytaleServer.jar: %HYTALE_JAR%

REM Find Assets folder
set "ASSETS_PATH="
for /d /r "%SERVER_EXTRACT_PATH%" %%d in (*) do (
    if /i "%%~nxd"=="Assets" (
        if exist "%%d\Server" set "ASSETS_PATH=%%d"
    )
)

if defined ASSETS_PATH (
    echo Found Assets: %ASSETS_PATH%
)

echo.
echo ============================================
echo   Checking Prerequisites
echo ============================================
echo.

set "PREREQ_FAIL="
set "PYTHON_CMD=py -3"

REM Check Python
where py >nul 2>nul
if errorlevel 1 (
    where python >nul 2>nul
    if errorlevel 1 (
        echo [FAIL] Python not found
        set "PREREQ_FAIL=1"
    ) else (
        echo [OK] Python found
        set "PYTHON_CMD=python"
    )
) else (
    echo [OK] Python found
)

REM Check Java
where java >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Java not found
    set "PREREQ_FAIL=1"
) else (
    echo [OK] Java found
)

REM Check Maven
where mvn >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Maven not found
    set "PREREQ_FAIL=1"
) else (
    echo [OK] Maven found
)

REM Check Git
where git >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Git not found
    set "PREREQ_FAIL=1"
) else (
    echo [OK] Git found
)

REM Check jar command
where jar >nul 2>nul
if errorlevel 1 (
    echo [FAIL] jar command not found
    set "PREREQ_FAIL=1"
) else (
    echo [OK] jar found
)

if defined PREREQ_FAIL (
    echo.
    echo ERROR: Prerequisites check failed. Please install missing tools.
    exit /b 1
)

echo.
echo ============================================
echo   Setting up Patcher Tool
echo ============================================
echo.

REM Clone or update patcher repo
if exist "%PATCHER_DIR%" (
    echo Updating patcher repository...
    pushd "%PATCHER_DIR%"
    git pull --ff-only
    popd
) else (
    echo Cloning patcher repository...
    git clone "https://github.com/HytaleModding/patcher.git" "%PATCHER_DIR%"
    if errorlevel 1 (
        echo ERROR: Failed to clone patcher repository
        exit /b 1
    )
)

REM Setup Python venv
set "VENV_PATH=%PATCHER_DIR%\.venv"
set "VENV_PYTHON=%VENV_PATH%\Scripts\python.exe"

if not exist "%VENV_PYTHON%" (
    echo.
    echo Creating Python virtual environment...
    pushd "%PATCHER_DIR%"
    %PYTHON_CMD% -m venv .venv
    popd
)

REM Install requirements
echo.
echo Installing Python dependencies...
if exist "%PATCHER_DIR%\requirements.txt" (
    "%VENV_PYTHON%" -m pip install -r "%PATCHER_DIR%\requirements.txt" --quiet
)

REM Copy HytaleServer.jar to patcher directory
echo.
echo Copying HytaleServer.jar to patcher...
copy /y "%HYTALE_JAR%" "%PATCHER_DIR%\HytaleServer.jar" >nul

echo.
echo ============================================
echo   Running Decompilation
echo ============================================
echo.

REM Check if patcher already has decompiled output - if so, clean it for fresh decompile
set "PATCHER_OUTPUT=%PATCHER_DIR%\hytale-server"
if exist "%PATCHER_OUTPUT%" (
    echo Cleaning previous decompilation output...
    rmdir /s /q "%PATCHER_OUTPUT%"
)

REM Also clean work directory for fresh decompile
if exist "%PATCHER_DIR%\work" (
    rmdir /s /q "%PATCHER_DIR%\work"
)

echo This may take several minutes...
echo Decompiling com.hypixel package using Vineflower...
echo.

pushd "%PATCHER_DIR%"
set "HYTALESERVER_JAR_PATH=%PATCHER_DIR%\HytaleServer.jar"
"%VENV_PYTHON%" run.py setup
set "DECOMPILE_RESULT=!ERRORLEVEL!"
popd

if !DECOMPILE_RESULT! neq 0 (
    echo.
    echo ERROR: Decompilation failed with exit code: !DECOMPILE_RESULT!
    exit /b 1
)

echo.
echo Decompilation complete!

echo.
echo ============================================
echo   Updating lib folder
echo ============================================
echo.

REM Copy decompiled source
set "DECOMPILE_PATH=%PATCHER_DIR%\hytale-server\src\main\java\com"
set "LIB_SERVER_SRC=%LIB_DIR%\hytale-server\src\main\java"

if exist "%DECOMPILE_PATH%" (
    echo Copying decompiled source code...
    
    if exist "%LIB_SERVER_SRC%\com" (
        echo   Removing existing source...
        rmdir /s /q "%LIB_SERVER_SRC%\com"
    )
    
    if not exist "%LIB_SERVER_SRC%" mkdir "%LIB_SERVER_SRC%"
    
    echo   Copying new source...
    xcopy /s /e /i /q "%DECOMPILE_PATH%" "%LIB_SERVER_SRC%\com" >nul
    
    echo   Source code copied to: %LIB_SERVER_SRC%
) else (
    echo Warning: Decompiled source not found at: %DECOMPILE_PATH%
)

REM Copy HytaleServer.jar
echo.
echo Copying HytaleServer.jar...
copy /y "%HYTALE_JAR%" "%LIB_DIR%\HytaleServer.jar" >nul
echo   JAR copied to: %LIB_DIR%\HytaleServer.jar

REM Copy Server assets
if defined ASSETS_PATH (
    if exist "%ASSETS_PATH%\Server" (
        echo.
        echo Copying Server assets...
        
        if exist "%LIB_DIR%\Server" (
            echo   Removing existing Server assets...
            rmdir /s /q "%LIB_DIR%\Server"
        )
        
        xcopy /s /e /i /q "%ASSETS_PATH%\Server" "%LIB_DIR%\Server" >nul
        echo   Server assets copied to: %LIB_DIR%\Server
    )
)

REM Copy UI assets from Hytale launcher installation (has the actual .ui files)
REM Uses the 'latest' symlink which points to current build
set "UI_SOURCE=%APPDATA%\Hytale\install\pre-release\package\game\latest\Client\Data\Game\Interface"

if exist "%UI_SOURCE%" (
    echo.
    echo Copying UI assets from Hytale installation...
    echo   Source: %UI_SOURCE%
    
    if exist "%LIB_DIR%\UI" (
        echo   Removing existing UI assets...
        rmdir /s /q "%LIB_DIR%\UI"
    )
    
    xcopy /s /e /i /q "%UI_SOURCE%" "%LIB_DIR%\UI" >nul
    echo   UI assets copied to: %LIB_DIR%\UI
) else (
    echo Warning: UI folder not found at: %UI_SOURCE%
    echo   Make sure Hytale is installed via the launcher.
)

REM Save version info
echo %SERVER_VERSION%> "%SCRIPT_DIR%..\LAST_VERSION.txt"

echo.
echo ============================================
echo   Update Complete
echo ============================================
echo.
echo Updated to version: %SERVER_VERSION%
echo.
echo Lib folder structure:
echo   lib/
echo     HytaleServer.jar          (original JAR)
echo     hytale-server/src/main/   (decompiled source)
echo     Server/                   (server assets)
echo     UI/                       (UI assets)
echo.
echo Remember: Decompiled code may have errors - it's for reference only.
echo.
echo Next steps:
echo   1. Review changes with: git diff lib/
echo   2. Test your plugin with: Build and Deploy Plugin task
echo.

exit /b 0
