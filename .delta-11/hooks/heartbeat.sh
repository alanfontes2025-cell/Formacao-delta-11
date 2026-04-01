#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DELTA-11 — Hook PostToolUse: Heartbeat (Batimento Cardíaco)
# ═══════════════════════════════════════════════════════════════
# Dispara DEPOIS de cada ação do agente. Atualiza o arquivo de
# pulso com timestamp, sinalizando "estou vivo e trabalhando".
#
# O monitor externo (LaunchAgent) verifica esses pulsos a cada
# 5 minutos. Se um pulso parar de ser atualizado, o agente morreu.
# ═══════════════════════════════════════════════════════════════

# Ler input JSON do stdin (Claude Code envia dados do hook)
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

# Descobrir qual agente está ativo neste projeto (lê o ack mais recente)
AGENTE=""
for ack in "${DELTA_DIR}/ativacoes/ack-"*.txt; do
    [ -f "$ack" ] || continue
    # Extrair nome do agente do filename: ack-NOME.txt
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

# Extrair nome da ferramenta usada (opcional, pra contexto)
TOOL=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4)

# Extrair session_id (opcional)
SESSION=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | head -1 | cut -d'"' -f4)

# Atualizar arquivo de pulso
PULSO_FILE="${DELTA_DIR}/ativacoes/pulso-${AGENTE}.json"
AGORA=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EPOCH=$(date +%s)

cat > "$PULSO_FILE" << EOF
{
  "agente": "${AGENTE}",
  "status": "ativo",
  "ultimo_update": "${AGORA}",
  "epoch": ${EPOCH},
  "ultima_tool": "${TOOL}",
  "session_id": "${SESSION}",
  "projeto": "$(basename "$CWD")"
}
EOF

exit 0
