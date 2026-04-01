#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DELTA-11 — Hook Stop: Sinal de Morte do Agente
# ═══════════════════════════════════════════════════════════════
# Dispara quando a sessão do Claude Code ENCERRA (por qualquer
# motivo: contexto esgotado, janela fechada, erro, ou término
# normal). Grava um registro de morte e limpa sinais de atividade.
#
# O monitor externo (LaunchAgent) lê esses registros e notifica
# o comandante sobre agentes que morreram.
# ═══════════════════════════════════════════════════════════════

# Ler input JSON do stdin
INPUT=$(cat)

# Extrair diretório de trabalho
CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$CWD" ]; then
    CWD=$(pwd)
fi

# Verificar se é um projeto Delta-11
DELTA_DIR="${CWD}/.delta-11"
if [ ! -d "$DELTA_DIR" ]; then
    exit 0
fi

# Descobrir qual agente está ativo neste projeto
AGENTE=""
for ack in "${DELTA_DIR}/ativacoes/ack-"*.txt; do
    [ -f "$ack" ] || continue
    nome=$(basename "$ack" | sed 's/^ack-//' | sed 's/\.txt$//')
    if [ -n "$nome" ]; then
        AGENTE="$nome"
        break
    fi
done

# Se não encontrou agente ativo, não faz nada
if [ -z "$AGENTE" ]; then
    exit 0
fi

# Extrair motivo da parada (se disponível)
MOTIVO=$(echo "$INPUT" | grep -o '"reason":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$MOTIVO" ]; then
    MOTIVO="sessao_encerrada"
fi

# Ler última tarefa do pulso (se existir)
PULSO_FILE="${DELTA_DIR}/ativacoes/pulso-${AGENTE}.json"
ULTIMA_TOOL=""
if [ -f "$PULSO_FILE" ]; then
    ULTIMA_TOOL=$(grep -o '"ultima_tool":"[^"]*"' "$PULSO_FILE" | head -1 | cut -d'"' -f4)
fi

# Gravar registro de morte
AGORA=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MORTE_FILE="${DELTA_DIR}/ativacoes/morte-${AGENTE}.json"

cat > "$MORTE_FILE" << EOF
{
  "agente": "${AGENTE}",
  "morreu_em": "${AGORA}",
  "motivo": "${MOTIVO}",
  "ultima_tool": "${ULTIMA_TOOL}",
  "projeto": "$(basename "$CWD")"
}
EOF

# Remover sinais de atividade
rm -f "${DELTA_DIR}/ativacoes/ack-${AGENTE}.txt"
rm -f "${DELTA_DIR}/ativacoes/pulso-${AGENTE}.json"

exit 0
