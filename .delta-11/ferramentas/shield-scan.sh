#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SHIELD — Varredura de Seguranca Completa
# ═══════════════════════════════════════════════════════════════
#
# Roda 3 verificacoes de seguranca e retorna relatorio unificado:
#   1. Semgrep (SAST — analise estatica de codigo)
#   2. npm audit (vulnerabilidades em dependencias)
#   3. Deteccao de secrets (chaves, tokens, senhas no codigo)
#
# Uso: bash .delta-11/ferramentas/shield-scan.sh [diretorio]
#   Se nao passar diretorio, usa o diretorio atual.
#
# Retorna: PASS (sem problemas) ou FAIL (com detalhes)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

ALVO="${1:-.}"
RESULTADO_FINAL="PASS"
RELATORIO=""

echo "═══════════════════════════════════════════════════"
echo "  SHIELD SCAN — Varredura de Seguranca"
echo "  Alvo: $ALVO"
echo "═══════════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────────────
# 1. SEMGREP (SAST)
# ───────────────────────────────────────────────────────

echo "[1/3] Semgrep (analise estatica de codigo)..."

if command -v semgrep &>/dev/null; then
    SEMGREP_OUTPUT=$(semgrep --config auto --json --quiet "$ALVO" 2>/dev/null || true)
    SEMGREP_COUNT=$(echo "$SEMGREP_OUTPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(len(data.get('results',[])))" 2>/dev/null || echo "0")

    if [ "$SEMGREP_COUNT" -gt 0 ] 2>/dev/null; then
        RESULTADO_FINAL="FAIL"
        RELATORIO="$RELATORIO\n[SEMGREP] $SEMGREP_COUNT vulnerabilidade(s) encontrada(s):"
        RELATORIO="$RELATORIO\n$(echo "$SEMGREP_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data.get('results', []):
    print(f\"  - {r.get('check_id','?')}: {r.get('path','?')}:{r.get('start',{}).get('line','?')} — {r.get('extra',{}).get('message','sem descricao')}\")
" 2>/dev/null || echo "  (erro ao parsear resultados)")"
        echo "  FAIL — $SEMGREP_COUNT problema(s)"
    else
        echo "  PASS — nenhuma vulnerabilidade"
    fi
else
    echo "  SKIP — semgrep nao instalado (pip install semgrep)"
    RELATORIO="$RELATORIO\n[SEMGREP] SKIP — nao instalado"
fi

# ───────────────────────────────────────────────────────
# 2. NPM AUDIT (dependencias)
# ───────────────────────────────────────────────────────

echo "[2/3] npm audit (vulnerabilidades em dependencias)..."

if [ -f "$ALVO/package.json" ] && command -v npm &>/dev/null; then
    AUDIT_OUTPUT=$(cd "$ALVO" && npm audit --json 2>/dev/null || true)
    AUDIT_VULNS=$(echo "$AUDIT_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
meta = data.get('metadata', {}).get('vulnerabilities', {})
total = meta.get('high', 0) + meta.get('critical', 0)
print(total)
" 2>/dev/null || echo "0")

    if [ "$AUDIT_VULNS" -gt 0 ] 2>/dev/null; then
        RESULTADO_FINAL="FAIL"
        RELATORIO="$RELATORIO\n[NPM AUDIT] $AUDIT_VULNS vulnerabilidade(s) critica(s)/alta(s)"
        echo "  FAIL — $AUDIT_VULNS vulnerabilidade(s) critica/alta"
    else
        echo "  PASS — nenhuma vulnerabilidade critica/alta"
    fi
elif [ ! -f "$ALVO/package.json" ]; then
    echo "  SKIP — sem package.json"
else
    echo "  SKIP — npm nao encontrado"
fi

# ───────────────────────────────────────────────────────
# 3. DETECCAO DE SECRETS
# ───────────────────────────────────────────────────────

echo "[3/3] Deteccao de secrets (chaves, tokens, senhas)..."

# Buscar patterns comuns de secrets no codigo (excluindo node_modules, .git, etc)
SECRETS_FOUND=$(grep -rn \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --include="*.py" --include="*.env" --include="*.json" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
    --exclude="package-lock.json" --exclude="*.lock" \
    -E '(sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|password\s*[:=]\s*["\x27][^"\x27]{8,}|secret_key\s*[:=]\s*["\x27])' \
    "$ALVO" 2>/dev/null || true)

if [ -n "$SECRETS_FOUND" ]; then
    SECRET_COUNT=$(echo "$SECRETS_FOUND" | wc -l | tr -d ' ')
    RESULTADO_FINAL="FAIL"
    RELATORIO="$RELATORIO\n[SECRETS] $SECRET_COUNT possivel(is) secret(s) exposto(s):"
    RELATORIO="$RELATORIO\n$(echo "$SECRETS_FOUND" | head -10 | sed 's/^/  - /')"
    echo "  FAIL — $SECRET_COUNT possivel(is) secret(s)"
else
    echo "  PASS — nenhum secret detectado"
fi

# ───────────────────────────────────────────────────────
# RELATORIO FINAL
# ───────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════"
echo "  RESULTADO: $RESULTADO_FINAL"
echo "═══════════════════════════════════════════════════"

if [ "$RESULTADO_FINAL" = "FAIL" ]; then
    echo -e "$RELATORIO"
fi

echo ""
exit $([ "$RESULTADO_FINAL" = "PASS" ] && echo 0 || echo 1)
