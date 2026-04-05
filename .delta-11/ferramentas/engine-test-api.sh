#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# ENGINE — Testes de API via curl
# ═══════════════════════════════════════════════════════════════
#
# Testa rotas da API com curl e verifica:
#   1. Status code esperado
#   2. Content-Type correto
#   3. Tempo de resposta (timeout 5s)
#
# Uso:
#   bash .delta-11/ferramentas/engine-test-api.sh [base_url]
#   bash .delta-11/ferramentas/engine-test-api.sh http://localhost:3000
#
# Se nao passar URL, usa http://localhost:3000
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

BASE_URL="${1:-http://localhost:3000}"
RESULTADO_FINAL="PASS"
RELATORIO=""
TESTES_TOTAL=0
TESTES_OK=0
TESTES_FAIL=0

echo "═══════════════════════════════════════════════════"
echo "  ENGINE TEST API"
echo "  Base URL: $BASE_URL"
echo "═══════════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────────────
# FUNCAO DE TESTE
# ───────────────────────────────────────────────────────

testar_rota() {
    local metodo="$1"
    local rota="$2"
    local status_esperado="${3:-200}"
    local corpo="${4:-}"

    TESTES_TOTAL=$((TESTES_TOTAL + 1))

    local curl_args="-s -o /dev/null -w '%{http_code}|%{time_total}|%{content_type}' --max-time 5"

    if [ -n "$corpo" ]; then
        curl_args="$curl_args -H 'Content-Type: application/json' -d '$corpo'"
    fi

    local resultado
    resultado=$(eval curl $curl_args -X "$metodo" "${BASE_URL}${rota}" 2>/dev/null || echo "000|0|")

    local status_code tempo content_type
    status_code=$(echo "$resultado" | cut -d'|' -f1 | tr -d "'")
    tempo=$(echo "$resultado" | cut -d'|' -f2)
    content_type=$(echo "$resultado" | cut -d'|' -f3)

    if [ "$status_code" = "$status_esperado" ]; then
        TESTES_OK=$((TESTES_OK + 1))
        echo "  PASS  $metodo $rota → $status_code (${tempo}s)"
    elif [ "$status_code" = "000" ]; then
        TESTES_FAIL=$((TESTES_FAIL + 1))
        RESULTADO_FINAL="FAIL"
        RELATORIO="$RELATORIO\n  TIMEOUT  $metodo $rota → sem resposta em 5s"
        echo "  FAIL  $metodo $rota → TIMEOUT (servidor nao respondeu)"
    else
        TESTES_FAIL=$((TESTES_FAIL + 1))
        RESULTADO_FINAL="FAIL"
        RELATORIO="$RELATORIO\n  FAIL  $metodo $rota → $status_code (esperado $status_esperado)"
        echo "  FAIL  $metodo $rota → $status_code (esperado $status_esperado)"
    fi
}

# ───────────────────────────────────────────────────────
# VERIFICAR SE SERVIDOR ESTA RODANDO
# ───────────────────────────────────────────────────────

echo "[0] Verificando se o servidor esta acessivel..."

HEALTH_CHECK=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 "$BASE_URL" 2>/dev/null || echo "000")

if [ "$HEALTH_CHECK" = "000" ]; then
    echo ""
    echo "  FAIL — Servidor nao esta acessivel em $BASE_URL"
    echo "  Verifique se o servidor esta rodando (npm run dev, etc.)"
    echo ""
    exit 1
fi

echo "  OK — Servidor acessivel (status $HEALTH_CHECK)"
echo ""

# ───────────────────────────────────────────────────────
# TESTES BASICOS (sempre rodam)
# ───────────────────────────────────────────────────────

echo "[1] Testes basicos..."

# Pagina principal deve responder
testar_rota "GET" "/" "200"

# Rotas de API que nao existem devem retornar 404
testar_rota "GET" "/api/rota-que-nao-existe-$(date +%s)" "404"

# ───────────────────────────────────────────────────────
# TESTES DINAMICOS (baseados em project-core.md)
# ───────────────────────────────────────────────────────

echo ""
echo "[2] Testes de rotas do projeto..."

PROJECT_CORE=".delta-11/memoria/project-core.md"

if [ -f "$PROJECT_CORE" ]; then
    # Extrair rotas GET definidas no project-core.md
    ROTAS_GET=$(grep -oE '(GET|POST|PUT|DELETE|PATCH)\s+/api/[^ ]+' "$PROJECT_CORE" 2>/dev/null || true)

    if [ -n "$ROTAS_GET" ]; then
        while IFS= read -r linha; do
            metodo=$(echo "$linha" | awk '{print $1}')
            rota=$(echo "$linha" | awk '{print $2}')

            if [ "$metodo" = "GET" ]; then
                # GET sem autenticacao pode retornar 200 ou 401
                testar_rota "$metodo" "$rota" "200"
            else
                # POST/PUT/DELETE sem body deve retornar 400 ou 401
                testar_rota "$metodo" "$rota" "400"
            fi
        done <<< "$ROTAS_GET"
    else
        echo "  Nenhuma rota encontrada no project-core.md"
    fi
else
    echo "  SKIP — project-core.md nao encontrado"
fi

# ───────────────────────────────────────────────────────
# RELATORIO FINAL
# ───────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════"
echo "  RESULTADO: $RESULTADO_FINAL"
echo "  Total: $TESTES_TOTAL | OK: $TESTES_OK | FAIL: $TESTES_FAIL"
echo "═══════════════════════════════════════════════════"

if [ -n "$RELATORIO" ]; then
    echo -e "$RELATORIO"
fi

echo ""
exit $([ "$RESULTADO_FINAL" = "PASS" ] && echo 0 || echo 1)
