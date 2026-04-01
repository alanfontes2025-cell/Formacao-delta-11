#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DELTA-11 — Hook PreCompact: Alerta de Contexto Enchendo
# ═══════════════════════════════════════════════════════════════
# Dispara ANTES do Claude Code comprimir o contexto (sinal de
# que a conversa está ficando longa demais). Injeta um alerta
# no contexto do agente para que ele execute o protocolo de
# reset ANTES de perder capacidade.
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

# Descobrir qual agente está ativo
AGENTE=""
for ack in "${DELTA_DIR}/ativacoes/ack-"*.txt; do
    [ -f "$ack" ] || continue
    nome=$(basename "$ack" | sed 's/^ack-//' | sed 's/\.txt$//')
    if [ -n "$nome" ]; then
        AGENTE="$nome"
        break
    fi
done

if [ -z "$AGENTE" ]; then
    exit 0
fi

# Atualizar pulso com status de alerta
PULSO_FILE="${DELTA_DIR}/ativacoes/pulso-${AGENTE}.json"
AGORA=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EPOCH=$(date +%s)

cat > "$PULSO_FILE" << EOF
{
  "agente": "${AGENTE}",
  "status": "contexto_critico",
  "ultimo_update": "${AGORA}",
  "epoch": ${EPOCH},
  "projeto": "$(basename "$CWD")"
}
EOF

# Retornar mensagem que será injetada no contexto do agente
# (Claude Code lê stdout do hook e adiciona ao contexto)
cat << 'EOF'
{
  "systemMessage": "[ALERTA DELTA-11] Seu contexto está sendo comprimido. Isso significa que você está perto do limite. EXECUTE AGORA o Protocolo de Contexto Esgotado: (1) Salve TUDO no seu arquivo de estado, (2) Atualize o kanban, (3) Gere o prompt de retomada em .delta-11/ativacoes/retomada-SEU-NOME.txt, (4) Avise o comandante. NÃO continue trabalhando sem fazer isso primeiro."
}
EOF

exit 0
