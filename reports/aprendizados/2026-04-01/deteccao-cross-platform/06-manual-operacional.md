# Manual Operacional — Detecção Cross-Platform para Delta-11

## 1. Detecção de SO (SEMPRE USAR ESTE BLOCO)

```bash
OS="desconhecido"
ARCH=$(uname -m)

case "$(uname -s)" in
    Darwin)
        OS="macos"
        ;;
    Linux)
        if [ -n "$WSL_DISTRO_NAME" ]; then
            OS="wsl"
        elif grep -qi microsoft /proc/version 2>/dev/null; then
            OS="wsl"
        else
            OS="linux"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        OS="windows"
        ;;
esac
```

### Saídas esperadas por plataforma

| Computador | uname -s | uname -m | OS detectado |
|-----------|----------|----------|-------------|
| MacBook Apple Silicon | Darwin | arm64 | macos |
| MacBook Intel | Darwin | x86_64 | macos |
| Windows Git Bash | MINGW64_NT-10.0-19045 | x86_64 | windows |
| Windows MSYS2 | MSYS_NT-10.0-19045 | x86_64 | windows |
| Ubuntu nativo | Linux | x86_64 | linux |
| Ubuntu no WSL | Linux | x86_64 | wsl |
| Raspberry Pi | Linux | aarch64 | linux |

## 2. Detecção de Modo de Execução (terminal vs VS Code)

```bash
MODO_EXECUCAO="terminal"

if [ -n "$VSCODE_PID" ]; then
    # Dentro do VS Code (extensão OU terminal integrado)
    if [ "$TERM_PROGRAM" = "vscode" ]; then
        MODO_EXECUCAO="vscode-terminal"  # Terminal integrado do VS Code
    else
        MODO_EXECUCAO="vscode-extensao"  # Extension host (Claude Code extensão)
    fi
fi
```

### Variáveis de ambiente confiáveis

| Variável | O que indica | Onde está presente | Confiabilidade |
|----------|-------------|-------------------|---------------|
| $VSCODE_PID | "Estou dentro do VS Code" | Terminal integrado + extension host | ALTA (mac/win/linux) |
| $TERM_PROGRAM | "vscode" = terminal integrado | Só terminal integrado | MÉDIA (pode falhar em cmd.exe) |
| $VSCODE_GIT_ASKPASS_NODE | VS Code spawnou este processo | Terminal integrado + extension host | MÉDIA |

### NUNCA USAR para detecção

| Método | Por que falha |
|--------|--------------|
| `command -v claude` | Ter o CLI instalado NÃO significa que o usuário está no terminal |
| `pgrep -x "Code"` | Falha quando processo se chama Electron ou Code Helper |
| Nome do .app hardcoded | Varia por instalação ("Visual Studio Code 2", etc) |

## 3. Detecção de VS Code Rodando (quando você NÃO está dentro dele)

```bash
vscode_esta_rodando() {
    case "$OS" in
        macos)
            pgrep -f "Visual Studio Code" > /dev/null 2>&1
            ;;
        windows)
            tasklist.exe /FI "IMAGENAME eq Code.exe" 2>NUL | grep -qi "Code.exe"
            ;;
        linux|wsl)
            pgrep -f "Visual Studio Code" > /dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}
```

### Por que `pgrep -f` e não `pgrep -x`

- `-x` = match EXATO do nome do processo → falha se o nome não é "Code" (ex: "Electron")
- `-f` = busca no caminho COMPLETO do comando → encontra "/Applications/Visual Studio Code.app/Contents/MacOS/Code"

## 4. Clipboard (copiar texto para colar depois)

```bash
copiar_para_clipboard() {
    local texto="$1"
    case "$OS" in
        macos)
            echo "$texto" | pbcopy
            ;;
        windows)
            echo "$texto" | clip.exe
            ;;
        linux)
            if command -v xclip &>/dev/null; then
                echo "$texto" | xclip -selection clipboard
            elif command -v xsel &>/dev/null; then
                echo "$texto" | xsel --clipboard --input
            elif command -v wl-copy &>/dev/null; then
                echo "$texto" | wl-copy
            else
                echo "ERRO: Instale xclip, xsel ou wl-clipboard"
                return 1
            fi
            ;;
        wsl)
            echo "$texto" | clip.exe  # clip.exe disponível no WSL2
            ;;
    esac
}
```

## 5. Auto-Dispatch por Plataforma

### macOS — osascript + bundle ID

```bash
disparar_macos_vscode() {
    local projeto="$1"
    local projeto_nome
    projeto_nome=$(basename "$projeto")

    osascript << APPLESCRIPT
set projectFolder to "$projeto_nome"

tell application "System Events"
    tell process "Code"
        set targetWindow to missing value
        repeat with w in windows
            try
                if title of w contains projectFolder then
                    set targetWindow to w
                    exit repeat
                end if
            end try
        end repeat
        if targetWindow is not missing value then
            perform action "AXRaise" of targetWindow
            delay 0.3
        end if
    end tell
end tell

tell application id "com.microsoft.VSCode"
    activate
end tell
delay 1.5

tell application "System Events"
    tell process "Code"
        set frontTitle to title of front window
        if frontTitle does not contain projectFolder then
            error "Janela errada: " & frontTitle
        end if
        keystroke "p" using {command down, shift down}
        delay 0.8
        keystroke "Claude Code: Open in New Tab"
        delay 1.2
        keystroke return
        delay 3.5
        keystroke "v" using {command down}
        delay 0.5
        keystroke return
    end tell
end tell
APPLESCRIPT
}

disparar_macos_terminal() {
    local projeto="$1"

    osascript << APPLESCRIPT
tell application "Terminal"
    activate
    delay 0.5
    tell application "System Events"
        tell process "Terminal"
            keystroke "t" using {command down}
        end tell
    end tell
    delay 1
    do script "cd '$projeto' && claude" in front window
    delay 6
    tell application "System Events"
        tell process "Terminal"
            keystroke "v" using {command down}
            delay 0.5
            keystroke return
        end tell
    end tell
end tell
APPLESCRIPT
}
```

### Windows — Windows Terminal ou cmd.exe

```bash
disparar_windows_terminal() {
    local projeto="$1"
    local prompt_arquivo="$2"

    # Copiar prompt para clipboard
    cat "$prompt_arquivo" | clip.exe

    # Detectar Windows Terminal
    if command -v wt.exe &>/dev/null 2>&1; then
        # Windows Terminal disponível (padrão no Win 11)
        wt.exe new-tab -- cmd /c "cd /d \"$projeto\" && claude" &
        sleep 6
        # Colar via PowerShell SendKeys (fallback)
        powershell.exe -Command "
            Add-Type -AssemblyName System.Windows.Forms
            Start-Sleep -Seconds 1
            [System.Windows.Forms.SendKeys]::SendWait('^v')
            Start-Sleep -Milliseconds 500
            [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        " &
    else
        # Fallback: abrir nova janela cmd
        start cmd /k "cd /d \"$projeto\" && claude"
        echo "Prompt copiado. Cole com Ctrl+V na janela que abriu."
    fi
}
```

### Linux — gnome-terminal ou fallback manual

```bash
disparar_linux_terminal() {
    local projeto="$1"
    local prompt_arquivo="$2"

    # Copiar para clipboard
    copiar_para_clipboard "$(cat "$prompt_arquivo")"

    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal --tab -- bash -c "cd '$projeto' && claude; exec bash" &
        sleep 6
        # xdotool para colar (se disponível)
        if command -v xdotool &>/dev/null; then
            xdotool key ctrl+shift+v
            sleep 0.5
            xdotool key Return
        else
            echo "Prompt copiado. Cole com Ctrl+Shift+V na aba que abriu."
        fi
    elif command -v konsole &>/dev/null; then
        konsole --new-tab -e bash -c "cd '$projeto' && claude; exec bash" &
        echo "Prompt copiado. Cole com Ctrl+Shift+V na aba que abriu."
    else
        echo "MODO MANUAL: Abra um terminal, cd para $projeto, rode 'claude', cole o prompt."
    fi
}
```

## 6. Função Mestre de Dispatch

```bash
disparar_agente() {
    local projeto="$1"
    local prompt_arquivo="$2"
    local agente_nome="$3"

    # Copiar prompt para clipboard
    copiar_para_clipboard "$(cat "$prompt_arquivo")"

    case "$OS" in
        macos)
            if [ "$MODO_EXECUCAO" = "vscode-extensao" ] || [ "$MODO_EXECUCAO" = "vscode-terminal" ]; then
                disparar_macos_vscode "$projeto"
            elif vscode_esta_rodando; then
                disparar_macos_vscode "$projeto"
            else
                disparar_macos_terminal "$projeto"
            fi
            ;;
        windows)
            disparar_windows_terminal "$projeto" "$prompt_arquivo"
            ;;
        linux)
            disparar_linux_terminal "$projeto" "$prompt_arquivo"
            ;;
        wsl)
            # WSL: usar PowerShell do Windows para dispatch
            disparar_windows_terminal "$projeto" "$prompt_arquivo"
            ;;
        *)
            echo "SO não reconhecido. Modo manual."
            echo "Prompt salvo em: $prompt_arquivo"
            ;;
    esac
}
```

## 7. Notificações Cross-Platform

```bash
notificar() {
    local titulo="$1"
    local mensagem="$2"

    case "$OS" in
        macos)
            osascript -e "display notification \"$mensagem\" with title \"$titulo\" sound name \"Sosumi\"" 2>/dev/null
            ;;
        windows|wsl)
            powershell.exe -Command "
                Add-Type -AssemblyName System.Windows.Forms
                \$b = New-Object System.Windows.Forms.NotifyIcon
                \$b.Icon = [System.Drawing.SystemIcons]::Warning
                \$b.BalloonTipTitle = '$titulo'
                \$b.BalloonTipText = '$mensagem'
                \$b.Visible = \$true
                \$b.ShowBalloonTip(10000)
                Start-Sleep -Seconds 3
                \$b.Dispose()
            " 2>/dev/null || echo -e "\a"
            ;;
        linux)
            if command -v notify-send &>/dev/null; then
                notify-send "$titulo" "$mensagem" 2>/dev/null
            else
                echo -e "\a"
            fi
            ;;
    esac
}
```

## 8. Tabela de Compatibilidade

| Funcionalidade | macOS | Windows Git Bash | Linux X11 | Linux Wayland | WSL |
|---------------|-------|-----------------|-----------|--------------|-----|
| Detectar SO | uname -s = Darwin | uname -s = MINGW* | uname -s = Linux | uname -s = Linux | $WSL_DISTRO_NAME |
| Detectar VS Code ativo | $VSCODE_PID | $VSCODE_PID | $VSCODE_PID | $VSCODE_PID | $VSCODE_PID |
| Detectar VS Code rodando | pgrep -f | tasklist.exe | pgrep -f | pgrep -f | tasklist.exe |
| Clipboard | pbcopy | clip.exe | xclip/xsel | wl-copy | clip.exe |
| Dispatch VS Code | osascript + bundle ID | SendKeys (frágil) | xdotool (X11 só) | manual | PowerShell |
| Dispatch Terminal | osascript Terminal.app | wt.exe / start cmd | gnome-terminal | gnome-terminal | wt.exe |
| Notificação | osascript notification | PowerShell NotifyIcon | notify-send | notify-send | PowerShell |

## 9. NUNCA FAZER (erros já cometidos)

| Erro | Consequência | Correção |
|------|-------------|----------|
| `pgrep -x "Code"` | Não encontra VS Code em alguns Macs | `pgrep -f "Visual Studio Code"` |
| `tell application "Visual Studio Code"` | Falha se nome do .app é diferente | `tell application id "com.microsoft.VSCode"` |
| `command -v claude` → assumir terminal | Ter CLI instalado ≠ estar usando no terminal | Verificar $VSCODE_PID primeiro |
| Assumir `pgrep` existe no Windows | pgrep NÃO existe no Git Bash | Usar `tasklist.exe` |
| Não verificar janela após activate | Keystrokes vão pro projeto errado | `title of front window contains projectFolder` |
