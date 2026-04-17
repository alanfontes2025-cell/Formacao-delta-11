# Plano de Monitoramento

## Fontes Ouro para Monitorar

- https://code.claude.com/docs/en/agent-teams (changelog oficial)
- https://github.com/anthropics/claude-code/issues (issues de limitações)
- https://code.claude.com/docs/en/sub-agents (evolução dos sub-agentes)

## Gatilhos para Reavaliar

1. **Teammates podem spawnar sub-agentes** — issue #32731 resolvida
2. **VS Code split panes suportados** — docs mencionam como limitação atual
3. **Modelos diferentes por teammate** — comunidade já pediu, Anthropic deve implementar
4. **Session resumption para teammates** — listado como limitação conhecida

## Cadência de Verificação

- A cada release major do Claude Code (atualmente saindo mensalmente)
- Ou quando qualquer gatilho acima aparecer em changelog

## Formato de Alerta

Se qualquer gatilho for resolvido, revisar o pacote especialista e recalcular a decisão estratégica entre Delta-11 e Agent Teams.
