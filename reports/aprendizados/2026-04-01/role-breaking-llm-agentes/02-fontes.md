# Fontes por Nível Epistêmico

## Ouro (Fontes Primárias)

| ID | Fonte | URL | Contribuição |
|----|-------|-----|--------------|
| F01 | Anthropic Docs — Keep Claude in Character | https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/keep-claude-in-character | Técnicas oficiais de role prompting; confirmação de depreciação de prefilling |
| F02 | Anthropic — Claude Code Subagents | https://code.claude.com/docs/en/sub-agents | Arquitetura de subagentes, memória persistente, hooks |
| F03 | Liu et al. (2023) — "Lost in the Middle" | https://arxiv.org/abs/2307.03172 | Fenômeno de atenção documentado peer-reviewed; efeito serial-position em LLMs |
| F04 | Liu et al. — publicado em TACL 2024 | https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00638/119630/ | Versão final do paper; degradação de 30%+ por posição |
| F05 | Anthropic — Building Effective Agents | https://www.anthropic.com/research/building-effective-agents | Arquitetura oficial de agentes; ausência notável de guidance sobre role consistency |

## Prata (Fontes Autoritativas Secundárias)

| ID | Fonte | URL | Contribuição |
|----|-------|-----|--------------|
| F06 | Marc Bara (2026) — "Claude Skills Have Two Reliability Problems" | https://medium.com/@marc.bara.iniesta/claude-skills-have-two-reliability-problems-not-one-299401842ca8 | Distinção entre falha de ativação e falha de execução; 650 testes de Ivan Seleznov |
| F07 | Frederick Smith (2026) — "Persistent LLM Memory Decay" | https://medium.com/@frederick-smith/persistent-llm-memory-decay-drift-continuity-93b1db4bcdb2 | Framework formal de métricas: SDS, IFI, Semantic Decay; cadeia de falha cascata |
| F08 | OpenAI Community — SCAN Technique | https://community.openai.com/t/solving-agent-system-prompt-drift-in-long-sessions-a-300-token-fix/1375139 | Técnica SCAN completa; 4 níveis de intensidade; custo de 0.5% de tokens |
| F09 | stunspot (2026) — "On Persona Prompting" | https://medium.com/@stunspot/on-persona-prompting-8c37e8b2f58c | Análise técnica de âncoras semânticas, BPE e glifos |
| F10 | Redis — Context Rot | https://redis.io/blog/context-rot/ | Definição formal de context rot; attention dilution documentada |

## Bronze (Jornalismo Especializado Rigoroso)

| ID | Fonte | URL | Contribuição |
|----|-------|-----|--------------|
| F11 | DEV Community — Context Drift Fix | https://dev.to/yaseen_tech/why-your-llm-forgets-your-code-after-10-prompts-and-how-to-fix-context-drift-2hak | Casos práticos de context drift com soluções |
| F12 | DEV Community — SCAN Article | https://dev.to/nikolasi/solving-agent-system-prompt-drift-in-long-sessions-a-300-token-fix-1akh | Implementação prática da técnica SCAN |
| F13 | Medium — Long System Prompts | https://medium.com/data-science-collective/why-long-system-prompts-hurt-context-windows-and-how-to-fix-it-7a3696e1cdf9 | Por que prompts longos pioram o problema |
