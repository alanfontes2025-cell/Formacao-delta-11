#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SCOUT — Auditoria Lighthouse de Performance
# ═══════════════════════════════════════════════════════════════
#
# Roda Google Lighthouse e retorna scores de:
#   1. Performance
#   2. Acessibilidade
#   3. Melhores Praticas
#   4. SEO
#
# Uso:
#   bash .delta-11/ferramentas/scout-lighthouse.sh [url]
#   bash .delta-11/ferramentas/scout-lighthouse.sh http://localhost:3000
#
# Requer: lighthouse (npm i -g lighthouse) e Chrome/Chromium
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

URL="${1:-http://localhost:3000}"
RESULTADO_FINAL="PASS"

echo "═══════════════════════════════════════════════════"
echo "  SCOUT LIGHTHOUSE — Auditoria de Performance"
echo "  URL: $URL"
echo "═══════════════════════════════════════════════════"
echo ""

# Verificar se Lighthouse esta instalado
if ! command -v lighthouse &>/dev/null; then
    echo "  SKIP — lighthouse nao instalado"
    echo "  Instale com: npm install -g lighthouse"
    echo ""
    exit 0
fi

# Verificar se URL esta acessivel
HEALTH=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$URL" 2>/dev/null || echo "000")
if [ "$HEALTH" = "000" ]; then
    echo "  FAIL — URL nao acessivel: $URL"
    exit 1
fi

echo "[1/2] Rodando Lighthouse (pode demorar 30-60 segundos)..."

# Rodar Lighthouse em modo headless com output JSON
TEMP_REPORT=$(mktemp /tmp/lighthouse-XXXXXX.json)

lighthouse "$URL" \
    --output=json \
    --output-path="$TEMP_REPORT" \
    --chrome-flags="--headless --no-sandbox" \
    --only-categories=performance,accessibility,best-practices,seo \
    --quiet \
    2>/dev/null || {
        echo "  FAIL — Lighthouse falhou ao rodar"
        echo "  Verifique se Chrome/Chromium esta instalado"
        rm -f "$TEMP_REPORT"
        exit 1
    }

echo "[2/2] Analisando resultados..."
echo ""

# Extrair scores
SCORES=$(python3 -c "
import json, sys
with open('$TEMP_REPORT') as f:
    data = json.load(f)
cats = data.get('categories', {})
for key in ['performance', 'accessibility', 'best-practices', 'seo']:
    cat = cats.get(key, {})
    score = int((cat.get('score', 0) or 0) * 100)
    print(f'{key}|{score}')
" 2>/dev/null || echo "")

if [ -z "$SCORES" ]; then
    echo "  FAIL — nao foi possivel parsear o relatorio"
    rm -f "$TEMP_REPORT"
    exit 1
fi

# Exibir scores com indicadores visuais
echo "  Categoria          Score"
echo "  ─────────────────  ─────"

while IFS='|' read -r categoria score; do
    # Indicador visual
    if [ "$score" -ge 90 ] 2>/dev/null; then
        indicador="OTIMO"
    elif [ "$score" -ge 50 ] 2>/dev/null; then
        indicador="MEDIO"
    else
        indicador="RUIM"
        RESULTADO_FINAL="FAIL"
    fi

    printf "  %-19s %3s  [%s]\n" "$categoria" "$score" "$indicador"
done <<< "$SCORES"

# Limpar
rm -f "$TEMP_REPORT"

# ───────────────────────────────────────────────────────
# RELATORIO FINAL
# ───────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════"
echo "  RESULTADO: $RESULTADO_FINAL"
echo "═══════════════════════════════════════════════════"
echo ""

exit $([ "$RESULTADO_FINAL" = "PASS" ] && echo 0 || echo 1)
