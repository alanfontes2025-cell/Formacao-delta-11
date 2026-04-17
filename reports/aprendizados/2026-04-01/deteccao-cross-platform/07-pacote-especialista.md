# Pacote Especialista — Detecção Cross-Platform para Sistemas Multi-Agente

## Conhecimento Reutilizável

### Regra 1: Detecção de SO — uname -s com pattern matching
```bash
case "$(uname -s)" in
    Darwin)        → macOS
    Linux)         → Linux nativo OU WSL (verificar $WSL_DISTRO_NAME)
    MINGW*|MSYS*)  → Windows Git Bash
esac
```
SEMPRE usar pattern matching (MINGW*) porque o sufixo muda com a versão do Windows.

### Regra 2: Detecção de VS Code — $VSCODE_PID tem prioridade absoluta
$VSCODE_PID é a ÚNICA variável que indica com confiança "estou dentro do VS Code".
Presente tanto no terminal integrado quanto na extensão.
Funciona em macOS, Windows e Linux.

### Regra 3: Detecção de processo VS Code — pgrep -f, NUNCA pgrep -x
macOS/Linux: `pgrep -f "Visual Studio Code"`
Windows: `tasklist.exe /FI "IMAGENAME eq Code.exe"`
pgrep NÃO existe no Git Bash do Windows.

### Regra 4: Automação macOS — bundle ID, NUNCA nome do app
`tell application id "com.microsoft.VSCode"` — funciona em qualquer instalação.
`tell application "Visual Studio Code"` — falha se o nome do .app é diferente.

### Regra 5: Clipboard — cada SO tem o seu
macOS: pbcopy | Windows/WSL: clip.exe | Linux X11: xclip | Linux Wayland: wl-copy

### Regra 6: Dispatch — não existe solução universal
Cada SO precisa de estratégia própria. Ter fallback manual SEMPRE.

### Regra 7: Windows Terminal (wt.exe) — melhor opção Windows mas não universal
Vem no Windows 11. Windows 10 precisa instalar. Fallback: cmd.exe.

## Armadilhas Documentadas

| Armadilha | Onde aprendemos | Como evitar |
|-----------|----------------|-------------|
| pgrep -x "Code" | Mac Mini do comandante (2026-04-01) | Usar pgrep -f |
| Nome do .app hardcoded | Mac com "Visual Studio Code 2" | Usar bundle ID |
| CLI no PATH = modo terminal | Detecção errada de dispatch-mode | $VSCODE_PID primeiro |
| pgrep no Git Bash | Não existe | tasklist.exe |
| xdotool no Wayland | Não funciona | Modo manual |
