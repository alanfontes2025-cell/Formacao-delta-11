#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# FORMAÇÃO Δ-11 — Vigilante (Monitor de Atividade)
# ═══════════════════════════════════════════════════════════════
#
# O que este script faz:
# Fica rodando no fundo verificando se os agentes Delta-11
# estão trabalhando. Se ninguém se mexe por 15 minutos,
# manda uma notificação no Mac com som e tenta redespachar
# agentes que ficaram pendentes.
#
# Como usar:
#   ./vigilante.sh              # Inicia o vigilante (roda até você fechar)
#   ./vigilante.sh --once       # Verifica uma vez e sai
#   ./vigilante.sh --stop       # Para o vigilante rodando em background
#
# O vigilante verifica a cada 5 minutos.
# Para parar: Ctrl+C ou feche a janela do terminal.
#
# ═══════════════════════════════════════════════════════════════

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Configuração
INTERVALO=300          # Verificar a cada 5 minutos (em segundos)
LIMITE_SILENCIO=900    # Alertar após 15 minutos sem atividade (em segundos)
PID_FILE="/tmp/delta11-vigilante-$$.pid"
PROJECT_PATH="$(pwd)"

# ─── Funções ─────────────────────────────────────────────────

verificar_delta11() {
    if [ ! -d ".delta-11" ]; then
        echo -e "${RED}Erro: pasta .delta-11 não encontrada.${NC}"
        echo "Execute este script na pasta raiz de um projeto com Delta-11 instalado."
        exit 1
    fi
}

ultimo_toque() {
    # Encontra o arquivo mais recentemente modificado no .delta-11/
    # Olha: kanban-data.js, activity-log.md, ack-*.txt, *-estado.md
    local mais_recente=0

    for arquivo in \
        .delta-11/kanban-data.js \
        .delta-11/kanban.md \
        .delta-11/activity-log.md \
        .delta-11/memoria/*-estado.md \
        .delta-11/ativacoes/ack-*.txt
    do
        if [ -f "$arquivo" ]; then
            local mtime
            mtime=$(stat -f "%m" "$arquivo" 2>/dev/null || echo "0")
            if [ "$mtime" -gt "$mais_recente" ] 2>/dev/null; then
                mais_recente=$mtime
            fi
        fi
    done

    echo "$mais_recente"
}

agentes_ativos() {
    # Conta quantos agentes têm ACK (estão ativos)
    local count=0
    for ack in .delta-11/ativacoes/ack-*.txt; do
        [ -f "$ack" ] && count=$((count + 1))
    done
    echo "$count"
}

prompts_pendentes() {
    # Conta prompts de ativação que existem MAS não têm ACK correspondente
    local pendentes=0
    local lista=""

    for prompt in .delta-11/ativacoes/janela-*.txt .delta-11/ativacoes/retomada-*.txt; do
        [ -f "$prompt" ] || continue

        # Extrair nome do agente do arquivo
        local agente=""
        agente=$(grep -m1 "^Agente:" "$prompt" 2>/dev/null | sed 's/Agente: *//' | tr -d '[:space:]')

        if [ -n "$agente" ]; then
            local ack=".delta-11/ativacoes/ack-${agente}.txt"
            if [ ! -f "$ack" ]; then
                pendentes=$((pendentes + 1))
                lista="$lista $agente"
            fi
        fi
    done

    echo "$pendentes|$lista"
}

notificar() {
    local titulo="$1"
    local mensagem="$2"

    # Notificação nativa do macOS com som
    osascript -e "display notification \"$mensagem\" with title \"$titulo\" sound name \"Sosumi\"" 2>/dev/null
}

tentar_redespacho() {
    local agente="$1"

    if [ -x "./disparar.sh" ]; then
        echo -e "  ${YELLOW}→ Tentando redespachar ${agente}...${NC}"
        ./disparar.sh "$agente" 2>/dev/null
        return $?
    else
        echo -e "  ${RED}→ disparar.sh não encontrado ou não executável${NC}"
        return 1
    fi
}

exibir_status() {
    local agora
    agora=$(date +%s)
    local ultimo
    ultimo=$(ultimo_toque)
    local silencio=0

    if [ "$ultimo" -gt 0 ] 2>/dev/null; then
        silencio=$((agora - ultimo))
    fi

    local ativos
    ativos=$(agentes_ativos)

    local resultado_pendentes
    resultado_pendentes=$(prompts_pendentes)
    local num_pendentes
    num_pendentes=$(echo "$resultado_pendentes" | cut -d'|' -f1)
    local lista_pendentes
    lista_pendentes=$(echo "$resultado_pendentes" | cut -d'|' -f2)

    # Formatar tempo de silêncio
    local min=$((silencio / 60))
    local seg=$((silencio % 60))

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Δ-11 VIGILANTE — $(date '+%H:%M:%S')${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "  Projeto:           ${DIM}$(basename "$PROJECT_PATH")${NC}"
    echo -e "  Agentes ativos:    ${GREEN}${ativos}${NC}"
    echo -e "  Último movimento:  ${min}m${seg}s atrás"
    echo -e "  Prompts pendentes: ${num_pendentes}"

    if [ "$silencio" -gt "$LIMITE_SILENCIO" ]; then
        echo ""
        echo -e "  ${RED}${BOLD}⚠ SISTEMA PARADO HÁ ${min} MINUTOS${NC}"

        if [ "$num_pendentes" -gt 0 ]; then
            echo -e "  ${YELLOW}Agentes não despachados:${lista_pendentes}${NC}"
        fi

        return 1  # Parado
    else
        echo -e "  ${GREEN}✓ Sistema ativo${NC}"
        return 0  # OK
    fi
}

ciclo_verificacao() {
    exibir_status
    local parado=$?

    if [ "$parado" -eq 1 ]; then
        # Sistema parado — notificar
        local ativos
        ativos=$(agentes_ativos)
        local resultado_pendentes
        resultado_pendentes=$(prompts_pendentes)
        local num_pendentes
        num_pendentes=$(echo "$resultado_pendentes" | cut -d'|' -f1)
        local lista_pendentes
        lista_pendentes=$(echo "$resultado_pendentes" | cut -d'|' -f2)

        notificar "Δ-11 TRAVADO" "Sistema parado. ${num_pendentes} agente(s) pendente(s):${lista_pendentes}"

        # Tentar redespachar agentes pendentes
        if [ "$num_pendentes" -gt 0 ]; then
            echo ""
            echo -e "  ${BOLD}Tentando redespachar agentes pendentes...${NC}"

            for agente in $lista_pendentes; do
                tentar_redespacho "$agente"
                sleep 8  # Esperar entre dispatches (regra do Delta-11)
            done
        fi
    fi
}

# ─── Tratamento de argumentos ────────────────────────────────

case "${1:-}" in
    --once)
        verificar_delta11
        ciclo_verificacao
        exit 0
        ;;
    --stop)
        # Parar todos os vigilantes deste projeto
        for pid_file in /tmp/delta11-vigilante-*.pid; do
            [ -f "$pid_file" ] || continue
            local_path=$(head -1 "$pid_file" 2>/dev/null)
            if [ "$local_path" = "$(pwd)" ]; then
                pid=$(basename "$pid_file" | sed 's/delta11-vigilante-//' | sed 's/.pid//')
                kill "$pid" 2>/dev/null && echo "Vigilante $pid parado." || echo "Vigilante $pid já não existia."
                rm -f "$pid_file"
            fi
        done
        exit 0
        ;;
    --help|-h)
        echo "Uso: ./vigilante.sh [--once|--stop|--help]"
        echo ""
        echo "  (sem argumentos)  Inicia monitoramento contínuo"
        echo "  --once            Verifica uma vez e sai"
        echo "  --stop            Para o vigilante rodando em background"
        echo "  --help            Mostra esta ajuda"
        exit 0
        ;;
esac

# ─── Loop principal ──────────────────────────────────────────

verificar_delta11

# Salvar PID para --stop
echo "$(pwd)" > "$PID_FILE"

# Limpar PID ao sair
trap "rm -f '$PID_FILE'; echo ''; echo 'Vigilante encerrado.'; exit 0" INT TERM

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Δ-11 VIGILANTE — Iniciando monitoramento${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Verificando a cada: ${BOLD}$((INTERVALO / 60)) minutos${NC}"
echo -e "  Alerta após:       ${BOLD}$((LIMITE_SILENCIO / 60)) minutos${NC} sem atividade"
echo -e "  Para parar:        ${DIM}Ctrl+C${NC}"

while true; do
    ciclo_verificacao
    echo ""
    echo -e "  ${DIM}Próxima verificação em $((INTERVALO / 60)) minutos...${NC}"
    sleep "$INTERVALO"
done
