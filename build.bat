@echo off
setlocal

title Auto Invoice Editor - Build

cd /d "%~dp0"

echo.
echo ==========================================
echo       AUTO INVOICE EDITOR
echo       AUTOMATIC BUILDER
echo ==========================================
echo.

REM ==================================================
REM CEK PYTHON
REM ==================================================

where python >nul 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Python tidak ditemukan.
    echo.
    echo Silakan install Python terlebih dahulu.
    echo.
    pause
    exit /b 1
)

echo [OK] Python ditemukan.

REM ==================================================
REM BUAT VIRTUAL ENVIRONMENT
REM ==================================================

if not exist ".venv" (

    echo.
    echo [1/5] Membuat virtual environment...

    python -m venv .venv

    if errorlevel 1 (
        echo.
        echo [ERROR] Gagal membuat virtual environment.
        pause
        exit /b 1
    )

) else (

    echo [OK] Virtual environment sudah ada.

)

REM ==================================================
REM AKTIFKAN VENV
REM ==================================================

call ".venv\Scripts\activate.bat"

if errorlevel 1 (
    echo.
    echo [ERROR] Gagal mengaktifkan virtual environment.
    pause
    exit /b 1
)

REM ==================================================
REM INSTALL DEPENDENCY
REM ==================================================

echo.
echo [2/5] Memeriksa dependency...

python -m pip install --upgrade pip --quiet

python -m pip install -r requirements.txt --quiet

if errorlevel 1 (
    echo.
    echo [ERROR] Gagal menginstall dependency.
    echo.
    pause
    exit /b 1
)

echo [OK] Dependency siap.

REM ==================================================
REM HAPUS BUILD LAMA
REM ==================================================

echo.
echo [3/5] Membersihkan build lama...

if exist build (
    rmdir /s /q build
)

if exist dist (
    rmdir /s /q dist
)

if exist AutoInvoiceEditor.spec (
    del /q AutoInvoiceEditor.spec
)

REM ==================================================
REM BUILD EXE
REM ==================================================

echo.
echo [4/5] Membuat aplikasi Windows...
echo.
echo Mohon tunggu...
echo.

python -m PyInstaller ^
    --onedir ^
    --name AutoInvoiceEditor ^
    --noconsole ^
    --clean ^
    --add-data "templates;templates" ^
    app.py

if errorlevel 1 (
    echo.
    echo ==========================================
    echo BUILD GAGAL
    echo ==========================================
    echo.
    pause
    exit /b 1
)

REM ==================================================
REM BUAT START.BAT
REM ==================================================

echo.
echo [5/5] Membuat launcher...

(
echo @echo off
echo cd /d "%%~dp0"
echo start "" "%%~dp0AutoInvoiceEditor.exe"
) > "dist\AutoInvoiceEditor\Start.bat"

REM ==================================================
REM BUAT STOP.BAT
REM ==================================================

(
echo @echo off
echo taskkill /F /IM AutoInvoiceEditor.exe ^>nul 2^>nul
echo exit
) > "dist\AutoInvoiceEditor\Stop.bat"

REM ==================================================
REM BUAT README
REM ==================================================

(
echo AUTO INVOICE EDITOR
echo.
echo CARA MENJALANKAN:
echo.
echo 1. Klik dua kali Start.bat
echo 2. Browser akan terbuka otomatis
echo 3. Gunakan aplikasi
echo.
echo Untuk menghentikan aplikasi:
echo Klik dua kali Stop.bat
) > "dist\AutoInvoiceEditor\README.txt"

REM ==================================================
REM SELESAI
REM ==================================================

echo.
echo.
echo ==========================================
echo        BUILD BERHASIL!
echo ==========================================
echo.
echo Aplikasi berada di:
echo.
echo dist\AutoInvoiceEditor
echo.
echo Klik Start.bat untuk mencobanya.
echo.

start "" "dist\AutoInvoiceEditor"

echo.
echo Selesai.
echo.

pause