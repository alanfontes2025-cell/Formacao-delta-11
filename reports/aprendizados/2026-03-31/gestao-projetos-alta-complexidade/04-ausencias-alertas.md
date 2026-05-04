# Ausências e Alertas — Verdades Populares e Silêncios Significativos

## ALERTA-01: "23 minutos para recuperar o foco" — VERDADE POPULAR SEM VALIDAÇÃO PRIMÁRIA

**Onde deveria estar documentado se fosse verdadeiro:** Nos papers publicados por Gloria Mark no CHI 2005 e CHI 2008, com metodologia de observação de campo.

**O que foi verificado:** O número 23 não aparece em nenhum paper publicado. Originou-se de entrevistas da autora para Gallup e Fast Company.

**Impacto do alerta:** Não invalidar o argumento geral (interrupções custam caro). Invalidar o número específico como evidência científica.

---

## ALERTA-02: Spotify Model — documentação original era aspiracional, não descritiva

**Onde deveria estar documentado:** O whitepaper original de 2012 (Henrik Kniberg e Anders Ivarsson) prometia seções sobre "alignment" e "accountability" que nunca foram publicadas.

**Silêncio significativo:** A parte mais importante — como manter alinhamento com alta autonomia — foi omitida do documento original. A maioria das empresas copiou apenas o lado da autonomia.

**Impacto:** Empresas que implementaram o modelo copiaram a estrutura organizacional sem o contexto de maturidade que a Spotify tinha em 2012 (e que o modelo não descrevia).

---

## ALERTA-03: DORA Report — não há dados sobre granularidade de planejamento

**Questão original:** O DORA mede práticas de planejamento hora-a-hora?

**Silêncio verificado:** O DORA mede deployment frequency, lead time, change failure rate e recovery time. NÃO mede granularidade de planejamento, duração de sprints, ou frequência de standups.

**Implicação:** Inferências sobre "planejamento hora-a-hora é contraproducente" NÃO podem ser ancoradas no DORA. A evidência vem de outras fontes (Shape Up, planning fallacy research, cognitive load theory).

---

## ALERTA-04: Standish CHAOS Report não é revisado por pares

**Onde deveria estar documentado:** Em journal acadêmico com metodologia transparente e replicável.

**Silêncio:** A Standish Group nunca publicou a metodologia completa para revisão externa. Os números são amplamente citados mas não são "Ouro" epistêmico.

**Impacto:** Usar como indicação de direção (ágil > waterfall em projetos grandes), não como estatística precisa.

---

## ALERTA-05: "Flow efficiency de 5-10% em equipes Scrum" — fonte são polls informais

**Fonte:** Scrum.org afirma que dado vem de "polls de participantes de cursos Scrum". Não é estudo controlado.

**Silêncio:** Não há paper publicado medindo flow efficiency sistematicamente em equipes de software. O dado é amplamente repetido mas a fonte primária é uma pesquisa informal em sala de aula.

**Impacto:** Direção altamente plausível (a maioria do tempo em projetos é espera, não trabalho ativo). Número específico (5-10%) não verificável.

---

## AUSÊNCIA-01: Pesquisa empírica sobre checkpoints de 15 minutos especificamente para equipes multi-função

Não existe literatura específica sobre "checkpoints de 15 minutos são suficientes para sincronização em projetos complexos multi-função". O que existe:
- Pesquisa sobre daily standup em geral (resultados mistos)
- Teoria sobre coordenação em times distribuídos
- A lacuna: nenhum estudo RCT comparou frequência e duração de checkpoints em projetos de alta complexidade

**Conclusão honesta:** A resposta à pergunta 3 (checkpoints de 15 min) não tem evidência empírica direta. Só inferência a partir de princípios adjacentes.
