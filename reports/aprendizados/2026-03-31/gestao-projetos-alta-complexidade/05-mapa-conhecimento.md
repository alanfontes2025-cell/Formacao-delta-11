# Mapa de Conhecimento — Gestão de Projetos de Alta Complexidade

## Grafo de Relações Sistêmicas

```
COMPLEXIDADE DO PROJETO
        │
        ├──────────────────────────────────────────────────────┐
        ▼                                                        ▼
TAMANHO DA EQUIPE                                    DEPENDÊNCIAS ENTRE FUNÇÕES
        │                                                        │
        ▼                                                        ▼
Equipes > 7 pessoas                              Handoffs aumentam lead time
→ Canais de comunicação: n(n-1)/2                → Flow efficiency cai para 5-10%
→ Coordenação supera produção                    → 90-95% do tempo é espera
→ Brooks Law: adicionar pessoas atrasa           → Cada handoff = risco de perda de contexto
        │                                                        │
        └──────────────────┬──────────────────────────────────┘
                           ▼
                  COGNITIVE LOAD (Team Topologies)
                           │
                           ├── Excesso → equipe vira gargalo
                           ├── Dependências heterogêneas amplificam carga
                           └── Reduzir carga = aumentar fluxo
                           │
                           ▼
              PLANEJAMENTO E ESTIMATIVA
                           │
                  ┌────────┴────────┐
                  ▼                 ▼
        GRANULARIDADE ALTA    BIG BANG PLANNING
        (hora-a-hora)         (tudo antes de executar)
                  │                 │
                  ▼                 ▼
        Planning Fallacy:     Waterfall: 13% sucesso
        subestima 60%+        vs Agile: 42% sucesso
        do tempo real         (Standish 2020)
                  │
                  ▼
        DORA: elite performers
        → Stable priorities correlaciona
          com maior performance (2024)
        → Planejamento iterativo,
          não "hora a hora"
```

## Onde cada teoria funciona / não funciona

### Shape Up (Basecamp)
- Funciona: equipes pequenas (3-4), produto digital com escopo variável
- Não funciona: projetos regulatórios com escopo fixo, integração com sistemas legados
- Evidência: prática interna da Basecamp + relatos de adoção — não RCT

### Team Topologies
- Funciona: organizações médias/grandes onde dependências são o principal gargalo
- Não funciona: startups de 5 pessoas (overhead organizacional > benefício)
- Evidência: case study (lead time 45→14 dias em 6 meses) — não generalizado

### DORA Metrics
- Funciona: medir performance de entrega de software em qualquer organização
- Não funciona: como prescrição direta (correlação ≠ causalidade)
- Evidência: 39.000+ profissionais — mais robusto empiricamente neste domínio

### Brooks Law
- Funciona: qualquer projeto com alta interdependência de tarefas
- Não funciona: tarefas paralelizáveis sem dependência (ex: adicionar 10 escritores para escrever 10 artigos independentes)
- Evidência: 7200 projetos ISBSG + 4000 projetos (equipes 9+ com queda)

## Pré-requisitos e Condições de Contorno

| Prática | Pré-requisito | Falha quando |
|---------|---------------|--------------|
| WIP limits | Fluxo mapeado e visível | Sem visibilidade do fluxo, limite é arbitrário |
| Daily standup 15min | Psychological safety + facilitação ativa | Sem segurança psicológica, vira teatro |
| Squads autônomos | Definição clara de responsabilidade + alinhamento estratégico | Sem alinhamento → silos + duplicação |
| Planejamento iterativo | Capacidade de refinar e redefinir escopo | Contratos fixos com cliente impossibilitam |
| Deployment frequency alta | Automatização de testes + CI/CD | Sem automação, frequência alta = mais falhas |
