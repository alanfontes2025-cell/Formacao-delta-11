# Pacote Especialista — Role Consistency em LLMs

## O Que Todo Arquiteto de Sistemas Multi-Agente Precisa Saber

### Princípio Fundamental
Instruções em texto não são leis — são sugestões com peso proporcional à atenção disponível no contexto. Em sessões longas, esse peso vai para zero. A única forma de enforçar comportamento de forma robusta é usar mecanismos que não dependem de atenção: hooks computacionais, structured outputs, e restrições de ferramentas.

### Os 3 Erros de Arquitetura Mais Comuns

**Erro 1: Confiar apenas em instruções no início da sessão**
O agente lê o papel uma vez, no início. Após 20+ turnos de trabalho, aquelas instruções têm ~1% da atenção que tinham. O modelo *lembrou* de ler o papel, mas esqueceu que *é* o papel.

**Erro 2: Etapas de verificação sem output visível**
"Verifique o kanban antes de continuar" é invisível. O modelo otimiza para parecer ter verificado sem verificar. Qualquer etapa crítica deve exigir um bloco de output que só pode existir se a etapa foi executada.

**Erro 3: Linguagem sugestiva em protocolos críticos**
"Considere atualizar o estado" compete com o instinto de continuar. "EXECUTE agora. NÃO prossiga sem isto." bloqueia o atalho. A negação explícita é essencial — não é redundância.

### Framework de 4 Camadas para Role Consistency

```
CAMADA 1 — ESTRUTURAL (mais forte, não depende de atenção)
├── Hooks PreToolUse: validam intenção antes de qualquer ação
├── Tool restrictions: subagente fisicamente não pode fazer X
└── Structured outputs: esquema garante forma da resposta

CAMADA 2 — POSICIONAL (explora efeito de primacy/recency)
├── Âncora de identidade no início de cada turno (~10 tokens)
├── Verificação obrigatória no fim de cada etapa (posição recency)
└── Output visível força o modelo a "materializar" a etapa

CAMADA 3 — SEMÂNTICA (reativa conceitos latentes)
├── Mencionar nome do agente explicitamente (ATLAS, não "você")
├── Glifos/símbolos únicos por agente (opcional mas válido)
└── SCAN periódico: modelo responde perguntas sobre suas próprias regras

CAMADA 4 — ARQUITETURAL (isola o problema)
├── Subagentes para tarefas longas (contexto isolado)
├── Memória persistente entre sessões (não depende de contexto)
└── Sessões curtas por agente (cada agente tem contexto limpo)
```

### Diagnóstico: Qual Tipo de Falha Está Acontecendo?

**Falha de Ativação** (agente nunca entrou no papel):
- Sintoma: primeira resposta já é Claude padrão
- Causa: system prompt não capturou atenção
- Solução: linguagem diretiva + negação + identidade nos primeiros 150 tokens

**Falha de Execução** (agente iniciou o papel mas abandonou no meio):
- Sintoma: resposta parece correta mas etapas intermediárias foram puladas
- Causa: etapas no meio/fim do protocolo = baixa atenção
- Solução: output obrigatório por etapa + SCAN periódico

**Drift Progressivo** (agente funciona mas degrada ao longo da sessão):
- Sintoma: primeira hora ok, depois vira Claude padrão
- Causa: contexto crescendo, atenção ao papel diminuindo
- Solução: âncora por turno + subagentes para isolar tarefas longas

### Métricas para Detectar Role Breaking Antes de Virar Problema

1. **Taxa de confirmação**: agente está pedindo confirmação em vez de executar? → Drift começou
2. **Output de identidade ausente**: resposta não começa com `[ATLAS | Fase X | T-XXX]`? → Drift em andamento
3. **Etapas de verificação sem bloco de output**: tarefa concluída sem `VERIFICAÇÃO [T-XXX]`? → Falha de execução silenciosa
4. **Número de turnos sem menção explícita do nome do agente**: mais de 5 turnos sem "ATLAS executa..."? → Risco de drift

### O Que Não Funciona (Armadilhas Documentadas)

- **Repetir o system prompt sem transformação**: adiciona tokens sem atenção proporcional
- **Prefilling no Claude Sonnet/Opus 4.6**: depreciado, não usar
- **Contar apenas com o arquivo de operativo lido no início**: suficiente para 5 turnos, insuficiente para 30+
- **Instruções longas e detalhadas no sistema**: mais tokens = mais dilução. Menos tokens, mais direto = melhor atenção por token
