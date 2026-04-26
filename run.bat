@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Typr / WhisperX Launcher
echo ========================================

:: Check for Node.js
echo [1/4] Checking Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. 
    echo Please install it from https://nodejs.org/
    pause
    exit /b 1
)
node --version

:: Check for Rust
echo [2/4] Checking Rust...
where cargo >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Rust/Cargo is not installed. 
    echo Please install it from https://rustup.rs/
    pause
    exit /b 1
)
cargo --version

:: Install dependencies if node_modules doesn't exist
if not exist "node_modules\" (
    echo [3/4] Installing Node.js dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] npm install failed.
        pause
        exit /b 1
    )
) else (
    echo [3/4] Node.js dependencies already installed.
)

:: Check for whisper-cpp sidecar
echo [4/4] Checking Whisper sidecar...
set "BIN_DIR=src-tauri\binaries"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

:: Determine target triple
for /f "tokens=2" %%i in ('rustc -Vv ^| findstr "host:"') do set "TARGET=%%i"
echo Target detected: %TARGET%

set "SIDECAR_NAME=whisper-cpp-%TARGET%.exe"
if not exist "%BIN_DIR%\%SIDECAR_NAME%" (
    echo [WARNING] whisper-cpp sidecar missing: %BIN_DIR%\%SIDECAR_NAME%
    echo Local transcription will not work without it.
    echo Please ensure the binary is placed in %BIN_DIR%
) else (
    echo Sidecar found: %SIDECAR_NAME%
)

echo.
echo Starting Typr...
echo ========================================
call npm run tauri dev

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Application crashed or failed to start.
    echo See the errors above.
    pause
)

pause
