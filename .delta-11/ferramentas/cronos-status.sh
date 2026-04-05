#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# CRONOS — Painel de Status da Formação D-11
# ═══════════════════════════════════════════════════════════════
#
# Verifica o estado de todos os agentes e retorna relatorio
# estruturado com: ACKs, locks, bloqueios e caminho critico.
#
# Uso:
#   bash .delta-11/ferramentas/cronos-status.sh
#   bash .delta-11/ferramentas/cronos-status.sh --resumo
#
# Nao precisa instalar nada — usa apenas ferramentas do sistema.
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

DELTA_DIR=".delta-11"
ATIVACOES_DIR="$DELTA_DIR/ativacoes"
LOCKS_DIR="$DELTA_DIR/locks"
KANBAN="$DELTA_DIR/kanban.md"
KANBAN_DATA="$DELTA_DIR/kanban-data.js"
MODO_RESUMO=false

if [[ "${1:-}" == "--resumo" ]]; then
    MODO_RESUMO=true
fi

AGENTES="ATLAS CRONOS FRONT PIXEL FORM BACK ENGINE VAULT SHIELD SCOUT"
RESULTADO_FINAL="OK"
ALERTAS=0

echo "═══════════════════════════════════════════════════"
echo "  CRONOS STATUS — Painel da Formacao D-11"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────────────
# 1. AGENTES ATIVOS (verificar ACKs)
# ───────────────────────────────────────────────────────

echo "[1/5] AGENTES ATIVOS"
echo "─────────────────────────────────────────────────"

ATIVOS=0
INATIVOS=0

for agente in $AGENTES; do
    ack_file="$ATIVACOES_DIR/ack-${agente}.txt"
    if [ -f "$ack_file" ]; then
        # Extrair timestamp do ACK
        ts=$(grep -o '"timestamp":"[^"]*"' "$ack_file" 2>/dev/null | cut -d'"' -f4 || echo "?")
        echo "  ATIVO   $agente (desde $ts)"
        ATIVOS=$((ATIVOS + 1))
    fi
done

if [ $ATIVOS -eq 0 ]; then
    echo "  Nenhum agente ativo no momento."
else
    echo ""
    echo "  Total: $ATIVOS agente(s) ativo(s)"
fi
echo ""

# ───────────────────────────────────────────────────────
# 2. LOCKS ATIVOS (verificar arquivos de trava)
# ───────────────────────────────────────────────────────

echo "[2/5] LOCKS ATIVOS"
echo "─────────────────────────────────────────────────"

if [ -d "$LOCKS_DIR" ]; then
    LOCK_COUNT=0
    LOCK_ORFAO=0
    NOW=$(date +%s)

    for lock_file in "$LOCKS_DIR"/*.lock 2>/dev/null; do
        [ -f "$lock_file" ] || continue
        LOCK_COUNT=$((LOCK_COUNT + 1))

        # Ler info do lock
        lock_agente=$(grep "^AGENTE:" "$lock_file" 2>/dev/null | sed 's/AGENTE: *//' || echo "?")
        lock_tarefa=$(grep "^TAREFA:" "$lock_file" 2>/dev/null | sed 's/TAREFA: *//' || echo "?")
        lock_arquivo=$(basename "$lock_file" .lock | sed 's/--/\//g')

        # Verificar idade do lock
        lock_age_sec=$(( NOW - $(stat -f %m "$lock_file" 2>/dev/null || stat -c %Y "$lock_file" 2>/dev/null || echo "$NOW") ))
        lock_age_min=$(( lock_age_sec / 60 ))

        if [ $lock_age_min -gt 30 ]; then
            # Lock orfao — mais de 30 min
            echo "  ORFAO  $lock_arquivo"
            echo "           Agente: $lock_agente | Tarefa: $lock_tarefa | Idade: ${lock_age_min}min"
            LOCK_ORFAO=$((LOCK_ORFAO + 1))
            ALERTAS=$((ALERTAS + 1))
        else
            echo "  ATIVO  $lock_arquivo"
            echo "           Agente: $lock_agente | Tarefa: $lock_tarefa | Idade: ${lock_age_min}min"
        fi
    done

    if [ $LOCK_COUNT -eq 0 ]; then
        echo "  Nenhum lock ativo."
    else
        echo ""
        echo "  Total: $LOCK_COUNT lock(s), $LOCK_ORFAO orfao(s)"
        if [ $LOCK_ORFAO -gt 0 ]; then
            RESULTADO_FINAL="ALERTA"
            echo "  ALERTA: Locks orfaos detectados! Agente pode ter morrido sem liberar."
        fi
    fi
else
    echo "  Pasta de locks nao encontrada."
fi
echo ""

# ───────────────────────────────────────────────────────
# 3. TAREFAS NO KANBAN (resumo por status)
# ───────────────────────────────────────────────────────

echo "[3/5] TAREFAS NO KANBAN"
echo "─────────────────────────────────────────────────"

if [ -f "$KANBAN" ]; then
    # Contar tarefas por secao
    a_fazer=$(grep -c "^- \[" "$KANBAN" 2>/dev/null || echo "0")
    fazendo=$(grep -c "^### FAZENDO\|^- .*FAZENDO" "$KANBAN" 2>/dev/null || echo "?")

    # Metodo mais robusto: contar por marcadores
    total_tarefas=$(grep -cE "^\- \[ \]|^\- \[x\]" "$KANBAN" 2>/dev/null || echo "0")
    concluidas=$(grep -c "^\- \[x\]" "$KANBAN" 2>/dev/null || echo "0")
    pendentes=$((total_tarefas - concluidas))

    echo "  Total: $total_tarefas tarefa(s)"
    echo "  Concluidas: $concluidas"
    echo "  Pendentes: $pendentes"

    # Verificar tarefas bloqueadas
    bloqueadas=$(grep -ci "bloqueado\|blocked\|depende de" "$KANBAN" 2>/dev/null || echo "0")
    if [ "$bloqueadas" -gt 0 ] 2>/dev/null; then
        echo "  Com dependencia: ~$bloqueadas mencionam 'depende de'"
    fi
else
    echo "  Kanban nao encontrado: $KANBAN"
fi
echo ""

# ───────────────────────────────────────────────────────
# 4. TRAVAS DE FASE (verificar transicoes)
# ───────────────────────────────────────────────────────

echo "[4/5] TRAVAS DE FASE"
echo "─────────────────────────────────────────────────"

TRAVA_ENCONTRADA=false
for i in 0 1 2 3 4 5; do
    trava_dir="$ATIVACOES_DIR/.trava-fase-$i"
    if [ -d "$trava_dir" ]; then
        owner=$(cat "$trava_dir/owner" 2>/dev/null || echo "?")
        echo "  TRAVA  Fase $i — dono: $owner"
        TRAVA_ENCONTRADA=true
    fi
done

if [ "$TRAVA_ENCONTRADA" = false ]; then
    echo "  Nenhuma trava de fase ativa."
fi
echo ""

# ───────────────────────────────────────────────────────
# 5. PROMPTS PENDENTES (ativacoes nao consumidas)
# ───────────────────────────────────────────────────────

echo "[5/5] PROMPTS PENDENTES"
echo "─────────────────────────────────────────────────"

if [ -d "$ATIVACOES_DIR" ]; then
    PROMPT_COUNT=0
    for f in "$ATIVACOES_DIR"/janela-*.txt "$ATIVACOES_DIR"/retomada-*.txt "$ATIVACOES_DIR"/erro-*.txt 2>/dev/null; do
        [ -f "$f" ] || continue
        PROMPT_COUNT=$((PROMPT_COUNT + 1))
        nome=$(basename "$f" .txt)
        tamanho=$(wc -c < "$f" | tr -d ' ')
        echo "  PENDENTE  $nome ($tamanho bytes)"
    done

    if [ $PROMPT_COUNT -eq 0 ]; then
        echo "  Nenhum prompt pendente."
    else
        echo ""
        echo "  Total: $PROMPT_COUNT prompt(s) aguardando dispatch"
    fi
else
    echo "  Pasta de ativacoes nao encontrada."
fi
echo ""

# ───────────────────────────────────────────────────────
# RELATORIO FINAL
# ───────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════"
if [ "$RESULTADO_FINAL" = "OK" ]; then
    echo "  RESULTADO: OK — Nenhum problema detectado"
else
    echo "  RESULTADO: ALERTA — $ALERTAS problema(s) encontrado(s)"
fi
echo "═══════════════════════════════════════════════════"
echo ""

exit $([ "$RESULTADO_FINAL" = "OK" ] && echo 0 || echo 1)
