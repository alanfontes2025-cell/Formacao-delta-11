#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# FORMACAO D-11 — Disparar Agentes (Cross-Platform)
# ═══════════════════════════════════════════════════════════════
#
# Funciona em: macOS + Windows (Git Bash) + Linux
#
# Este script le os prompts de ativacao gerados pelos agentes
# e abre uma nova instancia do Claude Code para cada agente,
# com o prompt ja colado e enviado automaticamente.
#
# MODOS DE DISPATCH (detectado automaticamente):
#   terminal-app  — Abre aba no terminal nativo com claude CLI
#   vscode-tab    — Abre tab no VS Code via extensao Claude Code
#   manual        — Mostra instrucoes para o comandante colar manualmente
#
# Como usar:
#   ./disparar.sh                      # Dispara TODOS os agentes pendentes
#   ./disparar.sh VAULT                # Dispara apenas o agente VAULT
#   ./disparar.sh --list               # Lista agentes disponiveis sem disparar
#   ./disparar.sh --mode=terminal-app  # Forca modo terminal
#   ./disparar.sh --mode=vscode-tab    # Forca modo extensao VS Code
#   ./disparar.sh --mode=manual        # Forca modo manual
#   ./disparar.sh --detect             # Re-detecta o modo automaticamente
#
# Os prompts ficam em .delta-11/ativacoes/*.txt
#
# ═══════════════════════════════════════════════════════════════

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ATIVACOES_DIR=".delta-11/ativacoes"
DISPATCH_MODE_FILE=".delta-11/.dispatch-mode"
PROJECT_PATH=$(pwd)

# ═══════════════════════════════════════════════════════════════
# DETECCAO DE SO (cross-platform)
# ═══════════════════════════════════════════════════════════════

OS_TYPE="desconhecido"
case "$(uname -s)" in
    Darwin)                    OS_TYPE="macos" ;;
    Linux)
        if [ -n "$WSL_DISTRO_NAME" ]; then
            OS_TYPE="wsl"
        elif grep -qi microsoft /proc/version 2>/dev/null; then
            OS_TYPE="wsl"
        else
            OS_TYPE="linux"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)     OS_TYPE="windows" ;;
esac

# ═══════════════════════════════════════════════════════════════
# FUNCOES CROSS-PLATFORM
# ═══════════════════════════════════════════════════════════════

copiar_para_clipboard() {
    local arquivo="$1"
    case "$OS_TYPE" in
        macos)
            cat "$arquivo" | pbcopy
            ;;
        windows|wsl)
            cat "$arquivo" | clip.exe 2>/dev/null || cat "$arquivo" | pbcopy 2>/dev/null || return 1
            ;;
        linux)
            if command -v xclip &>/dev/null; then
                cat "$arquivo" | xclip -selection clipboard
            elif command -v xsel &>/dev/null; then
                cat "$arquivo" | xsel --clipboard --input
            elif command -v wl-copy &>/dev/null; then
                cat "$arquivo" | wl-copy
            else
                echo -e "  ${RED}Clipboard indisponivel. Instale xclip, xsel ou wl-clipboard.${NC}"
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

vscode_esta_rodando() {
    case "$OS_TYPE" in
        macos)
            pgrep -f "Visual Studio Code" > /dev/null 2>&1
            ;;
        windows)
            tasklist.exe /FI "IMAGENAME eq Code.exe" 2>/dev/null | grep -qi "Code.exe" 2>/dev/null
            ;;
        wsl)
            tasklist.exe /FI "IMAGENAME eq Code.exe" 2>/dev/null | grep -qi "Code.exe" 2>/dev/null
            ;;
        linux)
            pgrep -f "Visual Studio Code" > /dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

claude_cli_disponivel() {
    command -v claude &>/dev/null
}

# ═══════════════════════════════════════════════════════════════
# PERFIL DO AGENTE — Especializacao real por agente
# ═══════════════════════════════════════════════════════════════
#
# Le .delta-11/perfis/[AGENTE].json e constroi o comando claude
# com flags especificas: --model, --mcp-config, --allowedTools
#
# Se o perfil nao existir, retorna "claude" (comportamento padrao).
# Se jq nao estiver instalado, retorna "claude" (fallback seguro).
#
# ═══════════════════════════════════════════════════════════════

PERFIS_DIR=".delta-11/perfis"

construir_comando_claude() {
    local nome="$1"
    local perfil_arquivo="$PERFIS_DIR/${nome}.json"
    local cmd="claude"

    # Fallback: sem perfil ou sem jq → comando padrao
    if [ ! -f "$perfil_arquivo" ]; then
        echo "$cmd"
        return 0
    fi

    if ! command -v jq &>/dev/null; then
        echo -e "  ${YELLOW}Aviso: jq nao instalado. Perfil de ${nome} ignorado.${NC}" >&2
        echo -e "  ${DIM}Instale com: brew install jq${NC}" >&2
        echo "$cmd"
        return 0
    fi

    # Ler campos do perfil
    local model
    model=$(jq -r '.model // empty' "$perfil_arquivo")
    local mcp_config
    mcp_config=$(jq -r '.mcp_config // empty' "$perfil_arquivo")
    local append_prompt
    append_prompt=$(jq -r '.append_system_prompt // empty' "$perfil_arquivo")

    # Construir comando com flags
    [ -n "$model" ] && cmd="$cmd --model $model"
    [ -n "$mcp_config" ] && [ -f "$mcp_config" ] && cmd="$cmd --mcp-config $mcp_config"
    [ -n "$append_prompt" ] && cmd="$cmd --append-system-prompt '$append_prompt'"

    # Allowed tools (array → lista separada por espaco)
    local tools
    tools=$(jq -r '.allowed_tools // [] | if length > 0 then join(" ") else empty end' "$perfil_arquivo")
    [ -n "$tools" ] && cmd="$cmd --allowedTools $tools"

    # Disallowed tools
    local disallowed
    disallowed=$(jq -r '.disallowed_tools // [] | if length > 0 then join(" ") else empty end' "$perfil_arquivo")
    [ -n "$disallowed" ] && cmd="$cmd --disallowedTools $disallowed"

    echo "$cmd"
}

# Prefixar prompt com /model para modo vscode-tab
# (VS Code nao aceita --model via CLI, entao injetamos /model no prompt)
prefixar_modelo_no_prompt() {
    local nome="$1"
    local arquivo_prompt="$2"
    local perfil_arquivo="$PERFIS_DIR/${nome}.json"

    if [ ! -f "$perfil_arquivo" ] || ! command -v jq &>/dev/null; then
        return 0
    fi

    local model
    model=$(jq -r '.model // empty' "$perfil_arquivo")

    if [ -n "$model" ]; then
        # Criar arquivo temporario com /model prefixado
        local temp_file
        temp_file=$(mktemp)
        echo "/model $model" > "$temp_file"
        echo "" >> "$temp_file"
        cat "$arquivo_prompt" >> "$temp_file"
        # Substituir o arquivo original
        mv "$temp_file" "$arquivo_prompt"
    fi
}

# Extrair nome do agente do arquivo de ativacao
extrair_nome_agente() {
    local arquivo="$1"
    local basename_sem_ext
    basename_sem_ext=$(basename "$arquivo" .txt)

    # Patterns: janela-1-VAULT, janela-SHIELD-revisao-T010-FRONT, retomada-ENGINE, erro-SCOUT
    # Tentar extrair o nome do agente do conteudo do arquivo primeiro
    if command -v grep &>/dev/null; then
        local agente_no_conteudo
        agente_no_conteudo=$(grep -oE 'Agente: (ATLAS|CRONOS|FRONT|PIXEL|FORM|BACK|ENGINE|VAULT|SHIELD|SCOUT)' "$arquivo" 2>/dev/null | head -1 | sed 's/Agente: //')
        if [ -n "$agente_no_conteudo" ]; then
            echo "$agente_no_conteudo"
            return 0
        fi
    fi

    # Fallback: tentar pelo nome do arquivo
    for agente in ATLAS CRONOS FRONT PIXEL FORM BACK ENGINE VAULT SHIELD SCOUT; do
        if echo "$basename_sem_ext" | grep -q "$agente"; then
            echo "$agente"
            return 0
        fi
    done

    # Nao encontrado
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# DETECCAO DE MODO
# ═══════════════════════════════════════════════════════════════

detectar_modo() {
    # $VSCODE_PID tem prioridade ABSOLUTA — é a realidade do ambiente atual
    # Sobrescreve qualquer valor gravado em disco
    if [ -n "$VSCODE_PID" ]; then
        echo "vscode-tab" > "$DISPATCH_MODE_FILE"
        echo "vscode-tab"
        return 0
    fi

    # Se NÃO está no VS Code, verificar preferência salva
    if [ -f "$DISPATCH_MODE_FILE" ]; then
        local modo_salvo
        modo_salvo=$(cat "$DISPATCH_MODE_FILE" | tr -d '[:space:]')
        # Se o arquivo diz vscode-tab mas $VSCODE_PID não existe,
        # significa que não estamos no VS Code — corrigir
        if [ "$modo_salvo" = "vscode-tab" ]; then
            # Não estamos no VS Code agora — verificar se CLI existe
            if claude_cli_disponivel; then
                echo "terminal-app" > "$DISPATCH_MODE_FILE"
                echo "terminal-app"
                return 0
            fi
        elif [[ "$modo_salvo" == "terminal-app" || "$modo_salvo" == "manual" ]]; then
            echo "$modo_salvo"
            return 0
        fi
    fi

    # Detecção automática
    if claude_cli_disponivel; then
        echo "terminal-app" > "$DISPATCH_MODE_FILE"
        echo "terminal-app"
        return 0
    fi

    # Nada encontrado
    echo "manual" > "$DISPATCH_MODE_FILE"
    echo "manual"
}

# ═══════════════════════════════════════════════════════════════
# HEALTH CHECK
# ═══════════════════════════════════════════════════════════════

verificar_saude() {
    local modo="$1"

    if [ "$modo" = "terminal-app" ]; then
        # Verificar se claude CLI esta disponivel
        if ! claude_cli_disponivel; then
            echo -e "${RED}x Comando 'claude' nao encontrado no PATH.${NC}"
            echo "  Instale o Claude Code CLI: npm install -g @anthropic-ai/claude-code"
            return 1
        fi

        # Verificar terminal nativo por SO
        case "$OS_TYPE" in
            macos)
                if ! osascript -e 'tell application "Terminal" to activate' &>/dev/null; then
                    echo -e "${RED}x Nao foi possivel ativar o Terminal.app.${NC}"
                    echo "  Verifique as permissoes de Acessibilidade em:"
                    echo "  System Settings > Privacy & Security > Accessibility"
                    return 1
                fi
                ;;
            windows|wsl)
                # Windows Terminal ou cmd.exe — sempre disponivel
                ;;
            linux)
                # Verificar se algum terminal esta disponivel
                if ! command -v gnome-terminal &>/dev/null && ! command -v konsole &>/dev/null && ! command -v xterm &>/dev/null; then
                    echo -e "${YELLOW}Aviso: nenhum terminal conhecido encontrado (gnome-terminal, konsole, xterm).${NC}"
                    echo "  O dispatch pode abrir uma janela nova em vez de aba."
                fi
                ;;
        esac

    elif [ "$modo" = "vscode-tab" ]; then
        # Verificar se VS Code esta rodando
        if ! vscode_esta_rodando; then
            echo -e "${RED}x VS Code nao esta rodando.${NC}"
            echo "  Abra o VS Code antes de disparar agentes."
            return 1
        fi

        # Verificar automacao por SO
        case "$OS_TYPE" in
            macos)
                if ! osascript -e 'tell application id "com.microsoft.VSCode" to activate' &>/dev/null; then
                    echo -e "${RED}x Nao foi possivel ativar o VS Code.${NC}"
                    echo "  Verifique as permissoes de Acessibilidade em:"
                    echo "  System Settings > Privacy & Security > Accessibility"
                    return 1
                fi
                ;;
            windows|wsl)
                echo -e "  ${YELLOW}Aviso: dispatch vscode-tab no Windows usa automacao limitada.${NC}"
                echo -e "  ${DIM}Recomendado: use --mode=terminal-app para melhor resultado.${NC}"
                ;;
            linux)
                if ! command -v xdotool &>/dev/null; then
                    echo -e "  ${YELLOW}Aviso: xdotool nao encontrado. Dispatch vscode-tab pode falhar.${NC}"
                    echo -e "  ${DIM}Instale com: sudo apt install xdotool${NC}"
                fi
                ;;
        esac

    elif [ "$modo" = "manual" ]; then
        return 0
    fi

    return 0
}

# ═══════════════════════════════════════════════════════════════
# AVISO ANTI-COLISAO
# ═══════════════════════════════════════════════════════════════

aviso_anti_colisao() {
    local nome="$1"
    local modo="$2"
    local destino="Terminal.app"
    if [ "$modo" = "vscode-tab" ]; then
        destino="VS Code"
    fi

    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}║${NC}  ${BOLD}ABRINDO NOVA JANELA${NC}                                        ${RED}║${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}║${NC}  Disparando: ${BOLD}${CYAN}${nome}${NC}                                       ${RED}║${NC}"
    echo -e "${RED}║${NC}  Destino:    ${DIM}${destino}${NC}                                       ${RED}║${NC}"
    echo -e "${RED}║${NC}  Projeto:    ${DIM}${PROJECT_PATH}${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}║${NC}  ${YELLOW}NAO MOVA O MOUSE. NAO DIGITE NADA.${NC}                          ${RED}║${NC}"
    echo -e "${RED}║${NC}  ${YELLOW}Aguarde 5 segundos...${NC}                                       ${RED}║${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    sleep 5
}

# ═══════════════════════════════════════════════════════════════
# ESTRATEGIA 1: TERMINAL NATIVO COM CLAUDE CLI (recomendado)
# ═══════════════════════════════════════════════════════════════
#
# Cada agente roda como processo claude CLI independente em
# uma aba/janela separada do terminal. Zero conflito de lock file.
#
# ═══════════════════════════════════════════════════════════════

disparar_terminal_app() {
    local projeto="$PROJECT_PATH"

    case "$OS_TYPE" in
        macos)
            disparar_terminal_macos "$projeto"
            ;;
        windows)
            disparar_terminal_windows "$projeto"
            ;;
        wsl)
            disparar_terminal_wsl "$projeto"
            ;;
        linux)
            disparar_terminal_linux "$projeto"
            ;;
        *)
            echo -e "  ${RED}SO nao suportado para dispatch automatico: $OS_TYPE${NC}"
            return 1
            ;;
    esac
}

disparar_terminal_macos() {
    local projeto="$1"
    local claude_cmd="${CLAUDE_CMD:-claude}"

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
    do script "cd '$projeto' && $claude_cmd" in front window
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

disparar_terminal_windows() {
    local projeto="$1"
    local claude_cmd="${CLAUDE_CMD:-claude}"
    # Converter path do Git Bash para Windows (ex: /c/Users/... → C:\Users\...)
    local projeto_win
    projeto_win=$(cd "$projeto" && pwd -W 2>/dev/null || echo "$projeto")

    if command -v wt.exe &>/dev/null; then
        # Windows Terminal disponivel (padrao no Win 11)
        wt.exe new-tab --title "D11" -- cmd /c "cd /d \"$projeto_win\" && $claude_cmd" &
        sleep 6
        # Tentar colar via PowerShell SendKeys
        powershell.exe -Command "
            Add-Type -AssemblyName System.Windows.Forms
            Start-Sleep -Seconds 1
            [System.Windows.Forms.SendKeys]::SendWait('^v')
            Start-Sleep -Milliseconds 500
            [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        " 2>/dev/null &
    else
        # Fallback: nova janela cmd
        start cmd /k "cd /d \"$projeto_win\" && $claude_cmd" 2>/dev/null || \
            cmd.exe /c "start cmd /k \"cd /d $projeto_win && $claude_cmd\"" 2>/dev/null
        sleep 6
        echo -e "  ${YELLOW}Prompt copiado. Cole com Ctrl+V na janela que abriu.${NC}"
    fi
}

disparar_terminal_wsl() {
    local projeto="$1"
    local claude_cmd="${CLAUDE_CMD:-claude}"
    # WSL: usar PowerShell do Windows para abrir nova janela
    if command -v wt.exe &>/dev/null; then
        wt.exe new-tab -- wsl.exe -d "$WSL_DISTRO_NAME" -- bash -c "cd '$projeto' && $claude_cmd" &
        sleep 6
        powershell.exe -Command "
            Add-Type -AssemblyName System.Windows.Forms
            Start-Sleep -Seconds 1
            [System.Windows.Forms.SendKeys]::SendWait('^v')
            Start-Sleep -Milliseconds 500
            [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        " 2>/dev/null &
    else
        # Fallback manual
        echo -e "  ${YELLOW}Abra um novo terminal WSL e rode:${NC}"
        echo -e "  ${CYAN}cd '$projeto' && $claude_cmd${NC}"
        echo -e "  ${YELLOW}Depois cole o prompt com Ctrl+Shift+V${NC}"
    fi
}

disparar_terminal_linux() {
    local projeto="$1"
    local claude_cmd="${CLAUDE_CMD:-claude}"

    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal --tab -- bash -c "cd '$projeto' && $claude_cmd; exec bash" 2>/dev/null &
        sleep 6
        # Tentar colar via xdotool
        if command -v xdotool &>/dev/null; then
            xdotool key ctrl+shift+v 2>/dev/null
            sleep 0.5
            xdotool key Return 2>/dev/null
        else
            echo -e "  ${YELLOW}Prompt copiado. Cole com Ctrl+Shift+V na aba que abriu.${NC}"
        fi
    elif command -v konsole &>/dev/null; then
        konsole --new-tab -e bash -c "cd '$projeto' && $claude_cmd; exec bash" 2>/dev/null &
        sleep 6
        echo -e "  ${YELLOW}Prompt copiado. Cole com Ctrl+Shift+V na aba que abriu.${NC}"
    elif command -v xterm &>/dev/null; then
        xterm -e "cd '$projeto' && $claude_cmd" 2>/dev/null &
        sleep 6
        echo -e "  ${YELLOW}Prompt copiado. Cole com Ctrl+Shift+V na janela que abriu.${NC}"
    else
        echo -e "  ${RED}Nenhum terminal encontrado (gnome-terminal, konsole, xterm).${NC}"
        echo -e "  ${YELLOW}Abra um terminal manualmente, cd para '$projeto' e rode '$claude_cmd'.${NC}"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# ESTRATEGIA 2: VS CODE TAB
# ═══════════════════════════════════════════════════════════════
#
# Abre nova aba do Claude Code dentro do VS Code via extensao.
# ATENCAO: Multiplas instancias podem causar conflito de lock
# file (bug #13287/#13499). Use terminal-app quando possivel.
#
# ═══════════════════════════════════════════════════════════════

disparar_vscode_tab() {
    local projeto="$PROJECT_PATH"

    case "$OS_TYPE" in
        macos)
            disparar_vscode_macos "$projeto"
            ;;
        windows|wsl)
            disparar_vscode_windows "$projeto"
            ;;
        linux)
            disparar_vscode_linux "$projeto"
            ;;
        *)
            echo -e "  ${RED}SO nao suportado para vscode-tab: $OS_TYPE${NC}"
            return 1
            ;;
    esac
}

disparar_vscode_macos() {
    local projeto="$1"
    local projeto_nome
    projeto_nome=$(basename "$projeto")

    # Targeting por titulo de janela + bundle ID (universal)
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
            error "Janela errada no topo: " & frontTitle & " (esperava " & projectFolder & ")"
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

disparar_vscode_windows() {
    local projeto="$1"

    # No Windows, abrir o projeto no VS Code e usar PowerShell SendKeys
    # para Ctrl+Shift+P → "Claude Code: Open in New Tab"
    code "$projeto" 2>/dev/null || true
    sleep 2

    powershell.exe -Command "
        Add-Type -AssemblyName System.Windows.Forms
        # Ctrl+Shift+P para Command Palette
        [System.Windows.Forms.SendKeys]::SendWait('^+p')
        Start-Sleep -Milliseconds 800
        # Digitar comando
        [System.Windows.Forms.SendKeys]::SendWait('Claude Code: Open in New Tab')
        Start-Sleep -Milliseconds 1200
        # Enter
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep -Seconds 4
        # Ctrl+V para colar
        [System.Windows.Forms.SendKeys]::SendWait('^v')
        Start-Sleep -Milliseconds 500
        # Enter para enviar
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
    " 2>/dev/null

    if [ $? -ne 0 ]; then
        echo -e "  ${RED}SendKeys falhou.${NC}"
        echo -e "  ${YELLOW}O prompt foi copiado. Abra o VS Code e cole manualmente.${NC}"
        return 1
    fi
}

disparar_vscode_linux() {
    local projeto="$1"

    # No Linux, usar xdotool para enviar teclas ao VS Code
    code "$projeto" 2>/dev/null || true
    sleep 2

    if command -v xdotool &>/dev/null; then
        # Ctrl+Shift+P para Command Palette
        xdotool key ctrl+shift+p 2>/dev/null
        sleep 0.8
        # Digitar comando
        xdotool type --clearmodifiers "Claude Code: Open in New Tab" 2>/dev/null
        sleep 1.2
        # Enter
        xdotool key Return 2>/dev/null
        sleep 4
        # Ctrl+V para colar
        xdotool key ctrl+v 2>/dev/null
        sleep 0.5
        # Enter para enviar
        xdotool key Return 2>/dev/null
    else
        echo -e "  ${YELLOW}xdotool nao encontrado. Instale com: sudo apt install xdotool${NC}"
        echo -e "  ${YELLOW}O prompt foi copiado. Abra o VS Code e cole manualmente.${NC}"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# ESTRATEGIA 3: MANUAL (fallback)
# ═══════════════════════════════════════════════════════════════

disparar_manual() {
    local arquivo="$1"
    local nome="$2"

    echo ""
    echo -e "  ${YELLOW}[MANUAL]${NC} Auto-dispatch indisponivel para ${BOLD}${nome}${NC}."
    echo -e "  O prompt esta salvo em: ${CYAN}${arquivo}${NC}"
    echo ""
    echo -e "  Para ativar este agente manualmente:"
    echo -e "  1. Abra um terminal"
    echo -e "  2. cd $PROJECT_PATH"
    echo -e "  3. claude"
    echo -e "  4. Cole o conteudo do arquivo acima"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# FUNCAO PRINCIPAL: Disparar um agente
# ═══════════════════════════════════════════════════════════════

disparar_agente() {
    local arquivo="$1"
    local nome="$2"
    local modo="$3"

    # Extrair nome do agente para buscar perfil
    local agente_nome
    agente_nome=$(extrair_nome_agente "$arquivo")

    if [ -n "$agente_nome" ]; then
        local perfil_arquivo="$PERFIS_DIR/${agente_nome}.json"
        if [ -f "$perfil_arquivo" ] && command -v jq &>/dev/null; then
            local model_info
            model_info=$(jq -r '.model // empty' "$perfil_arquivo")
            [ -n "$model_info" ] && echo -e "  ${DIM}Modelo: ${model_info}${NC}"
            local mcp_info
            mcp_info=$(jq -r '.mcp_config // empty' "$perfil_arquivo")
            [ -n "$mcp_info" ] && [ -f "$mcp_info" ] && echo -e "  ${DIM}MCP: ${mcp_info}${NC}"
        fi
    fi

    if [ "$modo" = "manual" ]; then
        disparar_manual "$arquivo" "$nome"
        return 0
    fi

    # Aviso visual anti-colisao
    aviso_anti_colisao "$nome" "$modo"

    # Para vscode-tab: prefixar prompt com /model ANTES de copiar
    if [ "$modo" = "vscode-tab" ] && [ -n "$agente_nome" ]; then
        prefixar_modelo_no_prompt "$agente_nome" "$arquivo"
    fi

    # Copiar prompt para clipboard (cross-platform)
    if ! copiar_para_clipboard "$arquivo"; then
        echo -e "  ${RED}Falha ao copiar para clipboard. Caindo para modo manual.${NC}"
        disparar_manual "$arquivo" "$nome"
        return 0
    fi

    # Disparar conforme o modo
    local resultado=0

    if [ "$modo" = "terminal-app" ]; then
        # Construir comando especializado com perfil do agente
        local CLAUDE_CMD="claude"
        if [ -n "$agente_nome" ]; then
            CLAUDE_CMD=$(construir_comando_claude "$agente_nome")
        fi
        export CLAUDE_CMD
        disparar_terminal_app || resultado=$?
    elif [ "$modo" = "vscode-tab" ]; then
        disparar_vscode_tab || resultado=$?
    fi

    # Se falhou, cair para manual
    if [ $resultado -ne 0 ]; then
        echo -e "  ${RED}x Dispatch falhou. Caindo para modo manual.${NC}"
        disparar_manual "$arquivo" "$nome"
    fi

    return 0
}

# ═══════════════════════════════════════════════════════════════
# PARSE DE ARGUMENTOS
# ═══════════════════════════════════════════════════════════════

FILTRO=""
MODO_LISTA=false
FORCE_MODE=""
FORCE_DETECT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --list)
            MODO_LISTA=true
            shift
            ;;
        --mode=*)
            FORCE_MODE="${1#*=}"
            shift
            ;;
        --detect)
            FORCE_DETECT=true
            shift
            ;;
        --help|-h)
            echo ""
            echo -e "${BOLD}FORMACAO D-11 — Disparar Agentes${NC}"
            echo ""
            echo "  Uso: ./disparar.sh [OPCOES] [AGENTE]"
            echo ""
            echo "  Opcoes:"
            echo "    --list               Lista agentes disponiveis sem disparar"
            echo "    --mode=MODO          Forca um modo: terminal-app, vscode-tab, manual"
            echo "    --detect             Re-detecta o modo automaticamente"
            echo "    --help               Mostra esta ajuda"
            echo ""
            echo "  Exemplos:"
            echo "    ./disparar.sh                      Dispara todos os agentes"
            echo "    ./disparar.sh VAULT                Dispara apenas o VAULT"
            echo "    ./disparar.sh --mode=terminal-app  Forca modo Terminal.app"
            echo "    ./disparar.sh --detect             Re-detecta e mostra o modo"
            echo ""
            echo "  Modos de dispatch:"
            echo "    terminal-app   Abre aba no Terminal.app com claude CLI (recomendado)"
            echo "    vscode-tab     Abre tab no VS Code via extensao (pode travar com muitos agentes)"
            echo "    manual         Mostra instrucoes para colar manualmente"
            echo ""
            exit 0
            ;;
        *)
            FILTRO="$1"
            shift
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════
# HEADER
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  FORMACAO D-11 — Disparando Agentes [${OS_TYPE}]${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# DETECCAO DE MODO
# ═══════════════════════════════════════════════════════════════

if [ "$FORCE_DETECT" = true ]; then
    rm -f "$DISPATCH_MODE_FILE"
    DISPATCH_MODE=$(detectar_modo)
    echo -e "  Modo re-detectado: ${BOLD}${GREEN}${DISPATCH_MODE}${NC}"
    echo -e "  Salvo em: ${DIM}${DISPATCH_MODE_FILE}${NC}"
    echo ""
    if [ "$MODO_LISTA" = false ] && [ -z "$FILTRO" ]; then
        exit 0
    fi
elif [ -n "$FORCE_MODE" ]; then
    if [[ "$FORCE_MODE" != "terminal-app" && "$FORCE_MODE" != "vscode-tab" && "$FORCE_MODE" != "manual" ]]; then
        echo -e "${RED}x Modo invalido: $FORCE_MODE${NC}"
        echo "  Modos validos: terminal-app, vscode-tab, manual"
        exit 1
    fi
    DISPATCH_MODE="$FORCE_MODE"
    echo -e "  Modo forcado: ${BOLD}${YELLOW}${DISPATCH_MODE}${NC}"
else
    DISPATCH_MODE=$(detectar_modo)
    echo -e "  Modo de dispatch: ${BOLD}${GREEN}${DISPATCH_MODE}${NC}"
fi

# Explicacao do modo para o comandante
case $DISPATCH_MODE in
    terminal-app)
        echo -e "  ${DIM}Cada agente vai abrir em uma aba do Terminal.app${NC}"
        ;;
    vscode-tab)
        echo -e "  ${DIM}Cada agente vai abrir em uma aba do Claude Code no VS Code${NC}"
        echo -e "  ${YELLOW}Aviso: muitos agentes no mesmo VS Code podem causar lentidao${NC}"
        ;;
    manual)
        echo -e "  ${DIM}Os prompts serao exibidos para voce colar manualmente${NC}"
        ;;
esac
echo ""

# ═══════════════════════════════════════════════════════════════
# VERIFICAR PASTA DE ATIVACOES
# ═══════════════════════════════════════════════════════════════

if [ ! -d "$ATIVACOES_DIR" ]; then
    echo -e "${RED}x Pasta $ATIVACOES_DIR nao encontrada.${NC}"
    echo ""
    echo "  O ATLAS ainda nao gerou os prompts de ativacao."
    echo "  Primeiro, abra o Claude Code e inicie com: d11"
    echo "  Quando o ATLAS terminar o planejamento,"
    echo "  ele vai criar os arquivos de ativacao automaticamente."
    echo "  Depois, rode este script."
    echo ""
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# LISTAR ARQUIVOS DE ATIVACAO
# ═══════════════════════════════════════════════════════════════

if [ -n "$FILTRO" ]; then
    ARQUIVOS=($(ls "$ATIVACOES_DIR"/*"$FILTRO"*.txt 2>/dev/null | grep -v -E '/(ack|pulso|morte)-' || true))
else
    ARQUIVOS=($(ls "$ATIVACOES_DIR"/*.txt 2>/dev/null | grep -v -E '/(ack|pulso|morte)-' || true))
fi

if [ ${#ARQUIVOS[@]} -eq 0 ]; then
    echo -e "${RED}x Nenhum arquivo de ativacao encontrado${NC}"
    if [ -n "$FILTRO" ]; then
        echo "  Filtro usado: $FILTRO"
        echo "  Arquivos disponiveis:"
        ls "$ATIVACOES_DIR"/*.txt 2>/dev/null | while read f; do
            echo "    - $(basename "$f" .txt)"
        done
    fi
    echo ""
    exit 1
fi

echo -e "  Encontrados ${BOLD}${#ARQUIVOS[@]} agente(s)${NC} para ativar:"
echo ""

for arquivo in "${ARQUIVOS[@]}"; do
    nome=$(basename "$arquivo" .txt)
    tamanho=$(wc -c < "$arquivo" | tr -d ' ')
    echo -e "    > ${CYAN}${nome}${NC} (${tamanho} bytes)"
done

echo ""

# Modo lista: so mostra e sai
if [ "$MODO_LISTA" = true ]; then
    echo "  Use ./disparar.sh para disparar todos."
    echo "  Use ./disparar.sh NOME para disparar um especifico."
    echo ""
    exit 0
fi

# ═══════════════════════════════════════════════════════════════
# HEALTH CHECK
# ═══════════════════════════════════════════════════════════════

if ! verificar_saude "$DISPATCH_MODE"; then
    echo ""
    echo -e "  ${YELLOW}Dica: tente outro modo com --mode=terminal-app ou --mode=manual${NC}"
    echo ""
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# CONFIRMACAO
# ═══════════════════════════════════════════════════════════════

read -p "  Disparar agora? (s/n): " CONFIRMA

if [[ "$CONFIRMA" != "s" && "$CONFIRMA" != "S" ]]; then
    echo "  Abortado."
    exit 0
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# LOOP DE DISPATCH
# ═══════════════════════════════════════════════════════════════

CONTADOR=0
DELAY_ENTRE_AGENTES=8

if [ "$DISPATCH_MODE" = "vscode-tab" ]; then
    DELAY_ENTRE_AGENTES=5
elif [ "$DISPATCH_MODE" = "manual" ]; then
    DELAY_ENTRE_AGENTES=0
fi

for arquivo in "${ARQUIVOS[@]}"; do
    nome=$(basename "$arquivo" .txt)
    CONTADOR=$((CONTADOR + 1))

    echo -e "  ${YELLOW}[$CONTADOR/${#ARQUIVOS[@]}]${NC} Ativando ${BOLD}${nome}${NC}..."

    disparar_agente "$arquivo" "$nome" "$DISPATCH_MODE"

    if [ $CONTADOR -lt ${#ARQUIVOS[@]} ] && [ $DELAY_ENTRE_AGENTES -gt 0 ]; then
        echo -e "  ${CYAN}Aguardando ${DELAY_ENTRE_AGENTES}s antes do proximo agente...${NC}"
        sleep "$DELAY_ENTRE_AGENTES"
    fi
done

# ═══════════════════════════════════════════════════════════════
# CONCLUSAO
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  OK ${CONTADOR} agente(s) disparado(s) com sucesso${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

case $DISPATCH_MODE in
    terminal-app)
        echo -e "  Cada agente esta rodando em uma aba/janela do terminal."
        case "$OS_TYPE" in
            macos)  echo -e "  Alterne entre as abas com ${BOLD}Cmd+Shift+[${NC} e ${BOLD}Cmd+Shift+]${NC}" ;;
            *)      echo -e "  Alterne entre as abas/janelas do terminal." ;;
        esac
        ;;
    vscode-tab)
        echo -e "  Cada agente esta rodando em uma aba do Claude Code no VS Code."
        echo -e "  Alterne entre as abas dentro do VS Code."
        ;;
    manual)
        echo -e "  Os prompts foram exibidos acima."
        echo -e "  Abra um terminal para cada agente, cd para o projeto, rode 'claude', e cole."
        ;;
esac

echo ""
echo -e "  Para acompanhar o progresso:"
echo -e "  > Abra o painel visual: .delta-11/painel.html"
echo ""
