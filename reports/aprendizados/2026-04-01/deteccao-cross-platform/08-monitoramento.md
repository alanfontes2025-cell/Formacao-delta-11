# Monitoramento — Quando Reabrir Este Estudo

## Fontes Monitoradas

| Fonte | URL | Cadência |
|-------|-----|----------|
| VS Code release notes | https://code.visualstudio.com/updates | A cada release |
| VS Code terminal env vars | GitHub vscode/terminalEnvironment.ts | Trimestral |
| Windows Terminal CLI | https://learn.microsoft.com/en-us/windows/terminal/ | Semestral |
| Claude Code docs | https://docs.anthropic.com/ | A cada release |

## Gatilhos de Reabertura

1. **VS Code mudar $VSCODE_PID** — se a variável for renomeada ou removida, toda a detecção quebra
2. **Claude Code adicionar flag de extensão** — se Anthropic criar uma variável específica para "rodando como extensão", usar em vez de $VSCODE_PID
3. **code CLI ganhar --command** — se VS Code adicionar execução de comandos via CLI, o dispatch cross-platform fica trivial
4. **Wayland ganhar automação universal** — se ydotool ou equivalente virar padrão, adicionar dispatch Linux Wayland
5. **Windows Terminal virar padrão no Win 10** — se wt.exe passar a vir pré-instalado, remover fallback cmd.exe
6. **Novo aluno/cliente reportar falha de dispatch** — qualquer falha real é gatilho de investigação
