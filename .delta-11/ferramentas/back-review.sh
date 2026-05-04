#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# BACK REVIEW — Auditoria Automatizada de Codigo Backend
# ═══════════════════════════════════════════════════════════════
#
# Verifica padroes obrigatorios em rotas de API:
# - Verificacao de sessao/autenticacao
# - Filtragem por user_id em queries
# - Validacao .max() em strings
# - Paginacao em listagens
# - Status HTTP corretos
# - Padroes N+1
# - Inicializacao segura de servicos externos
#
# Uso:
#   bash .delta-11/ferramentas/back-review.sh [diretorio]
#   bash .delta-11/ferramentas/back-review.sh src/app/api
#   bash .delta-11/ferramentas/back-review.sh --resumo
#
# Nao precisa instalar nada — usa apenas ferramentas do sistema.
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ───────────────────────────────────────────────────────
# CONFIGURACAO
# ───────────────────────────────────────────────────────

MODO_RESUMO=false
DIRETORIO=""

for arg in "$@"; do
    if [[ "$arg" == "--resumo" ]]; then
        MODO_RESUMO=true
    elif [[ -d "$arg" ]]; then
        DIRETORIO="$arg"
    fi
done

# Auto-detectar diretorio de rotas
if [ -z "$DIRETORIO" ]; then
    if [ -d "src/app/api" ]; then
        DIRETORIO="src/app/api"
    elif [ -d "app/api" ]; then
        DIRETORIO="app/api"
    elif [ -d "pages/api" ]; then
        DIRETORIO="pages/api"
    elif [ -d "src/pages/api" ]; then
        DIRETORIO="src/pages/api"
    else
        echo "ERRO: Nenhum diretorio de API encontrado."
        echo "Uso: back-review.sh [diretorio]"
        exit 1
    fi
fi

ALERTAS=0
CRITICOS=0
AVISOS=0
ARQUIVOS_VERIFICADOS=0
RESULTADO_FINAL="OK"

echo "═══════════════════════════════════════════════════"
echo "  BACK REVIEW — Auditoria de Codigo Backend"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Diretorio: $DIRETORIO"
echo "═══════════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────────────
# FUNCOES AUXILIARES
# ───────────────────────────────────────────────────────

registrar_critico() {
    local arquivo="$1"
    local problema="$2"
    echo "  CRITICO  $arquivo"
    echo "            $problema"
    CRITICOS=$((CRITICOS + 1))
    ALERTAS=$((ALERTAS + 1))
    RESULTADO_FINAL="FALHA"
}

registrar_aviso() {
    local arquivo="$1"
    local problema="$2"
    echo "  AVISO    $arquivo"
    echo "            $problema"
    AVISOS=$((AVISOS + 1))
    ALERTAS=$((ALERTAS + 1))
    if [ "$RESULTADO_FINAL" = "OK" ]; then
        RESULTADO_FINAL="ALERTA"
    fi
}

# ───────────────────────────────────────────────────────
# 1. VERIFICACAO DE SESSAO/AUTENTICACAO
# ───────────────────────────────────────────────────────

echo "[1/7] VERIFICACAO DE AUTENTICACAO"
echo "─────────────────────────────────────────────────"

ROTAS_SEM_AUTH=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    ARQUIVOS_VERIFICADOS=$((ARQUIVOS_VERIFICADOS + 1))

    # Pular arquivos de teste
    [[ "$arquivo" == *".test."* ]] && continue
    [[ "$arquivo" == *"__tests__"* ]] && continue

    # Verificar se tem alguma forma de auth check
    if ! grep -qE "getSession|getServerSession|getUser|auth\(\)|createClient|supabase\.auth|verifyToken|authenticate|requireAuth|withAuth|getToken|cookies\(\)" "$arquivo" 2>/dev/null; then
        # Verificar se e rota publica (webhook, health, etc)
        if ! grep -qiE "webhook|health|ping|public|cron" "$arquivo" 2>/dev/null; then
            registrar_critico "$arquivo" "Nenhuma verificacao de sessao/autenticacao encontrada"
            ROTAS_SEM_AUTH=$((ROTAS_SEM_AUTH + 1))
        fi
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | grep -E "route\.(ts|js|tsx|jsx)$" || true)

if [ $ROTAS_SEM_AUTH -eq 0 ]; then
    echo "  OK  Todas as rotas verificam autenticacao"
fi
echo ""

# ───────────────────────────────────────────────────────
# 2. FILTRAGEM POR USER_ID EM QUERIES
# ───────────────────────────────────────────────────────

echo "[2/7] FILTRAGEM POR USER_ID"
echo "─────────────────────────────────────────────────"

QUERIES_SEM_FILTRO=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    [[ "$arquivo" == *".test."* ]] && continue

    # Se faz query ao banco, verificar se filtra por user_id
    if grep -qE "\.from\(|\.select\(|\.insert\(|\.update\(|\.delete\(" "$arquivo" 2>/dev/null; then
        if ! grep -qE "user_id|userId|\.eq\(.*user|\.match\(.*user|auth\.uid\(\)" "$arquivo" 2>/dev/null; then
            # Verificar se e tabela publica ou admin
            if ! grep -qiE "admin|public_|settings|config|webhook" "$arquivo" 2>/dev/null; then
                registrar_aviso "$arquivo" "Query ao banco sem filtro aparente por user_id"
                QUERIES_SEM_FILTRO=$((QUERIES_SEM_FILTRO + 1))
            fi
        fi
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null || true)

if [ $QUERIES_SEM_FILTRO -eq 0 ]; then
    echo "  OK  Queries parecem filtrar por usuario"
fi
echo ""

# ───────────────────────────────────────────────────────
# 3. VALIDACAO .max() EM STRINGS (ZOD/YUP)
# ───────────────────────────────────────────────────────

echo "[3/7] VALIDACAO .max() EM STRINGS"
echo "─────────────────────────────────────────────────"

STRINGS_SEM_MAX=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    [[ "$arquivo" == *".test."* ]] && continue

    # Se usa z.string() (Zod), verificar se tem .max()
    if grep -qE "z\.string\(\)" "$arquivo" 2>/dev/null; then
        # Contar strings sem .max()
        sem_max=$(grep -cE "z\.string\(\)(?!.*\.max\()" "$arquivo" 2>/dev/null || echo "0")
        # Metodo alternativo: contar z.string() total e z.string()...max() separado
        total_strings=$(grep -c "z\.string()" "$arquivo" 2>/dev/null || echo "0")
        com_max=$(grep -c "z\.string().*\.max(" "$arquivo" 2>/dev/null || echo "0")
        diferenca=$((total_strings - com_max))

        if [ "$diferenca" -gt 0 ] 2>/dev/null; then
            registrar_aviso "$arquivo" "$diferenca campo(s) z.string() sem .max() definido"
            STRINGS_SEM_MAX=$((STRINGS_SEM_MAX + diferenca))
        fi
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null || true)

if [ $STRINGS_SEM_MAX -eq 0 ]; then
    echo "  OK  Todos os campos string parecem ter .max()"
fi
echo ""

# ───────────────────────────────────────────────────────
# 4. PAGINACAO EM LISTAGENS
# ───────────────────────────────────────────────────────

echo "[4/7] PAGINACAO EM LISTAGENS"
echo "─────────────────────────────────────────────────"

LISTAGENS_SEM_PAGINACAO=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    [[ "$arquivo" == *".test."* ]] && continue

    # Se faz SELECT/from sem LIMIT
    if grep -qE "\.from\(.*\.select\(|\.select\(.*\.from\(" "$arquivo" 2>/dev/null; then
        if ! grep -qE "\.limit\(|\.range\(|page|offset|cursor|LIMIT" "$arquivo" 2>/dev/null; then
            registrar_aviso "$arquivo" "Query de listagem sem paginacao (limit/range)"
            LISTAGENS_SEM_PAGINACAO=$((LISTAGENS_SEM_PAGINACAO + 1))
        fi
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | grep -E "route\.(ts|js|tsx|jsx)$" || true)

if [ $LISTAGENS_SEM_PAGINACAO -eq 0 ]; then
    echo "  OK  Listagens parecem ter paginacao"
fi
echo ""

# ───────────────────────────────────────────────────────
# 5. STATUS HTTP CORRETOS
# ───────────────────────────────────────────────────────

echo "[5/7] STATUS HTTP"
echo "─────────────────────────────────────────────────"

STATUS_PROBLEMAS=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    [[ "$arquivo" == *".test."* ]] && continue

    # POST que cria recurso deveria retornar 201, nao 200
    if grep -qE "export.*POST|method.*POST" "$arquivo" 2>/dev/null; then
        if grep -qE "\.insert\(|\.create\(" "$arquivo" 2>/dev/null; then
            if ! grep -qE "201|status.*201" "$arquivo" 2>/dev/null; then
                registrar_aviso "$arquivo" "POST com insert/create retorna 200 em vez de 201"
                STATUS_PROBLEMAS=$((STATUS_PROBLEMAS + 1))
            fi
        fi
    fi

    # DELETE deveria retornar 200 ou 204
    if grep -qE "export.*DELETE|method.*DELETE" "$arquivo" 2>/dev/null; then
        if grep -qE "status.*201|NextResponse.*201" "$arquivo" 2>/dev/null; then
            registrar_aviso "$arquivo" "DELETE retornando 201 (deveria ser 200 ou 204)"
            STATUS_PROBLEMAS=$((STATUS_PROBLEMAS + 1))
        fi
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | grep -E "route\.(ts|js|tsx|jsx)$" || true)

if [ $STATUS_PROBLEMAS -eq 0 ]; then
    echo "  OK  Status HTTP parecem corretos"
fi
echo ""

# ───────────────────────────────────────────────────────
# 6. PADROES N+1 (query dentro de loop)
# ───────────────────────────────────────────────────────

echo "[6/7] DETECCAO DE N+1"
echo "─────────────────────────────────────────────────"

N_PLUS_1=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    [[ "$arquivo" == *".test."* ]] && continue

    # Detectar padrao: for/forEach/map seguido de await com query
    if grep -qE "for.*\{|forEach|\.map\(" "$arquivo" 2>/dev/null; then
        if grep -qE "await.*\.from\(|await.*\.select\(|await.*fetch\(|await.*prisma\." "$arquivo" 2>/dev/null; then
            # Verificacao heuristica: se tem loop E await com query no mesmo arquivo
            # Pode ser falso positivo, mas vale alertar
            registrar_aviso "$arquivo" "Possivel N+1: await com query detectado em arquivo com loop"
            N_PLUS_1=$((N_PLUS_1 + 1))
        fi
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null || true)

if [ $N_PLUS_1 -eq 0 ]; then
    echo "  OK  Nenhum padrao N+1 obvio detectado"
fi
echo ""

# ───────────────────────────────────────────────────────
# 7. INICIALIZACAO DE SERVICOS EXTERNOS
# ───────────────────────────────────────────────────────

echo "[7/7] INICIALIZACAO DE SERVICOS"
echo "─────────────────────────────────────────────────"

INIT_PROBLEMAS=0

while IFS= read -r arquivo; do
    [ -f "$arquivo" ] || continue
    [[ "$arquivo" == *".test."* ]] && continue

    # Detectar instanciacao no nivel do modulo (fora de funcao)
    # Procurar por: new Stripe, new Resend, createClient no topo
    if head -20 "$arquivo" 2>/dev/null | grep -qE "^(const|let|var).*new (Stripe|Resend|Twilio|SendGrid|Mailgun)\(|^(const|let|var).*(createClient|createServerClient)\(" 2>/dev/null; then
        registrar_critico "$arquivo" "Servico externo instanciado no topo do modulo (crash se env ausente)"
        INIT_PROBLEMAS=$((INIT_PROBLEMAS + 1))
    fi
done < <(find "$DIRETORIO" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null || true)

if [ $INIT_PROBLEMAS -eq 0 ]; then
    echo "  OK  Servicos externos parecem inicializados de forma segura"
fi
echo ""

# ───────────────────────────────────────────────────────
# RELATORIO FINAL
# ───────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════"
echo "  RESUMO"
echo "─────────────────────────────────────────────────"
echo "  Arquivos verificados: $ARQUIVOS_VERIFICADOS"
echo "  Criticos: $CRITICOS"
echo "  Avisos: $AVISOS"
echo "  Total de alertas: $ALERTAS"
echo ""

if [ "$RESULTADO_FINAL" = "OK" ]; then
    echo "  RESULTADO: OK — Nenhum problema detectado"
elif [ "$RESULTADO_FINAL" = "ALERTA" ]; then
    echo "  RESULTADO: ALERTA — $AVISOS aviso(s) para revisar"
else
    echo "  RESULTADO: FALHA — $CRITICOS problema(s) critico(s)"
fi
echo "═══════════════════════════════════════════════════"
echo ""

exit $([ "$RESULTADO_FINAL" = "OK" ] && echo 0 || echo 1)
