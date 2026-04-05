#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Verificador de Dependencias por Agente
# ═══════════════════════════════════════════════════════════════
#
# Verifica se as ferramentas especializadas de um agente estao
# instaladas no sistema. Se alguma faltar, mostra como instalar.
#
# Uso: bash .delta-11/ferramentas/verificar-dependencias.sh SHIELD
# ═══════════════════════════════════════════════════════════════

AGENTE="${1:-}"

if [ -z "$AGENTE" ]; then
    echo "Uso: verificar-dependencias.sh NOME-DO-AGENTE"
    echo "Exemplo: verificar-dependencias.sh SHIELD"
    exit 1
fi

echo ""
echo "Verificando dependencias de $AGENTE..."
echo ""

FALTANDO=0

verificar() {
    local cmd="$1"
    local descricao="$2"
    local instalacao="$3"

    if command -v "$cmd" &>/dev/null; then
        echo "  OK  $cmd — $descricao"
    else
        echo "  FALTA  $cmd — $descricao"
        echo "         Instale com: $instalacao"
        FALTANDO=$((FALTANDO + 1))
    fi
}

case "$AGENTE" in
    SHIELD)
        verificar "semgrep" "Analise estatica de seguranca (SAST)" "pip install semgrep"
        verificar "npm" "Gerenciador de pacotes Node.js" "brew install node"
        verificar "python3" "Python 3 (para parsear JSON)" "brew install python3"
        ;;
    VAULT)
        verificar "sqlfluff" "Linter de SQL" "pip install sqlfluff"
        verificar "supabase" "CLI do Supabase" "brew install supabase/tap/supabase"
        ;;
    ENGINE)
        verificar "curl" "Testes de API" "(ja incluso no macOS)"
        verificar "python3" "Parser de respostas JSON" "brew install python3"
        ;;
    SCOUT)
        verificar "lighthouse" "Auditoria de performance web" "npm install -g lighthouse"
        verificar "python3" "Parser de relatorios" "brew install python3"
        ;;
    CRONOS)
        verificar "bash" "Shell para scripts de monitoramento" "(ja incluso no macOS)"
        verificar "grep" "Busca em arquivos de estado" "(ja incluso no macOS)"
        verificar "stat" "Verificacao de idade de locks" "(ja incluso no macOS)"
        ;;
    BACK)
        verificar "grep" "Busca de padroes em codigo" "(ja incluso no macOS)"
        verificar "find" "Busca de arquivos de rotas" "(ja incluso no macOS)"
        verificar "node" "Node.js para validacao de sintaxe" "brew install node"
        ;;
    *)
        echo "  $AGENTE nao tem ferramentas especializadas para verificar."
        echo ""
        exit 0
        ;;
esac

echo ""

if [ "$FALTANDO" -gt 0 ]; then
    echo "RESULTADO: $FALTANDO ferramenta(s) faltando."
    echo "Instale as ferramentas acima e rode este script novamente."
else
    echo "RESULTADO: Todas as ferramentas instaladas."
fi

echo ""
exit $FALTANDO
