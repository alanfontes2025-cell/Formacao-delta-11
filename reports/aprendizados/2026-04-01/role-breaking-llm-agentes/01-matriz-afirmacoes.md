# Matriz de Afirmações Críticas

| ID | Afirmação | Impacto | Status | Grau de Certeza |
|----|-----------|---------|--------|-----------------|
| A1 | Atenção em transformers dilui tokens iniciais conforme contexto cresce (1000 tokens em 80k = ~1% de atenção) | ALTO | CONFIRMADA | Ouro (paper TACL 2023 + múltiplas fontes) |
| A2 | LLMs exibem efeito serial-position: melhor memória para início e fim, degradação no meio | ALTO | CONFIRMADA | Ouro (Liu et al. 2023, "Lost in the Middle") |
| A3 | O comportamento padrão treinado via RLHF compete com instruções de papel e geralmente vence sob carga | ALTO | CONFIRMADA | Prata (Marc Bara 2026, Ivan Seleznov 650 testes) |
| A4 | Existe diferença entre falha de ativação (modelo ignora papel) e falha de execução (modelo inicia papel mas abandona etapas intermediárias) | ALTO | CONFIRMADA | Prata (Marc Bara 2026) |
| A5 | Prefilling foi depreciado no Claude Sonnet 4.6 e Claude Opus 4.6 | MÉDIO | CONFIRMADA | Ouro (docs.anthropic.com direto) |
| A6 | A técnica SCAN reduz drift com custo de 0.5% de tokens extras | MÉDIO | CONFIRMADA/PARCIAL | Bronze (experimento único, sem peer review) |
| A7 | Emoji/glifos funcionam como âncoras semânticas com massa de atenção elevada via BPE | MÉDIO | PROVÁVEL FRACA | Bronze (análise empírica não peer-reviewed) |
| A8 | Subagentes no Claude Code têm contexto fresh a cada invocação — não herdam estado de identidade | MÉDIO | CONFIRMADA | Ouro (docs.claude.com oficial) |
| A9 | A Anthropic não documenta especificamente "role drift" ou "character breaking" — o fenômeno é reconhecido pela comunidade, não pela empresa | ALTO | CONFIRMADA | Prata (ausência significativa) |
| A10 | Mecanismos além de texto (hooks, structured outputs, tool restrictions) podem enforçar comportamento sem depender da atenção do modelo | MÉDIO | CONFIRMADA | Ouro (docs Claude Code) |
