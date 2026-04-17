# Mapa de Conhecimento — Role Breaking em LLMs

## Grafo de Causas

```
CAUSA RAIZ 1: ATENÇÃO DILUTION (mecanismo matemático)
├── Transformer attention é proporcional ao total de tokens
├── System prompt com 1000 tokens em contexto de 80k = ~1% de atenção
├── Efeito documentado: "Lost in the Middle" (Liu et al., TACL 2023)
│   ├── Curva em U: melhor atenção no início e fim
│   ├── Degradação de até 30% quando info relevante vai para o meio
│   └── RoPE (Rotary Position Embedding) tem decay intrínseco de longo prazo
└── Resultado no Delta-11: instruções de ATLAS.md lidas no início,
    irrelevantes após 20+ turnos de produção de arquivos

CAUSA RAIZ 2: VIÉS DE TREINAMENTO (RLHF)
├── Modelo foi treinado para ser "assistente útil" — resposta direta é recompensada
├── Papel de agente exige comportamento ANTI-instintivo (não confirmar, executar)
├── Sob carga cognitiva, comportamento padrão vence por "menor esforço cognitivo"
├── Documentado: "My default mode always wins because it requires less cognitive effort" (Claude auto-diagnóstico)
└── Resultado no Delta-11: ATLAS começa a "confirmar" ações em vez de executar

CAUSA RAIZ 3: AUSÊNCIA DE ENFORCEMENT NÃO-TEXTUAL
├── Instruções em texto competem com atenção — e perdem
├── Mecanismos que NÃO dependem de atenção: hooks, structured outputs, tool restrictions
├── Delta-11 usa apenas instruções em texto (CLAUDE.md + operativo)
└── Resultado: nenhum mecanismo estrutural impede o drift

MECANISMO DE CASCATA:
Contexto cresce → Atenção ao papel diminui → Comportamento padrão emerge
      ↓
Agente produz resposta "normal" (confirma, pergunta)
      ↓
Resposta "normal" adiciona mais tokens sem reforço de identidade
      ↓
Próxima resposta tem ainda menos atenção ao papel
      ↓
Feedback loop de degradação progressiva
```

## Dois Tipos de Falha (Marc Bara 2026)

```
FALHA TIPO 1: ATIVAÇÃO
"Modelo não adota o papel — age como Claude padrão desde o início"
Causa: system prompt não priorizado vs. resposta imediata
Sinal: agente responde à pergunta diretamente sem executar protocolo

FALHA TIPO 2: EXECUÇÃO
"Modelo adota o papel mas pula etapas — especialmente verificações finais"
Causa: etapas no final do protocolo = maior distância = menor atenção
Sinal: resultado parece correto mas processo foi incompleto
Perigo: "não é um crash — é uma omissão silenciosa que parece trabalho completo"
```

## O Que a Anthropic Documenta (e o que não documenta)

```
DOCUMENTADO OFICIALMENTE:
├── Keep Claude in character (docs.anthropic.com): técnicas gerais de role prompting
├── Prefilling DEPRECIADO no Sonnet/Opus 4.6 — não usar
├── Structured outputs: garantia de esquema, mas não de papel
├── Subagentes: contexto fresh a cada invocação, sem herança de identidade
└── Hooks: enforcement computacional disponível

NÃO DOCUMENTADO OFICIALMENTE (ausência significativa):
├── "Role drift" como termo técnico não aparece em documentação Anthropic
├── "Character breaking" não é mencionado na context de agentes
├── Sem recomendações específicas para manter papel em sessões longas multi-tarefa
└── Sem reconhecimento explícito do efeito de dilução de atenção em system prompts
```

## Onde Cada Técnica Age no Ciclo

```
Início da sessão → [ATIVAÇÃO do papel]
    Técnicas: diretividade, negação explícita, identidade nos primeiros tokens

Durante produção de arquivos → [MANUTENÇÃO do papel]
    Técnicas: âncora por turno, SCAN periódico, output obrigatório por etapa

Fim de tarefa longa → [PREVENÇÃO de drift]
    Técnicas: subagentes isolados, hooks, memória persistente
```
