# Controvérsias

## Controvérsia 1: $VSCODE_PID é confiável?

**Posição A:** Sim, é a melhor variável disponível (VS Code source code, estável há anos)
**Posição B:** Não é API documentada oficialmente, pode mudar sem aviso

**Resolução:** Usar $VSCODE_PID como indicador PRIMÁRIO mas ter fallback (pgrep -f). É a melhor opção disponível apesar de não ser API pública. Se mudar no futuro, o fallback cobre.

**Grau de certeza:** Verdade Provável Forte

## Controvérsia 2: osascript funciona de dentro da extensão VS Code?

**Posição A:** Sim, osascript não precisa de TTY — comunica via Mach ports com WindowServer
**Posição B:** Pode falhar sem permissão de Acessibilidade

**Resolução:** osascript FUNCIONA de dentro da extensão. A permissão de Acessibilidade é necessária para System Events (keystroke), não para osascript em si. É uma permissão que precisa ser dada uma vez manualmente.

**Grau de certeza:** Verdade Absoluta (testado em produção no Delta-11)

## Controvérsia 3: Windows Terminal é confiável para dispatch?

**Posição A:** wt.exe é o melhor método no Windows — suporta tabs, comandos diretos
**Posição B:** Não vem instalado no Windows 10, nem todos os alunos vão ter

**Resolução:** Usar wt.exe quando disponível, cmd.exe como fallback. Documentar no guia de instalação que Windows Terminal é recomendado.

**Grau de certeza:** Verdade Provável Forte (wt.exe funciona bem onde existe, mas não é universal)
