# Plano de Monitoramento

## Fontes Monitoradas

| Fonte | URL | O que observar |
|-------|-----|---------------|
| Playwright MCP releases | github.com/microsoft/playwright-mcp/releases | Novas ferramentas, breaking changes, melhorias ARM64 |
| Lightpanda releases | github.com/lightpanda-io/browser/releases | Saida do beta, suporte a screenshots, compatibilidade web |
| Claude in Chrome docs | code.claude.com/docs/en/chrome | Saida do beta, novos recursos, suporte headless |
| Browser Use releases | github.com/browser-use/browser-use/releases | Melhorias no MCP server, reducao de consumo |
| MCP servers registry | github.com/modelcontextprotocol/servers | Novos browser MCP servers |

## Gatilhos para Reabrir Pesquisa

1. **Lightpanda sai do beta** — pode virar a melhor opcao se screenshots e compatibilidade melhorarem
2. **Claude in Chrome ganha modo headless** — eliminaria necessidade do Playwright MCP para muitos casos
3. **Novo navegador AI-nativo com MCP** — o mercado esta em explosao, pode surgir algo melhor
4. **Playwright MCP resolve problema de RAM no ARM64** — confirmaria nota maxima em todos os criterios
5. **Anthropic lanca browser integrado ao Claude Code** — pode tornar tudo isso obsoleto

## Cadencia de Verificacao

- **Por release:** Playwright MCP e Lightpanda (acompanhar cada versao nova)
- **Mensal:** Claude in Chrome (verificar se saiu do beta)
- **Trimestral:** Panorama geral do mercado (novas ferramentas)
