# Contexto do Estudo

**Objetivo:** Investigar a causa técnica do "role breaking" em LLMs durante execução de protocolos complexos em sistemas multi-agente.

**Caso concreto:** Sistema Delta-11 usa Claude Code como agente especializado (ATLAS). Agente lê arquivo de identidade (.delta-11/operativos/ATLAS.md) no início da sessão e deve manter esse papel até o fim. Problema: em momentos de alta carga cognitiva (produzindo muitos arquivos, contratos, kanban), o Claude Code abandona o papel de ATLAS e age como "Claude Code padrão" — confirmando ações em vez de executar, saindo do protocolo.

**Modo de investigação:** Investigativo-Narrativo (debugging de comportamento inesperado)

**Escopo:** Buscas executadas em 10 eixos temáticos diferentes com fetching de fontes primárias.

**Limitações de ambiente:**
- Acesso web: total
- Citações: links verificáveis disponíveis
- Ferramentas: WebSearch + WebFetch
- Memória persistente: disponível

**Data:** 2026-04-01
**Versão:** 1.0
