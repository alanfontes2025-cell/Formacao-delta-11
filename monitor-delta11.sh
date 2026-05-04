#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# FORMAÇÃO Δ-11 — Monitor Invisível (substitui vigilante.sh)
# ═══════════════════════════════════════════════════════════════
#
# Executado pelo LaunchAgent a cada 5 minutos.
# NUNCA abre janela. NUNCA mexe no cursor. NUNCA usa AppleScript
# de window management. Apenas verifica arquivos e manda
# notificação discreta (popup no canto da tela).
#
# ═══════════════════════════════════════════════════════════════

LIMITE_SILENCIO=900  # 15 minutos sem heartbeat = agente morto
AGORA=$(date +%s)

# ─── Encontrar todos os projetos com Delta-11 ──────────────

PROJETOS=()

# Ler do registry se existir
REGISTRY="$HOME/.delta-11-registry.json"
if [ -f "$REGISTRY" ]; then
    while IFS= read -r linha; do
        # Expandir ~ para $HOME
        dir=$(echo "$linha" | sed "s|~|$HOME|g" | tr -d '",' | xargs)
        if [ -d "$dir/.delta-11" ]; then
            PROJETOS+=("$dir")
        fi
    done < <(grep -o '"[^"]*"' "$REGISTRY" | grep -v "version\|source\|github\|backup\|historical\|last_sync\|projects" | grep '/')
fi

# Busca adicional em diretórios comuns
for base in "$HOME/Documents/VSCODE" "$HOME/projetos" "$HOME/Downloads"; do
    [ -d "$base" ] || continue
    for dir in "$base"/*/; do
        [ -d "${dir}.delta-11" ] || continue
        # Evitar duplicatas
        ja_existe=0
        for p in "${PROJETOS[@]}"; do
            if [ "$p" = "${dir%/}" ]; then
                ja_existe=1
                break
            fi
        done
        if [ "$ja_existe" -eq 0 ]; then
            PROJETOS+=("${dir%/}")
        fi
    done
done

# ─── Verificar cada projeto ────────────────────────────────

ALERTAS=""
MORTES=""
TRAVADOS=""
STATUS_PROJETOS="["

for projeto in "${PROJETOS[@]}"; do
    DELTA_DIR="${projeto}/.delta-11"
    NOME_PROJETO=$(basename "$projeto")
    ATIVACOES="${DELTA_DIR}/ativacoes"

    [ -d "$ATIVACOES" ] || continue

    projeto_alertas=""

    # 1. Verificar arquivos de morte (agente morreu)
    for morte in "${ATIVACOES}/morte-"*.json; do
        [ -f "$morte" ] || continue
        agente=$(grep -o '"agente":"[^"]*"' "$morte" | head -1 | cut -d'"' -f4)
        morreu_em=$(grep -o '"morreu_em":"[^"]*"' "$morte" | head -1 | cut -d'"' -f4)
        motivo=$(grep -o '"motivo":"[^"]*"' "$morte" | head -1 | cut -d'"' -f4)

        MORTES="${MORTES}${agente} morreu em ${NOME_PROJETO} (${motivo})\n"
        projeto_alertas="${projeto_alertas}{\"tipo\":\"morte\",\"agente\":\"${agente}\",\"quando\":\"${morreu_em}\",\"motivo\":\"${motivo}\"},"
    done

    # 2. Verificar pulsos antigos (agente travou sem morrer)
    for pulso in "${ATIVACOES}/pulso-"*.json; do
        [ -f "$pulso" ] || continue
        agente=$(grep -o '"agente":"[^"]*"' "$pulso" | head -1 | cut -d'"' -f4)
        epoch=$(grep -o '"epoch":[0-9]*' "$pulso" | head -1 | cut -d':' -f2)
        status=$(grep -o '"status":"[^"]*"' "$pulso" | head -1 | cut -d'"' -f4)

        if [ -n "$epoch" ]; then
            silencio=$((AGORA - epoch))
            if [ "$silencio" -gt "$LIMITE_SILENCIO" ]; then
                min=$((silencio / 60))
                TRAVADOS="${TRAVADOS}${agente} sem pulso há ${min}min em ${NOME_PROJETO}\n"
                projeto_alertas="${projeto_alertas}{\"tipo\":\"travado\",\"agente\":\"${agente}\",\"silencio_min\":${min}},"
            fi
        fi
    done

    # 3. Verificar tarefas em FAZENDO sem agente ativo
    KANBAN="${DELTA_DIR}/kanban.md"
    if [ -f "$KANBAN" ]; then
        for agente_nome in ATLAS CRONOS FRONT PIXEL FORM BACK ENGINE VAULT SHIELD SCOUT; do
            # Tem tarefa em FAZENDO para esse agente?
            em_fazendo=$(grep -A5 "FAZENDO\|fazendo\|Em andamento" "$KANBAN" 2>/dev/null | grep -ci "$agente_nome" 2>/dev/null | tr -d '[:space:]')
            [ -z "$em_fazendo" ] && em_fazendo=0
            if [ "$em_fazendo" -gt 0 ]; then
                # Tem ack?
                if [ ! -f "${ATIVACOES}/ack-${agente_nome}.txt" ]; then
                    # Tem pulso recente?
                    if [ ! -f "${ATIVACOES}/pulso-${agente_nome}.json" ]; then
                        projeto_alertas="${projeto_alertas}{\"tipo\":\"orfa\",\"agente\":\"${agente_nome}\"},"
                    fi
                fi
            fi
        done
    fi

    # Montar status do projeto
    if [ -n "$projeto_alertas" ]; then
        # Remover vírgula final
        projeto_alertas="${projeto_alertas%,}"
        STATUS_PROJETOS="${STATUS_PROJETOS}{\"projeto\":\"${NOME_PROJETO}\",\"path\":\"${projeto}\",\"alertas\":[${projeto_alertas}]},"
    fi
done

# Fechar JSON
STATUS_PROJETOS="${STATUS_PROJETOS%,}]"

# ─── Gravar status em cada projeto (para o painel ler) ─────

for projeto in "${PROJETOS[@]}"; do
    DELTA_DIR="${projeto}/.delta-11"
    [ -d "$DELTA_DIR" ] || continue

    cat > "${DELTA_DIR}/monitor-status.json" << EOF
{
  "verificado_em": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "epoch": ${AGORA},
  "projetos": ${STATUS_PROJETOS}
}
EOF
done

# ─── Enviar notificacoes (SEM roubar foco) ─────────────────

# Detectar SO para escolher metodo de notificacao
case "$(uname -s)" in
    Darwin)               OS_KIND="macos"   ;;
    MINGW*|MSYS*|CYGWIN*) OS_KIND="windows" ;;
    Linux)
        if [ -n "$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/version 2>/dev/null; then
            OS_KIND="wsl"
        else
            OS_KIND="linux"
        fi
        ;;
    *)                    OS_KIND="desconhecido" ;;
esac

notificar_sistema() {
    local titulo="$1"
    local msg="$2"

    case "$OS_KIND" in
        macos)
            osascript -e "display notification \"$msg\" with title \"$titulo\" sound name \"Sosumi\"" 2>/dev/null
            ;;
        windows|wsl)
            powershell.exe -NoProfile -Command "
                Add-Type -AssemblyName System.Windows.Forms
                \$balloon = New-Object System.Windows.Forms.NotifyIcon
                \$balloon.Icon = [System.Drawing.SystemIcons]::Warning
                \$balloon.BalloonTipTitle = '$titulo'
                \$balloon.BalloonTipText = '$msg'
                \$balloon.Visible = \$true
                \$balloon.ShowBalloonTip(10000)
                Start-Sleep -Seconds 3
                \$balloon.Dispose()
            " 2>/dev/null
            ;;
        linux)
            command -v notify-send &>/dev/null && notify-send "$titulo" "$msg" 2>/dev/null
            ;;
    esac
}

if [ -n "$MORTES" ]; then
    MSG=$(echo -e "$MORTES" | head -3)
    notificar_sistema "D-11: Agente Morreu" "$MSG"
fi

if [ -n "$TRAVADOS" ]; then
    MSG=$(echo -e "$TRAVADOS" | head -3)
    notificar_sistema "D-11: Agente Travado" "$MSG"
fi

# ─── Log ───────────────────────────────────────────────────

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Verificados ${#PROJETOS[@]} projetos"
[ -n "$MORTES" ] && echo -e "  MORTES: $MORTES"
[ -n "$TRAVADOS" ] && echo -e "  TRAVADOS: $TRAVADOS"
[ -z "$MORTES" ] && [ -z "$TRAVADOS" ] && echo "  OK - Sem alertas"
