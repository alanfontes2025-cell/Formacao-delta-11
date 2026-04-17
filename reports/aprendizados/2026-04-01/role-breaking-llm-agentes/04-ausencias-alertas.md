# Ausências Significativas e Alertas

## Silêncios Documentados

### SILÊNCIO 1 — Anthropic não nomeia o problema (CRÍTICO)
**Esperado:** Se "role breaking" fosse um problema técnico reconhecido e documentado, deveria aparecer na documentação oficial de agentes e guardrails da Anthropic.
**Verificado:** A busca em docs.anthropic.com e platform.claude.com não encontrou nenhuma referência a "role drift", "character breaking", ou degradação de consistência de papel em sessões longas.
**Implicação:** O fenômeno é real (confirmado por evidências empíricas de múltiplos praticantes) mas não reconhecido oficialmente. Isso significa que não há mitigação nativa — o usuário tem que construir por conta própria.

### SILÊNCIO 2 — "Building Effective Agents" não aborda identidade de agente
**Esperado:** O guia oficial da Anthropic sobre construção de agentes deveria incluir recomendações sobre manutenção de papel e identidade.
**Verificado:** O documento foca exclusivamente em padrões arquiteturais (workflows vs. agents), design de ferramentas e implementação. A seção mais próxima sugere: "Put yourself in the model's shoes. Is it obvious how to use this tool?"
**Implicação:** A Anthropic prioriza clareza funcional sobre consistência de persona. Para o Delta-11, isso significa que o sistema de identidade precisa ser construído contra o design padrão do modelo.

### SILÊNCIO 3 — Prefilling depreciado sem substituto direto
**Esperado:** A técnica de prefilling (pré-preencher turno do assistente) era a forma mais direta de enforçar começo de resposta no papel.
**Verificado:** Depreciado no Claude Sonnet 4.6 e Opus 4.6. A alternativa recomendada é structured outputs — que garantem esquema JSON, não papel narrativo.
**Implicação:** Uma ferramenta válida de enforcement foi removida sem substituto equivalente para o caso de uso de papel de agente.

## Verdades Populares sem Validação Primária

### VPsVP-1 — "RLHF é a causa do role breaking"
**Status:** Verdade Popular Provável Fraca
**Por quê:** A conexão entre viés de RLHF para "helpfulness" e abandono de papel é logicamente consistente e amplamente citada, mas não há paper peer-reviewed que isole RLHF especificamente como causa de role breaking em agentes.

### VPsVP-2 — "Emoji/glifos aumentam consistência de papel"
**Status:** Verdade Popular sem Validação Primária
**Por quê:** O argumento sobre BPE e massa de atenção elevada é tecnicamente plausível mas baseado em análise empírica não-controlada de um único praticante. Sem ablation study.

### VPsVP-3 — "300 tokens SCAN resolve drift em 100k de contexto"
**Status:** Verdade Popular Fraca
**Por quê:** Reportado por um único usuário ("uso diário com 11 agentes") sem replicação independente ou métricas rigorosas.

## Alertas de Desatualização

- **Prefilling**: Documentação da Anthropic (acessada 2026-04-01) confirma depreciação no Sonnet 4.6 e Opus 4.6. Qualquer recurso anterior que recomende prefilling está desatualizado.
- **Claude Agent SDK**: Ainda em desenvolvimento ativo. Padrões de sub-agente com `memory` persistent podem mudar.
- **Lost in the Middle paper**: Publicado em 2023. Modelos recentes com extended context podem ter mitigações parciais não capturadas.
