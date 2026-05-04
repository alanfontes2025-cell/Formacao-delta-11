@echo off
REM ===================================================================
REM  FORMACAO D-11 - Criar Projeto Novo (atalho Windows)
REM ===================================================================
REM
REM  Da duplo-clique neste arquivo no Windows Explorer.
REM  Ele pede o caminho do projeto novo e roda novo-projeto.sh
REM  por baixo dos panos (via Git Bash).
REM
REM  Pre-requisito: Git for Windows instalado (traz o bash).
REM ===================================================================

setlocal

REM Detectar pasta deste script (raiz da Formacao D-11)
set "FORMACAO_DIR=%~dp0"

REM Verificar se o bash do Git for Windows existe
set "GIT_BASH="
if exist "C:\Program Files\Git\bin\bash.exe" set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"
if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "GIT_BASH=C:\Program Files (x86)\Git\bin\bash.exe"

if "%GIT_BASH%"=="" (
    echo.
    echo ERRO: Git Bash nao encontrado.
    echo.
    echo Instale o Git for Windows em:
    echo   https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo.
echo =====================================================
echo   FORMACAO D-11 - Criar Projeto Novo
echo =====================================================
echo.
echo  Caminho da Formacao: %FORMACAO_DIR%
echo.

set /p "TARGET=Caminho completo da pasta nova (ex: C:\Users\%USERNAME%\projetos\meu-app): "

if "%TARGET%"=="" (
    echo.
    echo ERRO: Caminho vazio. Abortando.
    pause
    exit /b 1
)

echo.
echo  Criando projeto em: %TARGET%
echo.

REM Converter caminho Windows para formato Git Bash e rodar o script
"%GIT_BASH%" -c "cd '%FORMACAO_DIR:\=/%' && bash ./novo-projeto.sh '%TARGET:\=/%'"

echo.
pause
