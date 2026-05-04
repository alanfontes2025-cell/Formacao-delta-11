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

# Detectar SO para sugerir o instalador correto
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) PKG_HINT="winget install (ou npm install -g, ou pip install)" ;;
    Darwin)               PKG_HINT="brew install (ou npm install -g, ou pip install)" ;;
    Linux)                PKG_HINT="apt install / pacman -S (ou npm install -g, ou pip install)" ;;
    *)                    PKG_HINT="instalador do seu sistema" ;;
esac

case "$AGENTE" in
    SHIELD)
        verificar "semgrep" "Analise estatica de seguranca (SAST)" "pip install semgrep"
        verificar "npm" "Gerenciador de pacotes Node.js" "winget install OpenJS.NodeJS  |  brew install node  |  apt install nodejs"
        verificar "python3" "Python 3 (para parsear JSON)" "winget install Python.Python.3.12  |  brew install python3  |  apt install python3"
        ;;
    VAULT)
        verificar "sqlfluff" "Linter de SQL" "pip install sqlfluff"
        verificar "supabase" "CLI do Supabase" "npm install -g supabase  |  brew install supabase/tap/supabase"
        ;;
    ENGINE)
        verificar "curl" "Testes de API" "(ja incluso no Git Bash / macOS / Linux)"
        verificar "python3" "Parser de respostas JSON" "winget install Python.Python.3.12  |  brew install python3  |  apt install python3"
        ;;
    SCOUT)
        verificar "lighthouse" "Auditoria de performance web" "npm install -g lighthouse"
        verificar "python3" "Parser de relatorios" "winget install Python.Python.3.12  |  brew install python3  |  apt install python3"
        ;;
    CRONOS)
        verificar "bash" "Shell para scripts de monitoramento" "(ja incluso no Git Bash / macOS / Linux)"
        verificar "grep" "Busca em arquivos de estado" "(ja incluso no Git Bash / macOS / Linux)"
        verificar "stat" "Verificacao de idade de locks" "(ja incluso no Git Bash / macOS / Linux)"
        ;;
    BACK)
        verificar "grep" "Busca de padroes em codigo" "(ja incluso no Git Bash / macOS / Linux)"
        verificar "find" "Busca de arquivos de rotas" "(ja incluso no Git Bash / macOS / Linux)"
        verificar "node" "Node.js para validacao de sintaxe" "winget install OpenJS.NodeJS  |  brew install node  |  apt install nodejs"
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
