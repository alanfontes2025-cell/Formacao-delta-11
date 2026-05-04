# Ausências e Alertas

## Verdades Populares sem Validação Primária

1. **"pgrep -x Code detecta VS Code"** — FALSO. Testado e falhou no Mac Mini. O nome do processo varia.

2. **"Basta verificar se `claude` está no PATH para saber se está no terminal"** — FALSO. Ter o CLI instalado não significa estar usando no terminal. O usuário pode estar na extensão VS Code.

3. **"clip.exe funciona no WSL"** — PARCIALMENTE VERDADE. Funciona no WSL2, pode não funcionar no WSL1.

## Silêncios Significativos

1. **Nenhum framework multi-agente documenta auto-dispatch via UI automation.** AutoGen, CrewAI, LangGraph — todos usam API programática ou processo único. O Delta-11 está fazendo algo inédito. Não existem soluções prontas para copiar.

2. **VS Code CLI não tem --command.** Se existisse, resolveria o dispatch cross-platform inteiro. A ausência confirma que a Anthropic/Microsoft não previu esse caso de uso.

3. **Nenhuma documentação sobre diferenças de $VSCODE_PID entre builds.** Code-OSS e VS Code Insiders podem se comportar diferente, mas ninguém testou sistematicamente.

## Alertas de Risco

- **Alunos em Windows 10 sem Windows Terminal:** O `wt.exe` só vem pré-instalado no Windows 11. Win 10 precisa instalar da Microsoft Store. Dispatch automático pode não funcionar.
- **Alunos em Linux com Wayland:** GNOME 42+ usa Wayland por padrão. xdotool não funciona em Wayland. Dispatch automático impossível sem ydotool (experimental, precisa root).
