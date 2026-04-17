# Ausencias e Alertas

## Verdades Populares sem Validacao Primaria

### VP-01: "Playwright MCP usa pouca memoria no ARM64"
**Onde deveria estar documentado:** Benchmarks oficiais do Playwright para ARM64
**Realidade:** NAO existe benchmark oficial de uso de memoria do Playwright MCP no Apple Silicon. Os numeros citados (~200-500MB) sao de benchmarks gerais de Chromium headless, nao especificos para o MCP no ARM64.
**Risco:** Issue #38489 do Playwright reporta que "Chrome for Testing" no ARM64 pode usar significativamente mais memoria (2-5GB citados pela comunidade).
**Acao recomendada:** Medir REAL no Mac do usuario apos instalacao antes de considerar o numero como verdade.

### VP-02: "Lightpanda tem 95% de compatibilidade web"
**Onde deveria estar documentado:** Suite de testes de compatibilidade (WPT ou similar)
**Realidade:** O numero "95%" aparece em artigos e blogs mas NAO ha referencia a um teste formal de compatibilidade (Web Platform Tests). O proprio README do Lightpanda lista centenas de APIs nao implementadas.
**Risco:** Sites com JavaScript complexo (SPAs, React, Angular) podem simplesmente nao funcionar.
**Acao recomendada:** NAO confiar no numero. Testar os sites especificos que o usuario precisa acessar.

## Silencios Significativos

### SS-01: Nenhum benchmark formal compara TODOS os candidatos
**Onde deveria estar:** Artigo tecnico independente ou repositorio de benchmark
**Realidade:** Cada ferramenta tem seus proprios benchmarks (cherry-picked). Nao existe comparacao imparcial com mesma metodologia.
**Impacto:** As notas de "uso de RAM" na matriz comparativa sao estimativas, nao medidas controladas.

### SS-02: Claude in Chrome — sem documentacao de limitacoes
**Onde deveria estar:** Pagina oficial da Anthropic
**Realidade:** A documentacao oficial diz o que funciona mas NAO lista claramente o que NAO funciona ou quais sites/cenarios falham.
**Impacto:** Pode haver limitacoes nao documentadas que so aparecem no uso real.

### SS-03: Nenhuma ferramenta documenta uso de CPU no ARM64
**Onde deveria estar:** Benchmarks de performance
**Realidade:** Todos falam de RAM mas ninguem mede CPU de forma consistente no Apple Silicon.
**Impacto:** A "leveza" e medida apenas por RAM, ignorando impacto na bateria e CPU.
