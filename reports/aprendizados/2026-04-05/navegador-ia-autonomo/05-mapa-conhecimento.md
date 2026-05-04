# Mapa de Conhecimento — Navegadores para IAs

## Taxonomia: 4 categorias de solucoes

```
NAVEGADORES PARA IAS
|
├── CATEGORIA 1: LOCAL + GRATIS (roda no seu Mac)
│   ├── Claude in Chrome (Anthropic) — usa SEU Chrome real
│   ├── Playwright MCP (Microsoft) — abre um Chrome separado, invisivel
│   ├── Lightpanda — navegador ultraleve proprio (sem visual)
│   └── Chrome DevTools MCP (Google) — acesso ao "painel tecnico" do Chrome
│
├── CATEGORIA 2: LOCAL + FRAMEWORK (roda no seu Mac, mais complexo)
│   ├── Browser Use — agente autonomo que navega sozinho
│   ├── Stagehand (modo local) — mistura IA com codigo
│   └── Vercel Agent-Browser — eficiente em tokens, CLI
│
├── CATEGORIA 3: NUVEM (roda em servidor remoto, voce paga)
│   ├── Browserbase — lider de mercado, anti-bloqueio
│   ├── Steel (cloud) — alternativa open-source ao Browserbase
│   ├── Browserless.io — foco empresarial, certificacoes
│   └── AgentQL — camada de busca inteligente (nao e navegador)
│
└── CATEGORIA 4: HIBRIDO (pode rodar local OU nuvem)
    └── Steel (self-hosted via Docker)
```

## Matriz Comparativa Final

### Os 5 Finalistas (com nota de 0 a 10 em cada criterio)

| Criterio (peso) | Claude in Chrome | Playwright MCP | Lightpanda | Browser Use | Steel local |
|---|---|---|---|---|---|
| **MCP com Claude Code (25%)** | 10 (oficial Anthropic) | 10 (oficial Microsoft) | 8 (MCP nativo, beta) | 9 (MCP nativo) | 8 (MCP oficial) |
| **Headless/autonomo (20%)** | 5 (precisa Chrome aberto) | 10 (100% headless) | 10 (100% headless) | 10 (headless padrao) | 10 (100% headless) |
| **macOS ARM64 (15%)** | 10 (nativo) | 10 (nativo) | 10 (binario nativo Zig) | 9 (via Playwright) | 7 (via Docker ARM64) |
| **Uso de RAM (15%)** | 0 (usa o Chrome todo) | 6 (200-500MB) | 10 (24MB!) | 5 (200MB+ Chromium) | 5 (Docker + Chrome) |
| **Facilidade instalar (10%)** | 10 (1 comando) | 10 (1 comando) | 7 (download manual) | 7 (requer Python) | 4 (requer Docker) |
| **Funcoes completas (10%)** | 8 (navega, clica, print, console) | 10 (26 ferramentas) | 4 (sem print visual, sem CSS) | 9 (agente autonomo) | 8 (completo) |
| **Custo (5%)** | 10 (gratis) | 10 (gratis) | 10 (gratis) | 10 (gratis) | 10 (gratis local) |
| **NOTA FINAL** | **7.3** | **9.1** | **8.0** | **8.0** | **7.0** |

### Detalhamento das notas

**Playwright MCP (9.1) — PRIMEIRO LUGAR**
- Ponto forte: funcionalidade mais completa (26 ferramentas), headless total, 1 comando para instalar
- Ponto fraco: usa 200-500MB de RAM (Chromium por baixo)
- Grau de certeza: VERDADE ABSOLUTA (todas as claims confirmadas por fonte Ouro)

**Lightpanda (8.0) — SEGUNDO LUGAR (empatado)**
- Ponto forte: ULTRALEVE (24MB de RAM!), 11x mais rapido
- Ponto fraco: BETA, nao tira screenshots de paginas renderizadas, muitos sites complexos podem nao funcionar
- Grau de certeza: VERDADE PROVAVEL FORTE (benchmarks confirmados, mas compatibilidade web e ~95%)

**Browser Use (8.0) — SEGUNDO LUGAR (empatado)**
- Ponto forte: agente AUTONOMO (navega sozinho, decide o que clicar)
- Ponto fraco: pesado (usa Chromium completo), requer Python + chave de LLM
- Grau de certeza: VERDADE PROVAVEL FORTE (86k stars no GitHub, comunidade ativa)

**Claude in Chrome (7.3) — TERCEIRO LUGAR**
- Ponto forte: oficial da Anthropic, usa suas sessoes logadas, zero config
- Ponto fraco: precisa do Chrome aberto e visivel, beta, nao e headless
- Grau de certeza: VERDADE ABSOLUTA (documentacao oficial da Anthropic)

**Steel local (7.0) — QUARTO LUGAR**
- Ponto forte: self-hosted, open-source, anti-bloqueio
- Ponto fraco: requer Docker rodando (consome recursos extras)
- Grau de certeza: VERDADE PROVAVEL FORTE (docs oficiais + GitHub)

## Grafo de Relacoes

```
PLAYWRIGHT MCP ←── usa ──→ CHROMIUM (ou Firefox/WebKit)
     ↑                           ↑
     │ (base para)               │ (base para)
     │                           │
BROWSER USE ←── usa ──→ PLAYWRIGHT ←── compativel ──→ LIGHTPANDA (como backend)
     │                                                      │
     │                                                      │ (protocolo CDP)
     │                                                      │
STAGEHAND ←── usa ──→ CDP ←── usa ──→ CHROME DEVTOOLS MCP

CLAUDE IN CHROME ←── controla ──→ SEU CHROME REAL (sessoes logadas)

STEEL / BROWSERBASE ←── roda ──→ CHROMIUM NA NUVEM
```

## Descobertas Importantes

1. **Puppeteer MCP esta MORTO** — arquivado em maio 2025, sem manutencao
2. **Playwright MCP e o padrao de facto** — 30k stars, Microsoft mantendo ativamente
3. **Claude in Chrome e a solucao oficial da Anthropic** — mas precisa do Chrome aberto
4. **Lightpanda e revolucionario em leveza** — mas ainda beta e sem visual
5. **Nenhuma solucao na nuvem vale a pena para o seu caso** — latencia + custo sem necessidade
