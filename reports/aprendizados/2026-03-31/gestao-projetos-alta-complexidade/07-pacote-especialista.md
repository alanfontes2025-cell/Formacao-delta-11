# Pacote de Especialização Reutilizável

## Respostas diretas às 8 questões — com grau de certeza explícito

---

### QUESTÃO 1: O que a evidência empírica diz sobre planejamento com granularidade de 1 hora?

**Resposta:** Contraproducente em projetos de alta complexidade. Não existe evidência empírica direta testando "1 hora vs outras granularidades", mas a convergência de múltiplas linhas de evidência aponta claramente:

1. **Planning fallacy (Kahneman/Tversky, 1979/1994):** Pessoas subestimam sistematicamente o tempo necessário. Estudantes estimaram 33,9 dias para tese; real foi 55,5 dias (+64%). O efeito é pior em tarefas novas.

2. **Shape Up (Basecamp):** A metodologia é explicitamente construída em oposição ao planejamento hora-a-hora. A distinção fundamental: "estimate" (começa com design, termina com número) vs "appetite" (começa com número, termina com design que cabe nele). Ao planejar em horas, você usa estimates, que são altamente imprecisas em trabalho criativo/complexo.

3. **DORA 2024:** "Stable priorities" é um dos mais fortes preditores de performance. Planejamento muito granular cria instabilidade de prioridades quando tasks atrasam (e vão atrasar).

4. **Custo de replanejamento:** Quando a task de 1 hora vira 3 horas (planning fallacy), você precisa rebalancear todo o plano. Com 50 tasks de 1 hora, isso acontece constantemente.

**Grau de certeza:** Verdade Provável Forte (sem RCT direto, mas convergência de 3+ linhas independentes).

**Exceção legítima:** Tarefas altamente rotineiras com histórico de execução (ex: "migrar tabela X para formato Y — já fizemos isso 20 vezes") têm estimativa em horas confiável.

---

### QUESTÃO 2: O que acontece com equipes que têm muitas dependências entre funções?

**Resposta:** Gargalos exponenciais. A evidência é robusta:

1. **Brooks Law — empiricamente suportado:** Análise de 7.200 projetos mostra que adicionar pessoas a projetos com alta interdependência piora o resultado. Equipes de 9+ pessoas têm queda significativa de produtividade (ISBSG, 1.000+ projetos).

2. **Fórmula de canais:** n(n-1)/2. Com 10 pessoas = 45 canais potenciais. Com 5 equipes de 5 = 10 canais internos cada + N canais entre equipes. Dependências externas multiplicam a carga.

3. **Spotify Model failure:** A falha documentada do modelo Spotify foi exatamente isso — squads com alta autonomia, mas sem mecanismo de coordenação quando precisavam colaborar. "Coordenação entre squads se provou mais difícil do que esperado" (Jeremiah Lee, 2020).

4. **Team Topologies:** O framework inteiro existe porque dependências inter-equipe são o principal gargalo de entrega em organizações de médio/grande porte. Case documentado: redução de 22% em cognitive load + lead time de 45 para 14 dias em 6 meses ao redesenhar as dependências.

**Grau de certeza:** Verdade Absoluta para a direção (dependências aumentam lead time). Verdade Provável Forte para a magnitude.

---

### QUESTÃO 3: Checkpoints de 15 minutos são suficientes para sincronização em projetos complexos?

**Resposta:** Insuficientes como único mecanismo, mas úteis como âncora diária.

**O que a pesquisa diz:**
- Daily standup de 15 min tem evidências mistas (ScienceDirect 2016, Tandfonline 2025)
- Quando funciona bem: cria visibilidade de bloqueios e senso de alinhamento
- Quando falha: vira teatro de status report, reduz satisfação no trabalho

**O ponto crítico que a literatura NÃO endereça diretamente:** Em projetos de alta complexidade com múltiplas funções trabalhando em paralelo, os bloqueios não aparecem no ritmo de 24 horas — eles aparecem em horas. Um checkpoint de 15 min às 9h não captura o bloqueio que surgiu às 14h.

**O que as equipes elite realmente fazem (DORA + Lean):** Combinação de
- Sincronização assíncrona contínua (canais de comunicação sempre visíveis)
- Reunião diária curta como âncora
- Mecanismo de escalação rápida para bloqueios (não esperar o próximo standup)

**Grau de certeza:** Verdade Provável Fraca para "15 min é suficiente em projetos complexos". Não existe evidência empírica direta sobre esse ponto específico.

---

### QUESTÃO 4: O que o DORA report diz sobre deployment frequency?

**Resposta:** Os números são os mais robustos desta pesquisa inteira (39.000 profissionais, pesquisa anual).

| Métrica | Elite (19%) | Low (25%) | Diferença |
|---------|-------------|-----------|-----------|
| Deployment frequency | Múltiplos/dia | Mensal-semestral | 182x mais deploys |
| Lead time | < 1 dia | 1-6 meses | 127x mais rápido |
| Change failure rate | 5% | 40-64% | 8x menos falhas |
| Recovery time | < 1 hora | 1-4 semanas | 2.293x mais rápido |

**O que diferencia equipes elite (DORA 2024):**
1. Psychological safety (mais forte preditor individual)
2. Stable priorities (oscilação de prioridades = queda de performance + burnout)
3. Transformational leadership
4. High-quality documentation
5. Solid CI/CD + automated testing ANTES de adotar AI tools

**Insight não óbvio:** Em 2024, o DORA teve que escolher entre duas definições de "high performer": quem deploya mais com failure rate maior OU quem deploya menos com failure rate menor. Escolheu o primeiro. Isso indica que velocidade e estabilidade não são opostos para elite — são simultâneos.

**Grau de certeza:** Verdade Absoluta (fonte primária Ouro com 39.000 respondentes).

---

### QUESTÃO 5: O que a literatura diz sobre handoff overhead?

**Resposta:** O custo é sistematicamente subestimado e constitui a maior fonte de desperdício em desenvolvimento de software.

**Dados:**
1. **Flow efficiency de equipes Scrum:** 5-10% segundo polls Scrum.org. Significa que 90-95% do tempo de uma tarefa é fila de espera, não trabalho ativo.

2. **Toyota/Lean:** "Much of the waste in knowledge work occurs in the handoffs (wait time) between team members, not within the steps themselves."

3. **Atenção residual (Sophie Leroy, University of Washington):** Performance cai após troca de tarefa porque parte da atenção fica "presa" na tarefa anterior. Isso é diferente do número 23 min de Gloria Mark (que é Verdade Popular, não paper) — mas o mecanismo é confirmado.

4. **Trabalho interrompido leva 2x mais e tem 2x mais erros** (pesquisa sobre task switching, múltiplas fontes).

**O que isso significa para handoffs entre pessoas (não apenas interrupções):** Cada handoff é uma interrupção forçada + perda de contexto implícito + período de ramp-up para quem recebe. Em projeto com 5 handoffs por feature, a flow efficiency pode ser <3%.

**Grau de certeza:** Verdade Provável Forte para a direção e magnitude aproximada. Números específicos (5-10%) são de polls informais, não estudos controlados.

---

### QUESTÃO 6: O modelo Spotify teve problemas reais? Quais?

**Resposta:** Sim. A empresa abandonou o modelo. Os problemas são documentados e públicos.

**Fonte primária:** Declaração pública da Spotify + análise MIT Sloan 2020 por Jeremiah Lee com acesso a coaches internos.

**Problemas específicos documentados:**

1. **Accountability gap:** Chapter leads não tinham responsabilidade pela entrega. Product managers tinham que negociar com múltiplos chapter leads (engineering, design, QA) sem ter equivalente em engenharia. Escalações chegavam ao Director of Tribe sem resolução.

2. **Autonomia sem alinhamento:** Cada squad desenvolveu workflows únicos. Resultado: "weird subcultures where you're not really working for the same company anymore." Sem mecanismo de coordenação quando squads precisavam colaborar.

3. **Whitepaper incompleto:** O documento original cobriu autonomia mas nunca publicou as seções prometidas sobre alignment e accountability. Empresas copiaram metade do modelo.

4. **Skill gaps:** Muitos funcionários não entendiam práticas ágeis básicas. Squads "iterated through process tweaks in blind hope."

5. **O modelo era aspiracional, não descritivo:** O whitepaper descrevia onde a Spotify QUERIA chegar, não onde estava. Empresas implementaram o alvo como se fosse o ponto de partida.

**Grau de certeza:** Verdade Absoluta para "Spotify abandonou o modelo". Verdade Provável Forte para os problemas específicos (fonte: coaches internos citados por Lee, não dados quantitativos).

---

### QUESTÃO 7: O que é cognitive load em Team Topologies e por que é crítico?

**Resposta:** Cognitive load é a capacidade cognitiva total de uma equipe — o quanto ela pode absorver, processar e decidir simultaneamente. Team Topologies trata isso como recurso finito que deve ser gerenciado ativamente.

**Definição operacional:** "Cada nova ferramenta, responsabilidade ou domínio adicionado à equipe consome sua largura de banda mental."

**Por que é crítico:** Quando cognitive load excede a capacidade da equipe:
- A equipe vira gargalo (todos esperam por ela)
- Qualidade cai (superficialidade forçada)
- Motivação cai (impossível dominar nenhum domínio)
- Lead time aumenta (decisões lentas, erros aumentam retrabalho)

**O mecanismo central:** Dependências inter-equipe NÃO desaparecem quando você divide uma equipe grande em equipes menores. Elas apenas mudam de intra-equipe para inter-equipe — e aí ficam PIORES porque agora envolvem coordenação formal, reuniões, esperas.

**Evidência quantitativa (única disponível):** Case study InfoQ — redesign organizacional com Team Topologies → -22% cognitive load (autorreportado) + lead time 45→14 dias + deployment frequency 3x + change failure rate 18%→8% em 6 meses.

**Limitação da evidência:** Cognitive load não tem métrica padronizada. O framework usa qualitative assessment, não instrumento validado psicometricamente.

**Grau de certeza:** Verdade Provável Forte para o mecanismo. Verdade Provável Fraca para métricas específicas (1 case study).

---

### QUESTÃO 8: O que acontece quando você tenta fazer "big bang planning"?

**Resposta:** Falha sistêmica, com evidência empírica razoavelmente robusta.

**Dados:**
1. **Standish CHAOS 2020:** Waterfall (BDUF por definição) tem 13% de sucesso vs 42% para agile. Em "huge projects", agile é 600% mais provável de ter sucesso.

2. **Planning fallacy:** Qualquer plano detalhado feito no início maximiza a exposição ao viés de planejamento. Quanto mais detalhe no início, mais suposições falsas são codificadas como verdades.

3. **Shape Up:** "A lot of assumptions are made [in BDUF] that later prove to be false but are designed and possibly already coded." Custo de descobrir erro cedo = baixo. Custo de descobrir após codificar = alto.

4. **DORA "stable priorities":** Big bang planning não é apenas sobre planejar tudo antes — é sobre criar um plano que não pode ser ajustado sem "falhar". Isso é estruturalmente incompatível com o que as equipes elite fazem.

**O mecanismo de falha:**
```
Plano detalhado no início
→ Suposições falsas codificadas
→ Descoberta tardia de problemas
→ Replanejamento massivo
→ Ou: entregar o errado (seguiu o plano)
→ Ou: atrasar muito (replanejou caro)
```

**Onde o big bang planning funciona:** Projetos com especificações completamente fixas, sem descoberta incremental (ex: construção civil, regulatório com requisitos legais imutáveis). Para software — onde os requisitos evoluem com o aprendizado — o big bang planning é estruturalmente inadequado.

**Grau de certeza:** Verdade Provável Forte para "BDUF é contraproducente em projetos de software complexo". Ressalva: metodologia Standish é contestada. Mas a direção do efeito tem convergência de múltiplas fontes independentes.
