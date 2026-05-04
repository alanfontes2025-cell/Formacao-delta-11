# FORMAÇÃO Δ-11

Sistema operacional de desenvolvimento de software por inteligência artificial.

10 agentes especializados + 1 comandante humano trabalhando em paralelo no Claude Code.

Funciona em **Windows 10/11**, **macOS** e **Linux** — o sistema detecta o SO automaticamente.

---

## Início Rápido

### 1. Pré-requisitos

| Sistema | O que instalar |
|---------|----------------|
| **Windows** | [Git for Windows](https://git-scm.com/download/win), [VS Code](https://code.visualstudio.com/) + extensão Claude Code, e no PowerShell: `winget install GitHub.cli jqlang.jq` |
| **macOS** | `brew install gh jq` + VS Code + extensão Claude Code |
| **Linux** | `sudo apt install gh jq xdotool` + VS Code + extensão Claude Code |

### 2. Instalar

Abra o terminal (Git Bash no Windows, Terminal no macOS, terminal padrão no Linux):

```bash
cd /caminho/para/Formacao-delta-11
chmod +x instalar.sh
./instalar.sh
```

### 3. Criar projeto novo

```bash
./novo-projeto.sh ~/projetos/meu-app
```

> **No Windows**, você também pode dar duplo-clique em `delta11-novo-projeto.bat` para criar projetos sem abrir o terminal.

### 4. No VS Code com Claude Code, digite

```
d11

Quero construir [descreva seu projeto]
```

O sistema planeja, classifica, e te entrega os prompts prontos para cada janela.

---

## Documentação

- **[GUIA-DO-COMANDANTE.md](GUIA-DO-COMANDANTE.md)** — Manual completo de uso (com seção específica por SO)
- **[CLAUDE.md](CLAUDE.md)** — Instruções que o Claude Code lê automaticamente em cada projeto

---

## Estrutura

```
.delta-11/
├── operativos/          ← Identidade dos 10 agentes (ATLAS, CRONOS, FRONT, ...)
├── memoria/             ← Memória do projeto e estados individuais
├── protocolos/          ← Regras e procedimentos
├── perfis/              ← Modelo, MCP e ferramentas de cada agente (.json)
├── ferramentas/         ← Scripts especializados de cada agente (.sh)
├── conhecimento/        ← Base de conhecimento por agente (.md)
├── hooks/               ← heartbeat / on-stop / pre-compact (rastreamento em tempo real)
├── locks/               ← Locks de arquivos para prevenir conflito entre agentes
├── ativacoes/           ← Prompts de ativação gerados pelos agentes
├── templates/           ← Modelos em branco
├── sub-agentes/         ← build-validator, code-simplifier, contract-tester
├── kanban.md            ← Quadro de tarefas (markdown)
├── kanban-data.js       ← Dados do quadro (alimenta o painel)
└── painel.html          ← Painel visual de acompanhamento
```

---

## Scripts da raiz

| Script | O que faz |
|--------|-----------|
| `instalar.sh` | Instalação inicial (1x) |
| `novo-projeto.sh` | Cria nova pasta de projeto com a Formação Δ-11 |
| `disparar.sh` | Dispara agentes (cross-platform: Windows/macOS/Linux) |
| `sincronizar.sh` | Atualiza Δ-11 em todos os projetos que já têm |
| `task-done.sh` | Golden Path de finalização de tarefa |
| `monitor-delta11.sh` | Monitor em segundo plano (verifica agentes mortos) |
| `vigilante.sh` | Modo manual de monitoramento (legacy — substituído pelos hooks) |
| `delta11-novo-projeto.bat` | Atalho Windows: duplo-clique para criar projeto novo |
| `delta11-disparar.bat` | Atalho Windows: duplo-clique para rodar `disparar.sh` no projeto atual |
