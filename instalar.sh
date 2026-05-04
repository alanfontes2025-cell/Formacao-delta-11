#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# FORMAÇÃO Δ-11 — Script de Instalação para macOS
# ═══════════════════════════════════════════════════════════════
#
# O que este script faz:
# 1. Verifica se você tem tudo que precisa instalado (git, gh)
# 2. Cria o repositório privado no seu GitHub
# 3. Faz o primeiro commit e push
# 4. Instala a extensão Live Server no VS Code (para o painel)
# 5. Abre o VS Code com o projeto
# 6. Abre o painel visual no navegador
#
# Como usar:
#   1. Abra o Terminal do macOS
#   2. Navegue até a pasta onde estão os arquivos da Formação Δ-11
#   3. Execute: chmod +x instalar.sh && ./instalar.sh
#
# ═══════════════════════════════════════════════════════════════

set -e

# Cores para o terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}        FORMAÇÃO Δ-11 — Instalação${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─── PASSO 1: Verificar pré-requisitos ───────────────────────

echo -e "${YELLOW}[1/6]${NC} Verificando pré-requisitos..."

# Verificar Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git não encontrado.${NC}"
    echo "  Instale com: xcode-select --install"
    echo "  Ou baixe de: https://git-scm.com/download/mac"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Git encontrado: $(git --version)"

# Verificar GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${RED}✗ GitHub CLI (gh) não encontrado.${NC}"
    echo ""
    echo "  Instale conforme seu sistema operacional:"
    echo "    Windows: winget install --id GitHub.cli"
    echo "    macOS:   brew install gh"
    echo "    Linux:   apt install gh   (ou veja https://github.com/cli/cli)"
    echo ""
    echo "  Depois rode este script novamente."
    exit 1
fi
echo -e "  ${GREEN}✓${NC} GitHub CLI encontrado: $(gh --version | head -1)"

# Verificar se gh está autenticado
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}  ⚠ GitHub CLI não está autenticado.${NC}"
    echo "  Vou iniciar o processo de autenticação agora..."
    echo ""
    gh auth login
    echo ""
fi
echo -e "  ${GREEN}✓${NC} GitHub CLI autenticado"

# Verificar VS Code CLI
if ! command -v code &> /dev/null; then
    echo -e "${YELLOW}  ⚠ Comando 'code' do VS Code não encontrado.${NC}"
    echo "  Para instalar:"
    echo "    1. Abra o VS Code"
    echo "    2. Pressione Cmd+Shift+P"
    echo "    3. Digite 'Shell Command: Install code command in PATH'"
    echo "    4. Selecione e confirme"
    echo ""
    VSCODE_AVAILABLE=false
else
    echo -e "  ${GREEN}✓${NC} VS Code CLI encontrado"
    VSCODE_AVAILABLE=true
fi

echo ""

# ─── PASSO 2: Configurar nome do repositório ─────────────────

echo -e "${YELLOW}[2/6]${NC} Configuração do repositório..."
echo ""

# Pegar nome do usuário no GitHub
GH_USER=$(gh api user --jq '.login')
echo -e "  Conta GitHub: ${CYAN}${GH_USER}${NC}"
echo ""

# Perguntar nome do repositório
DEFAULT_REPO="formacao-delta-11"
read -p "  Nome do repositório [$DEFAULT_REPO]: " REPO_NAME
REPO_NAME=${REPO_NAME:-$DEFAULT_REPO}

echo ""

# Verificar se o repositório já existe
if gh repo view "${GH_USER}/${REPO_NAME}" &> /dev/null; then
    echo -e "${YELLOW}  ⚠ O repositório '${REPO_NAME}' já existe.${NC}"
    read -p "  Deseja usar o existente? (s/n): " USE_EXISTING
    if [[ "$USE_EXISTING" != "s" && "$USE_EXISTING" != "S" ]]; then
        echo "  Abortado. Rode o script novamente com outro nome."
        exit 1
    fi
    REPO_EXISTS=true
else
    REPO_EXISTS=false
fi

echo ""

# ─── PASSO 3: Verificar se os arquivos estão aqui ────────────

echo -e "${YELLOW}[3/6]${NC} Verificando arquivos da Formação Δ-11..."

if [ ! -f "CLAUDE.md" ]; then
    echo -e "${RED}✗ Arquivo CLAUDE.md não encontrado nesta pasta.${NC}"
    echo "  Certifique-se de que você está na pasta que contém os arquivos da Formação Δ-11."
    echo "  A estrutura deve ser:"
    echo "    CLAUDE.md"
    echo "    GUIA-DO-COMANDANTE.md"
    echo "    .delta-11/"
    echo "    instalar.sh (este script)"
    exit 1
fi

if [ ! -d ".delta-11" ]; then
    echo -e "${RED}✗ Pasta .delta-11 não encontrada.${NC}"
    echo "  Certifique-se de que a pasta .delta-11 está aqui (ela é oculta)."
    echo "  Use 'ls -la' para verificar."
    exit 1
fi

FILE_COUNT=$(find . -type f -not -path './.git/*' -not -name 'instalar.sh' -not -name '.DS_Store' | wc -l | xargs)
echo -e "  ${GREEN}✓${NC} ${FILE_COUNT} arquivos encontrados"

# Garantir que todas as pastas de sistema existam
mkdir -p .delta-11/perfis
mkdir -p .delta-11/mcp
mkdir -p .delta-11/ferramentas
mkdir -p .delta-11/conhecimento
mkdir -p .delta-11/hooks
mkdir -p .delta-11/locks
echo -e "  ${GREEN}✓${NC} Pastas de sistema verificadas"
echo ""

# ─── PASSO 4: Inicializar Git e criar repositório ────────────

echo -e "${YELLOW}[4/6]${NC} Configurando repositório Git..."

# Criar .gitignore
cat > .gitignore << 'EOF'
.DS_Store
*.swp
*.swo
*~
.vscode/settings.json
node_modules/
EOF

# Inicializar git se necessário
if [ ! -d ".git" ]; then
    git init -b main
    echo -e "  ${GREEN}✓${NC} Git inicializado"
fi

# Criar repositório no GitHub se não existe
if [ "$REPO_EXISTS" = false ]; then
    echo "  Criando repositório privado no GitHub..."
    gh repo create "$REPO_NAME" --private --source=. --remote=origin
    echo -e "  ${GREEN}✓${NC} Repositório privado criado: ${CYAN}https://github.com/${GH_USER}/${REPO_NAME}${NC}"
else
    # Verificar se o remote já existe
    if ! git remote get-url origin &> /dev/null; then
        git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
    fi
    echo -e "  ${GREEN}✓${NC} Usando repositório existente"
fi

echo ""

# ─── PASSO 4.5: Detectar modo de dispatch ────────────────────

echo -e "${YELLOW}[4.5/6]${NC} Detectando modo de dispatch..."

if [ -n "$VSCODE_PID" ]; then
    # Rodando dentro do terminal integrado do VS Code
    echo "vscode-tab" > .delta-11/.dispatch-mode
    echo -e "  ${GREEN}✓${NC} Detectado: VS Code (extensão) → ${CYAN}vscode-tab${NC}"
elif [ -n "$TERM_PROGRAM" ] && [ "$TERM_PROGRAM" = "vscode" ]; then
    # Outra forma de detectar terminal integrado do VS Code
    echo "vscode-tab" > .delta-11/.dispatch-mode
    echo -e "  ${GREEN}✓${NC} Detectado: VS Code (terminal integrado) → ${CYAN}vscode-tab${NC}"
else
    # Rodando no Terminal do macOS — não grava o arquivo
    # ATLAS detectará automaticamente na primeira ativação dentro do VS Code
    echo -e "  ${YELLOW}→${NC} Terminal externo detectado — modo será detectado automaticamente"
    echo -e "    pelo ATLAS na primeira ativação dentro do VS Code"
fi

echo ""

# ─── PASSO 4.7: Instalar skill fluxo-ux-completo ─────────────

echo -e "${YELLOW}[4.7/6]${NC} Instalando skill fluxo-ux-completo..."

SKILL_DEST="$HOME/.claude/skills/fluxo-ux-completo"
SKILL_SRC="$(pwd)/skills/fluxo-ux-completo"

if [ -d "$SKILL_SRC" ]; then
    mkdir -p "$SKILL_DEST"
    cp -r "$SKILL_SRC/." "$SKILL_DEST/"
    echo -e "  ${GREEN}✓${NC} Skill fluxo-ux-completo instalada em ~/.claude/skills/"
else
    echo -e "  ${YELLOW}⚠${NC} Pasta skills/fluxo-ux-completo não encontrada — pulando"
fi

echo ""

# ─── PASSO 5: Commit e Push ──────────────────────────────────

echo -e "${YELLOW}[5/6]${NC} Fazendo commit e push..."

git add -A
git commit -m "Formação Δ-11 — Sistema operacional de desenvolvimento por inteligência artificial

Sistema completo com 10 agentes especializados:
- ATLAS (arquiteto), CRONOS (gerente), FRONT, BACK (líderes técnicos)
- PIXEL, FORM, ENGINE, VAULT (executores)
- SHIELD (qualidade), SCOUT (correção de erros)

Inclui: protocolos, kanban, painel visual, templates de memória.
" 2>/dev/null || echo "  (nenhuma mudança para commitar)"

git push -u origin main 2>/dev/null || git push origin main
echo -e "  ${GREEN}✓${NC} Código enviado para o GitHub"
echo ""

# ─── PASSO 5.5: Registrar no registry global ──────────────────

REGISTRY="$HOME/.delta-11-registry.json"
PROJECT_PATH="$(pwd)"

if command -v jq &> /dev/null; then
    if [ -f "$REGISTRY" ]; then
        # Verificar se o projeto ja esta registrado
        ALREADY=$(jq --arg p "$PROJECT_PATH" '.projects | index($p)' "$REGISTRY")
        if [ "$ALREADY" = "null" ]; then
            echo -e "  Registrando projeto no registry global..."
            TMP_REG=$(mktemp)
            jq --arg p "$PROJECT_PATH" '.projects += [$p]' "$REGISTRY" > "$TMP_REG" && mv "$TMP_REG" "$REGISTRY"
            echo -e "  ${GREEN}✓${NC} Projeto registrado em $REGISTRY"
        else
            echo -e "  ${GREEN}✓${NC} Projeto ja registrado no registry"
        fi
    else
        # Criar registry novo
        echo -e "  Criando registry global..."
        cat > "$REGISTRY" << REGEOF
{
  "version": "3.2",
  "source": "$PROJECT_PATH",
  "github": "https://github.com/Hackerdomarketing/Formacao-delta-11.git",
  "projects": ["$PROJECT_PATH"],
  "backup": null,
  "historical": null,
  "last_sync": null
}
REGEOF
        echo -e "  ${GREEN}✓${NC} Registry criado em $REGISTRY"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} jq nao encontrado — registro no registry ignorado"
    echo "    Instale conforme seu SO e rode sincronizar.sh depois:"
    echo "      Windows: winget install jqlang.jq"
    echo "      macOS:   brew install jq"
    echo "      Linux:   apt install jq"
fi

echo ""

# ─── PASSO 5.7: Instalar hooks e monitor invisível ─────────────

echo -e "${YELLOW}[5.7/6]${NC} Configurando monitoramento de agentes..."

# 5.7a: Configurar hooks do projeto (heartbeat, stop, pre-compact)
if [ -f ".delta-11/templates/settings-hooks.json" ]; then
    PROJETO_SETTINGS=".claude/settings.json"
    mkdir -p .claude
    if [ -f "$PROJETO_SETTINGS" ]; then
        echo -e "  ${GREEN}✓${NC} Hooks do projeto já configurados"
    else
        cp .delta-11/templates/settings-hooks.json "$PROJETO_SETTINGS"
        echo -e "  ${GREEN}✓${NC} Hooks instalados (heartbeat, stop, pre-compact)"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Template de hooks não encontrado — pulando"
fi

# 5.7b: Tornar hooks executáveis
for hook in .delta-11/hooks/*.sh; do
    [ -f "$hook" ] && chmod +x "$hook"
done

# 5.7c: Instalar monitor de fundo (verifica agentes mortos a cada 5 min)
# macOS usa LaunchAgent; Windows precisaria de Task Scheduler (não implementado ainda)
case "$(uname -s)" in
    Darwin)
        # macOS: LaunchAgent
        PLIST_SRC="$(cd "$(dirname "$0")" && pwd)/com.delta11.monitor.plist"
        PLIST_DST="$HOME/Library/LaunchAgents/com.delta11.monitor.plist"

        if [ -f "$PLIST_SRC" ]; then
            if [ -f "$PLIST_DST" ]; then
                echo -e "  ${GREEN}✓${NC} Monitor LaunchAgent já instalado"
            else
                mkdir -p "$HOME/Library/LaunchAgents"
                cp "$PLIST_SRC" "$PLIST_DST"
                launchctl load "$PLIST_DST" 2>/dev/null
                echo -e "  ${GREEN}✓${NC} Monitor instalado (verifica a cada 5 min, invisível)"
            fi
        else
            echo -e "  ${YELLOW}⚠${NC} LaunchAgent plist não encontrado — pulando"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # Windows: monitor automatico ainda nao implementado
        echo -e "  ${YELLOW}ⓘ${NC} Monitor de fundo nao instalado (Windows)"
        echo -e "      Os hooks (heartbeat/on-stop/pre-compact) ja funcionam — eles registram"
        echo -e "      pulso, morte e alerta de contexto direto nos arquivos do projeto."
        echo -e "      Para ativar verificacao automatica, agende no Windows Task Scheduler:"
        echo -e "        Programa: bash"
        echo -e "        Argumentos: \"$(cd "$(dirname "$0")" && pwd)/monitor-delta11.sh\""
        echo -e "        Frequencia: a cada 5 minutos"
        ;;
    Linux)
        echo -e "  ${YELLOW}ⓘ${NC} Monitor de fundo nao instalado (Linux)"
        echo -e "      Para ativar, configure um cron job:"
        echo -e "        */5 * * * * bash $(cd "$(dirname "$0")" && pwd)/monitor-delta11.sh"
        ;;
esac

# 5.7d: Parar vigilante.sh antigo se estiver rodando (so macOS/Linux — pgrep nao existe nativo no Windows)
case "$(uname -s)" in
    Darwin|Linux)
        if pgrep -f "vigilante.sh" > /dev/null 2>&1; then
            pkill -f "vigilante.sh" 2>/dev/null
            echo -e "  ${GREEN}✓${NC} Vigilante antigo parado (substituído pelo monitor)"
        fi
        ;;
esac

echo ""

# ─── PASSO 6: Abrir tudo ─────────────────────────────────────

echo -e "${YELLOW}[6/6]${NC} Abrindo ambiente de trabalho..."

# Instalar extensão Live Server no VS Code (se VS Code disponível)
if [ "$VSCODE_AVAILABLE" = true ]; then
    echo "  Instalando extensão Live Server..."
    code --install-extension ritwickdey.LiveServer 2>/dev/null && \
        echo -e "  ${GREEN}✓${NC} Live Server instalado" || \
        echo -e "  ${YELLOW}⚠${NC} Live Server já instalado ou erro (pode ignorar)"

    echo "  Abrindo VS Code..."
    code .
    echo -e "  ${GREEN}✓${NC} VS Code aberto com o projeto"
fi

# Abrir o painel no navegador
echo "  Abrindo painel visual no navegador..."
open .delta-11/painel.html 2>/dev/null || \
    echo -e "  ${YELLOW}⚠${NC} Não foi possível abrir automaticamente. Abra manualmente: .delta-11/painel.html"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✓ INSTALAÇÃO COMPLETA${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Repositório:${NC} https://github.com/${GH_USER}/${REPO_NAME}"
echo -e "  ${BOLD}Painel:${NC}      .delta-11/painel.html"
echo ""
echo -e "  ${BOLD}Para começar um projeto:${NC}"
echo -e "  1. Abra uma janela do Claude Code no VS Code"
echo -e "  2. Digite: ${CYAN}d11${NC}"
echo -e "  3. Descreva o que quer construir"
echo -e "  4. Siga as instruções — o sistema te guia"
echo ""
echo -e "  ${BOLD}Para acompanhar:${NC}"
echo -e "  • Kanban no VS Code: abra ${CYAN}.delta-11/kanban.md${NC} e pressione Ctrl+Shift+V"
echo -e "  • Painel visual: clique direito em ${CYAN}.delta-11/painel.html${NC} → Open with Live Server"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
