# Mapa de Conhecimento — Detecção Cross-Platform

## Grafo de Decisão Completo

```
ENTRADA: Script precisa saber onde está rodando
│
├─ PASSO 1: Qual SO?
│  ├─ uname -s == "Darwin"           → macOS (Intel ou Apple Silicon)
│  ├─ uname -s == "Linux"
│  │  ├─ $WSL_DISTRO_NAME existe?    → WSL (Windows por baixo)
│  │  └─ senão                       → Linux nativo
│  ├─ uname -s starts "MINGW*"       → Windows (Git Bash)
│  └─ uname -s starts "MSYS*"        → Windows (MSYS2)
│
├─ PASSO 2: Dentro do VS Code?
│  ├─ $VSCODE_PID existe             → SIM (extensão ou terminal integrado)
│  │  ├─ $TERM_PROGRAM == "vscode"   → Terminal integrado
│  │  └─ senão                       → Extension host
│  └─ $VSCODE_PID não existe         → NÃO (terminal externo / CLI)
│
├─ PASSO 3: VS Code está rodando? (se não estou dentro dele)
│  ├─ macOS: pgrep -f "Visual Studio Code"
│  ├─ Windows: tasklist.exe /FI "IMAGENAME eq Code.exe"
│  └─ Linux: pgrep -f "Visual Studio Code"
│
└─ PASSO 4: Como disparar?
   ├─ macOS + VS Code aberto → osascript + bundle ID + targeting por janela
   ├─ macOS + VS Code fechado → osascript + Terminal.app + claude CLI
   ├─ Windows + Windows Terminal → wt.exe new-tab
   ├─ Windows + sem WT → start cmd /k
   ├─ Linux + gnome-terminal → gnome-terminal --tab
   ├─ Linux + konsole → konsole --new-tab
   └─ Qualquer + fallback → salvar arquivo + modo manual
```

## Limites Conhecidos

| Limite | Impacto | Workaround |
|--------|---------|------------|
| Linux Wayland não tem xdotool | Dispatch automático impossível | Modo manual |
| WSL1 não tem clip.exe funcional | Clipboard falha | Usar WSL2 |
| Code-OSS pode não ter $VSCODE_PID | Detecção falha em builds OSS | Fallback para pgrep -f |
| Windows Terminal não vem no Win 10 | wt.exe ausente | start cmd /k (nova janela) |
| pgrep não existe no Git Bash | Detecção de processo falha | tasklist.exe |

## Condições de Contorno

- Apple Silicon vs Intel: NENHUMA diferença na automação. Mesmos comandos, mesmos processos.
- VS Code Insiders: bundle ID diferente (com.microsoft.VSCodeInsiders). Script deve tentar ambos.
- Múltiplas janelas VS Code: targeting por título de janela é OBRIGATÓRIO. Sem ele, keystrokes vão pra janela errada.
