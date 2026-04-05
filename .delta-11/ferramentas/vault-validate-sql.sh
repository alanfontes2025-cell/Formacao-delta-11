#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# VAULT — Validacao de SQL e Migrations
# ═══════════════════════════════════════════════════════════════
#
# Valida arquivos SQL:
#   1. Sintaxe SQL (sqlfluff lint)
#   2. Ordem de migrations (sequencia numerica)
#   3. Checklist de seguranca (RLS, indexes, constraints)
#
# Uso: bash .delta-11/ferramentas/vault-validate-sql.sh [diretorio]
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

ALVO="${1:-.}"
RESULTADO_FINAL="PASS"
RELATORIO=""

echo "═══════════════════════════════════════════════════"
echo "  VAULT VALIDATE — SQL e Migrations"
echo "  Alvo: $ALVO"
echo "═══════════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────────────
# 1. SQLFLUFF LINT
# ───────────────────────────────────────────────────────

echo "[1/3] sqlfluff lint..."

MIGRATION_DIR=""
for dir in "$ALVO/supabase/migrations" "$ALVO/migrations" "$ALVO/sql"; do
    [ -d "$dir" ] && MIGRATION_DIR="$dir" && break
done

if [ -n "$MIGRATION_DIR" ] && command -v sqlfluff &>/dev/null; then
    SQLFLUFF_OUTPUT=$(sqlfluff lint "$MIGRATION_DIR" --dialect postgres 2>&1 || true)
    SQLFLUFF_ERRORS=$(echo "$SQLFLUFF_OUTPUT" | grep -c "ERROR\|L:" 2>/dev/null || echo "0")

    if [ "$SQLFLUFF_ERRORS" -gt 0 ] 2>/dev/null; then
        RELATORIO="$RELATORIO\n[SQLFLUFF] $SQLFLUFF_ERRORS problema(s) de estilo SQL"
        echo "  WARNING — $SQLFLUFF_ERRORS problema(s) de estilo"
    else
        echo "  PASS — SQL bem formatado"
    fi
elif [ -z "$MIGRATION_DIR" ]; then
    echo "  SKIP — pasta de migrations nao encontrada"
elif ! command -v sqlfluff &>/dev/null; then
    echo "  SKIP — sqlfluff nao instalado (pip install sqlfluff)"
fi

# ───────────────────────────────────────────────────────
# 2. ORDEM DE MIGRATIONS
# ───────────────────────────────────────────────────────

echo "[2/3] Verificando ordem de migrations..."

if [ -n "$MIGRATION_DIR" ]; then
    # Verificar se migrations estao em ordem cronologica
    MIGRATIONS=$(ls "$MIGRATION_DIR"/*.sql 2>/dev/null | sort)
    MIGRATION_COUNT=$(echo "$MIGRATIONS" | grep -c ".sql" 2>/dev/null || echo "0")

    if [ "$MIGRATION_COUNT" -gt 0 ] 2>/dev/null; then
        # Verificar duplicatas de timestamp
        TIMESTAMPS=$(echo "$MIGRATIONS" | xargs -I{} basename {} | grep -oE '^[0-9]+' | sort)
        DUPLICATAS=$(echo "$TIMESTAMPS" | uniq -d)

        if [ -n "$DUPLICATAS" ]; then
            RESULTADO_FINAL="FAIL"
            RELATORIO="$RELATORIO\n[MIGRATIONS] Timestamps duplicados: $DUPLICATAS"
            echo "  FAIL — timestamps duplicados encontrados"
        else
            echo "  PASS — $MIGRATION_COUNT migration(s) em ordem"
        fi
    else
        echo "  SKIP — nenhum arquivo .sql encontrado"
    fi
else
    echo "  SKIP — pasta de migrations nao encontrada"
fi

# ───────────────────────────────────────────────────────
# 3. CHECKLIST DE SEGURANCA SQL
# ───────────────────────────────────────────────────────

echo "[3/3] Checklist de seguranca SQL..."

if [ -n "$MIGRATION_DIR" ]; then
    TODOS_SQL=$(cat "$MIGRATION_DIR"/*.sql 2>/dev/null || true)

    # Verificar se tem CREATE TABLE sem RLS
    TABELAS_SEM_RLS=0
    for tabela in $(echo "$TODOS_SQL" | grep -oE 'CREATE TABLE[^(]+' | sed 's/CREATE TABLE//; s/IF NOT EXISTS//' | tr -d ' "' | grep -v '^$'); do
        if ! echo "$TODOS_SQL" | grep -q "ENABLE ROW LEVEL SECURITY.*${tabela}\|ALTER TABLE.*${tabela}.*ENABLE ROW LEVEL SECURITY"; then
            # Verificar formato alternativo
            if ! echo "$TODOS_SQL" | grep -q "enable row level security" | grep -qi "$tabela"; then
                TABELAS_SEM_RLS=$((TABELAS_SEM_RLS + 1))
                RELATORIO="$RELATORIO\n  - Tabela sem RLS: $tabela"
            fi
        fi
    done

    if [ "$TABELAS_SEM_RLS" -gt 0 ] 2>/dev/null; then
        RELATORIO="$RELATORIO\n[SEGURANCA] $TABELAS_SEM_RLS tabela(s) sem Row Level Security"
        echo "  WARNING — $TABELAS_SEM_RLS tabela(s) sem RLS"
    else
        echo "  PASS — todas as tabelas com RLS"
    fi

    # Verificar ON DELETE em foreign keys
    FK_SEM_DELETE=$(echo "$TODOS_SQL" | grep -c "REFERENCES.*[^(]*$" 2>/dev/null || echo "0")
    if [ "$FK_SEM_DELETE" -gt 0 ] 2>/dev/null; then
        RELATORIO="$RELATORIO\n[SEGURANCA] $FK_SEM_DELETE foreign key(s) sem ON DELETE definido"
        echo "  WARNING — $FK_SEM_DELETE FK(s) sem ON DELETE"
    fi
else
    echo "  SKIP — sem migrations para verificar"
fi

# ───────────────────────────────────────────────────────
# RELATORIO FINAL
# ───────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════"
echo "  RESULTADO: $RESULTADO_FINAL"
echo "═══════════════════════════════════════════════════"

if [ -n "$RELATORIO" ]; then
    echo -e "$RELATORIO"
fi

echo ""
exit $([ "$RESULTADO_FINAL" = "PASS" ] && echo 0 || echo 1)
