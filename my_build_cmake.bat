@echo off

REM --- CONFIGURAZIONE DEI PERCORSI ---

SET "SCRIPT_DIR=%~dp0"
SET "BUILD_DIR=%SCRIPT_DIR%build"
SET "PROJECT_ROOT=%SCRIPT_DIR%..\..\.."

SET "BLAKE3_C_SRC_DIR=%SCRIPT_DIR%c"
SET "EXTERN_INCLUDE_DIR=%PROJECT_ROOT%\Extern\include\BLAKE3"
SET "EXTERN_LIB_DIR=%PROJECT_ROOT%\Extern\lib\BLAKE3"

echo.
echo Eseguito da: %SCRIPT_DIR%
echo Cartella di build: %BUILD_DIR%
echo Project root calcolato: %PROJECT_ROOT%
echo Destinazione include: %EXTERN_INCLUDE_DIR%
echo Destinazione lib: %EXTERN_LIB_DIR%
echo.

echo Compilando BLAKE3 con Runtime STATICO (/MTd e /MT)...

REM Pulizia build
REM if exist "%BUILD_DIR%" (
    REM rmdir /s /q "%BUILD_DIR%"
REM )
REM mkdir "%BUILD_DIR%" 2>nul

REM --- DEBUG (/MTd) ---
echo.
echo [1/4] Configurando BLAKE3 per Debug (x86) con Runtime /MTd...
cmake -S "%BLAKE3_C_SRC_DIR%" -B "%BUILD_DIR%\x86_debug" -G "Visual Studio 17 2022" -A Win32 -D BUILD_SHARED_LIBS:BOOL=OFF -D CMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreadedDebug -D BLAKE3_USE_TBB:BOOL=ON -D BLAKE3_FETCH_TBB:BOOL=ON
if %errorlevel% neq 0 exit /b %errorlevel%

echo [2/4] Compilando BLAKE3 per Debug (x86)...
cmake --build "%BUILD_DIR%\x86_debug" --config Debug
if %errorlevel% neq 0 exit /b %errorlevel%


REM --- RELEASE (/MT) ---
echo.
echo [3/4] Configurando BLAKE3 per Release (x86) con Runtime /MT...
cmake -S "%BLAKE3_C_SRC_DIR%" -B "%BUILD_DIR%\x86_release" -G "Visual Studio 17 2022" -A Win32 -D BUILD_SHARED_LIBS:BOOL=OFF -D CMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded -D BLAKE3_USE_TBB:BOOL=ON -D BLAKE3_FETCH_TBB:BOOL=ON
if %errorlevel% neq 0 exit /b %errorlevel%

echo [4/4] Compilando BLAKE3 per Release (x86)...
cmake --build "%BUILD_DIR%\x86_release" --config Release
if %errorlevel% neq 0 exit /b %errorlevel%


REM --- Copia dei file ---
echo.
echo Copiando gli artefatti nelle cartelle 'Extern'...
mkdir "%EXTERN_INCLUDE_DIR%" 2>nul
mkdir "%EXTERN_LIB_DIR%" 2>nul

copy "%BLAKE3_C_SRC_DIR%\blake3.h" "%EXTERN_INCLUDE_DIR%\"
copy "%BUILD_DIR%\x86_debug\Debug\blake3.lib" "%EXTERN_LIB_DIR%\blake3_d.lib"
copy "%BUILD_DIR%\x86_release\Release\blake3.lib" "%EXTERN_LIB_DIR%\blake3.lib"
copy "%BUILD_DIR%\x86_debug\msvc_19.44_cxx20_32_mt_debug\tbb12_debug.lib" "%EXTERN_LIB_DIR%\tbb12_debug.lib"
copy "%BUILD_DIR%\x86_release\msvc_19.44_cxx20_32_mt_release\tbb12.lib" "%EXTERN_LIB_DIR%\tbb12.lib"

echo.
echo La libreria BLAKE3 e' ora allineata con il tuo progetto (Runtime Statico).