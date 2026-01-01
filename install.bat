@echo off
echo ========================================
echo   ROBLOX ARAC SISTEMI - KURULUM
echo ========================================
echo.

:: Rojo kontrolu
where rojo >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [!] Rojo bulunamadi!
    echo [*] Rojo'yu yuklemek icin: https://rojo.space/docs/v7/getting-started/installation/
    echo.
    echo Alternatif: Aftman ile yukleyin:
    echo   1. https://github.com/LPGhatguy/aftman/releases adresinden aftman indirin
    echo   2. "aftman install" komutunu calistirin
    echo.
    pause
    exit /b 1
)

echo [✓] Rojo bulundu!
echo.
echo [*] Roblox Studio'da projeyi acmak icin:
echo.
echo     1. Roblox Studio'yu acin
echo     2. Yeni bir place olusturun veya mevcut place'i acin
echo     3. Bu klasorde terminal acin ve su komutu calistirin:
echo.
echo        rojo serve
echo.
echo     4. Studio'da Rojo plugin'ini acin ve "Connect" butonuna basin
echo.
echo ========================================
echo   VEYA TEK KOMUTLA RBXL DOSYASI OLUSTURUN:
echo ========================================
echo.
echo     rojo build -o CarSystem.rbxl
echo.
echo ========================================

:: Otomatik build
echo.
set /p choice="Simdi .rbxl dosyasi olusturulsun mu? (E/H): "
if /i "%choice%"=="E" (
    echo.
    echo [*] CarSystem.rbxl olusturuluyor...
    rojo build -o CarSystem.rbxl
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo [✓] CarSystem.rbxl basariyla olusturuldu!
        echo [*] Dosyayi Roblox Studio ile acabilirsiniz.
    ) else (
        echo [!] Hata olustu!
    )
)

echo.
pause
