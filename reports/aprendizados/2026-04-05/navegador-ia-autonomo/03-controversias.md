# Controversias Encontradas

## Controversia 1: Uso de RAM do Playwright no ARM64

**Questao critica:** Quanto de memoria o Playwright MCP realmente usa no Apple Silicon?

**Posicao A — Documentacao oficial e benchmarks gerais:**
- Chromium headless tipico: ~200-500MB
- Fonte: benchmarks gerais de Chromium headless
- Nivel: Ouro/Prata

**Posicao B — Comunidade reporta uso elevado na v1.57+:**
- "Chrome for Testing" no ARM64 pode chegar a 2-5GB por instancia
- Fonte: GitHub Issue #38489 do Playwright
- Nivel: Chumbo (relatos de usuarios, nao benchmark formal)

**Origem da divergencia:** Na versao 1.57+, o Playwright trocou o Chromium bundled por "Chrome for Testing" no ARM64, que e mais pesado.

**Consenso atual:** Nao ha benchmark formal. A comunidade reporta uso elevado mas sem dados controlados.

**Recomendacao sob incerteza:** Usar flag `--browser=webkit` ou `--browser=firefox` como alternativa mais leve se o consumo de memoria for problema. Medir no Mac do usuario apos instalacao.

---

## Controversia 2: Lightpanda — Pronto para uso real?

**Questao critica:** O Lightpanda esta maduro o suficiente para ser o navegador principal?

**Posicao A — Marketing e benchmarks proprios:**
- 11x mais rapido, 16x menos memoria
- Fonte: lightpanda.io, Medium, AI for Automation
- Nivel: Prata/Bronze

**Posicao B — Limitacoes reais:**
- Beta, centenas de Web APIs nao implementadas
- Sem renderizacao visual (nao tira screenshots de paginas como usuario ve)
- CORS incompleto
- ~95% de compatibilidade web
- Fonte: GitHub README, issues
- Nivel: Ouro

**Consenso:** Os benchmarks de performance sao reais, mas as limitacoes tambem. NAO serve como navegador principal para automacao que precisa de screenshots ou interacao com sites complexos (SPAs, sites com muito JavaScript dinamico).

**Recomendacao:** Usar como COMPLEMENTO ao Playwright MCP para tarefas que nao precisam de visual (scraping de texto, leitura de HTML). NAO como substituto.

---

## Controversia 3: Claude in Chrome vs Playwright MCP

**Questao critica:** Qual e melhor para o caso do usuario?

**Posicao A — Claude in Chrome:**
- Solucao oficial da Anthropic
- Usa o Chrome real do usuario (sessoes logadas)
- Zero configuracao extra
- Fonte: docs.anthropic.com
- Nivel: Ouro

**Posicao B — Playwright MCP:**
- Mais ferramentas (26 vs ~10)
- Headless (sem janela)
- Nao depende do Chrome estar aberto
- Navegador isolado (nao mexe nas sessoes do usuario)
- Fonte: docs Playwright, GitHub
- Nivel: Ouro

**Consenso:** Nao sao concorrentes — sao COMPLEMENTARES.
- Claude in Chrome: quando precisa acessar sites onde o usuario ja esta logado
- Playwright MCP: quando precisa de automacao headless, isolada, sem depender do Chrome do usuario

**Recomendacao:** Instalar AMBOS. Claude in Chrome para tarefas que precisam de login do usuario. Playwright MCP para automacao autonoma geral.
