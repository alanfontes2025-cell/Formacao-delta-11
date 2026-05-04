@echo off
REM ===================================================================
REM  FORMACAO D-11 - Disparar Agentes (atalho Windows)
REM ===================================================================
REM
REM  Da duplo-clique neste arquivo DENTRO da pasta de um projeto
REM  com Delta-11 instalado. Ele dispara os agentes pendentes
REM  via disparar.sh.
REM ===================================================================

setlocal

REM Verificar se o bash do Git for Windows existe
set "GIT_BASH="
if exist "C:\Program Files\Git\bin\bash.exe" set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"
if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "GIT_BASH=C:\Program Files (x86)\Git\bin\bash.exe"

if "%GIT_BASH%"=="" (
    echo.
    echo ERRO: Git Bash nao encontrado.
    echo Instale o Git for Windows em: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

REM Verificar se estamos numa pasta com Delta-11 instalado
if not exist ".delta-11" (
    echo.
    echo ERRO: Pasta .delta-11 nao encontrada aqui.
    echo.
    echo Coloque este .bat (ou rode-o) DENTRO de um projeto com
    echo a Formacao D-11 instalada (criado via novo-projeto.sh).
    echo.
    pause
    exit /b 1
)

REM Se nao existe disparar.sh local, usar do repo da Formacao
if exist "disparar.sh" (
    set "DISPARAR_PATH=./disparar.sh"
) else (
    REM Fallback: tentar achar a Formacao D-11 instalada
    if exist "%~dp0disparar.sh" (
        set "DISPARAR_PATH=%~dp0disparar.sh"
    ) else (
        echo ERRO: disparar.sh nao encontrado.
        pause
        exit /b 1
    )
)

echo.
echo =====================================================
echo   FORMACAO D-11 - Disparando agentes
echo =====================================================
echo.

"%GIT_BASH%" -c "cd '%CD:\=/%' && bash %DISPARAR_PATH%"

echo.
pause
