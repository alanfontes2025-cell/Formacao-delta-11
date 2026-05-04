# CLASSIFICAÇÃO DE PROJETOS — FORMAÇÃO Δ-11

## CRITÉRIOS (usado pelo ATLAS na Fase 1)

| Critério | 1 ponto | 2 pontos | 3 pontos |
|---------|---------|----------|----------|
| Telas e rotas | Até 5 | 6 a 15 | Mais de 15 |
| Integrações externas | Nenhuma ou 1 | 2 a 3 | Mais de 3 |
| Modelo de dados | Até 5 tabelas | 6 a 15 tabelas | Mais de 15 |
| Tempo real | Sem | Notificações ao vivo | Edição colaborativa |
| Segurança | Básica | Dados pessoais | Financeiro ou saúde |

## RESULTADO

| Soma | Complexidade | Agentes | Janelas simultâneas |
|------|-------------|---------|---------------------|
| 5-8 | BAIXA | ATLAS + CRONOS + 2 líderes acumuladores (FRONT, BACK) + SHIELD + SCOUT sob demanda | 3 a 4 |
| 9-12 | MÉDIA | Todos os 10 (CRONOS + ATLAS + FRONT + PIXEL + FORM + BACK + ENGINE + VAULT + SHIELD + SCOUT sob demanda) | 5 a 6 |
| 13-15 | ALTA | Todos os 10 com monitoramento reforçado do CRONOS via Code Architect | 6 a 8 |

## USO DO SCORE A PARTIR DA v4.0

**O score continua sendo útil** para o ATLAS na Fase 1 decidir:
- Se FRONT acumula PIXEL+FORM (score < 7) ou se eles são separados (score ≥ 7)
- Se BACK acumula ENGINE+VAULT (score < 7) ou se eles são separados (score ≥ 7)
- Estimativa de escopo e prazo
- Expectativa de quantas janelas simultâneas o comandante vai abrir

**O que MUDOU na v4.0:**

O score **NÃO determina mais se o CRONOS entra no projeto**. A partir da v4.0, o CRONOS é ativado em TODO projeto, independente da complexidade — incluindo projetos de baixa complexidade (score < 7).

**Por quê:** em times de engenharia reais, o arquiteto entrega o blueprint e sai; o gerente de projeto orquestra a execução. Manter essa separação em todos os projetos (e não apenas nos complexos) torna o sistema previsível e escalável. Mesmo um projeto simples precisa de alguém cobrando, sequenciando e destravando.

O score continua indicando a QUANTIDADE de agentes que o CRONOS orquestra, nunca SE o CRONOS orquestra.
