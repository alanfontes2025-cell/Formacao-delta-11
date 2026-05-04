# Manual Operacional — Boas Práticas Validadas

## Prática 1: Calibrar granularidade de planejamento pelo tipo de incerteza

**Base empírica:** Planning fallacy (Kahneman/Tversky 1994) + Shape Up (Basecamp) + DORA "stable priorities"

**Regra:** Quanto maior a complexidade e incerteza, menor deve ser a granularidade do planejamento.

| Tipo de tarefa | Granularidade recomendada | Por que |
|---------------|--------------------------|---------|
| Tarefa bem conhecida, feita antes | 1-4 horas | Referência histórica existe |
| Tarefa nova em domínio familiar | Meio dia / 1 dia | Espaço para descoberta |
| Tarefa nova em domínio novo | 1-2 semanas (appetite, não estimativa) | Incerteza muito alta para hora |
| Projeto completo de alta complexidade | Ciclos de 6 semanas com escopo variável | Shape Up |

**O que NÃO fazer:** Planejar projeto complexo em tasks de 1 hora. O custo de replanejamento quando a task atrasa (e vai atrasar — planning fallacy) supera o benefício de granularidade.

---

## Prática 2: Minimizar dependências antes de otimizar velocidade

**Base empírica:** Brooks Law (ISBSG 7200 projetos) + Team Topologies (case: lead time 45→14 dias) + Lean/Toyota (flow efficiency)

**Regra:** Uma equipe autônoma de 8 pessoas entrega mais rápido que 3 equipes de 3 com dependências entre si.

**Checklist de dependências (aplicar antes de estruturar time):**
- [ ] Cada equipe pode planejar, executar e entregar sua parte sem aguardar outra equipe?
- [ ] As interfaces entre equipes são contratos claros (API, protocolo, formato)?
- [ ] Existe pessoa ou equipe "platform" que elimina necessidade de cada equipe reinventar infraestrutura?
- [ ] Se a resposta for "não" para qualquer item: dependência existe. Resolver antes de dividir.

---

## Prática 3: Dimensionar equipes pelo trabalho, não pelo prazo

**Base empírica:** Brooks Law + ISBSG (3-7 membros ótimo, 9+ queda)

**Regra anti-Brooks:** Ao atrasar, não adicione pessoas. Reduza escopo ou adicione tempo.

**Fórmula de canais de comunicação:** Para n pessoas → n(n-1)/2 canais
- 3 pessoas: 3 canais
- 5 pessoas: 10 canais
- 8 pessoas: 28 canais
- 12 pessoas: 66 canais

**Quando adicionar pessoa é seguro:** Apenas se (a) a tarefa nova é paralela e sem dependência com as demais E (b) a pessoa tem rampa de onboarding curta.

---

## Prática 4: Tratar handoffs como desperdício, não como processo

**Base empírica:** Lean/Toyota + Scrum.org (flow efficiency 5-10%)

**O que isso significa operacionalmente:**
- Cada vez que o trabalho passa de uma pessoa para outra = perda de contexto + fila de espera
- Uma tarefa que "demora 2 dias de trabalho" pode levar 3 semanas de calendar time se envolver 5 handoffs
- Solução: colocation de habilidades (a mesma pessoa ou equipe faz design + código + teste quando possível)

**Métrica para aplicar:** Calcule o "tempo de toque" vs "tempo total". Se você trabalha 4 horas numa task que levou 5 dias para chegar em produção, sua flow efficiency é 4h/120h = 3,3%.

---

## Prática 5: Usar deployment frequency como proxy de saúde do processo

**Base empírica:** DORA 2023/2024 (39.000 profissionais)

**O que o DORA diz operacionalmente:**
- Elite: múltiplos deploys por dia, lead time < 1 dia, recuperação < 1 hora, failure rate 5%
- Low: deploys mensais/semestrais, lead time 1-6 meses, recuperação 1-4 semanas, failure rate 40-64%

**A relação não óbvia:** Equipes elite têm MENOS falhas E deployam MAIS. A crença popular de que "deployar rápido = mais risco" é empiricamente falsa para equipes com boas práticas de teste e CI/CD.

**Pré-requisito para não ser contraexemplo:** Automated testing + CI/CD devem existir ANTES de aumentar deployment frequency.

---

## Prática 6: Standups são para criar alinhamento, não para reportar status

**Base empírica:** ScienceDirect 2016 + Tandfonline 2025 (resultados mistos)

**O que a pesquisa mostra:**
- Quando funcionam: criam psychological safety + visibilidade de bloqueios + senso de pertencimento
- Quando falham: viram teatro de status report para o líder + reduzem satisfação + destroem confiança

**Regra:** 15 minutos é suficiente para sincronização SOMENTE se o foco é "o que bloqueia?" e não "o que fiz ontem?". Para projetos de alta complexidade com dependências reais, 15 min/dia pode ser insuficiente — complementar com assíncrono e reuniões estruturadas de desbloqueio.

---

## Prática 7: Cognitive load como critério de design organizacional

**Base empírica:** Team Topologies + InfoQ case study

**Definição prática:** Cognitive load é o quanto uma equipe precisa saber/decidir/gerenciar para entregar seu trabalho. Quando excede a capacidade → a equipe vira gargalo.

**Sinais de excesso de cognitive load:**
- A equipe recebe pedidos de 4+ tipos de domínios diferentes
- Membros trocam de contexto mais de 3 vezes por dia
- A equipe não consegue se aprofundar em nenhum domínio porque cobre tudo superficialmente

**Solução Team Topologies:** Criar equipes de plataforma que encapsulam complexidade técnica → stream-aligned teams ficam com menos cognitive load → entregam mais rápido com menos erros.
