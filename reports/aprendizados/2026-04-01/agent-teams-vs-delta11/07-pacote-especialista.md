# Pacote Especialista — Agent Teams para Usuários Delta-11

## Decisão Estratégica

**Agent Teams NÃO substitui Delta-11 hoje. É complementar e ainda imaturo para o caso de uso específico do Delta-11.**

### Por que NÃO substituir ainda:

1. **Blocker crítico — sem sub-agentes por teammate**: O Delta-11 usa build-validator e code-simplifier como sub-agentes disparados pelos próprios agentes. Em Agent Teams, teammates não podem spawnar nada — o Agent tool é removido. Isso elimina toda a pipeline de qualidade automática.

2. **Blocker prático — VS Code**: Split panes não funcionam no terminal integrado do VS Code. O modo in-process funciona, mas perde o visual de janelas separadas que o Delta-11 usa hoje.

3. **Blocker de custo**: Agent Teams exige Opus 4.6 para todos os agentes. Delta-11 pode usar Sonnet/Haiku para agentes de baixo esforço, controlando custo. Com 16 teammates em Opus a ~7x tokens, o custo escala drasticamente.

4. **Sem retomada de sessão**: Quando o contexto esgota, Agent Teams perde o estado dos teammates. Delta-11 persiste estado em arquivos e retoma de onde parou.

### O que Agent Teams tem de MELHOR:

1. **Comunicação direta agente-agente** via mailbox (sem arquivo intermediário)
2. **Self-coordination** — agentes pegam tarefas da lista sem esperar dispatch manual
3. **Zero AppleScript** — sem risco de dispatch na janela errada
4. **Task claiming com file lock automático** — resolve race condition sem código manual

## Caminho Recomendado

### Opção A — Manter Delta-11, observar Agent Teams evoluir
- Continue com Delta-11 como está
- Monitore releases do Claude Code (issues GitHub, changelog)
- Gatilho para reavaliar: suporte a sub-agentes por teammate + VS Code split panes

### Opção B — Híbrido experimental (baixo risco)
- Use Agent Teams para fases de PESQUISA e REVISÃO (sem código)
- ATLAS como lead, spawna 3-4 teammates para investigação paralela
- Delta-11 continua para fases de IMPLEMENTAÇÃO onde sub-agentes são críticos
- Teste em projeto novo, nunca em produção D-11

### Opção C — Migração futura (aguardar maturidade)
- Agent Teams está amadurecendo rapidamente (lançou fev/2026, já v2.1.32)
- Quando suportar: sub-agentes por teammate + VS Code + modelos distintos por papel
- Aí sim faz sentido estudar migração

## Resposta à Pergunta Central

**"Sub-agentes continuam podendo ser usados?"**

Sim, mas com distinção importante:
- **Do lead (sessão principal)**: ✅ Sub-agentes funcionam normalmente
- **De um teammate**: ❌ Agent tool removido — sub-agentes não podem ser spawados por teammates
- **Sub-agentes standalone (sem Agent Teams)**: ✅ Funcionam como sempre

**"Agent Teams é melhor que Delta-11 para context window?"**

Para o problema de contexto: **equivalente**. Ambos resolvem o esgotamento dando context window próprio para cada agente.

Para o sistema completo: **Delta-11 é mais robusto hoje** — tem sub-agentes por agente, retomada de estado, modelos diferentes, e funciona no VS Code sem deps externas.

Agent Teams pode ser melhor **quando amadurecer** (6-12 meses estimado para remover limitações críticas).
