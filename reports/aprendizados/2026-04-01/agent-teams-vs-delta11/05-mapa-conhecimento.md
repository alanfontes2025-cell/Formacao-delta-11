# Mapa de Conhecimento — Agent Teams vs Delta-11

## Arquitetura Agent Teams

```
[Você]
   │
   ▼
[Team Lead] ←── context window próprio
   │              carrega CLAUDE.md
   │              cria task list
   │              spawna teammates
   │
   ├──[Mailbox]──────────────────┐
   │                             │
   ▼                             ▼
[Teammate A]              [Teammate B]
context próprio           context próprio
carrega CLAUDE.md         carrega CLAUDE.md
recebe spawn prompt       recebe spawn prompt
NÃO herda histórico       NÃO herda histórico
NÃO pode spawnar          NÃO pode spawnar
   │                             │
   └──── mensagens diretas ──────┘
              (mailbox)
   │
   ▼
[Task List compartilhada]
pending → in_progress → completed
file locking anti-race condition
```

## Arquitetura Delta-11

```
[Você]
   │
   ▼
[ATLAS] ←── janela VS Code própria
   │         lê CLAUDE.md
   │         lê project-core.md
   │         lê kanban.md
   │         cria prompts de ativação
   │
   ├──[kanban.md]──────────────────┐
   │  [kanban-data.js]             │
   │  [arquivos de estado]         │
   │                               │
   ▼                               ▼
[FRONT/ENGINE/etc.]          [VAULT/SHIELD/etc.]
janela VS Code própria       janela VS Code própria
context limpo                context limpo
lê todos os arquivos         lê todos os arquivos
PODE usar Task tool          PODE usar Task tool
PODE spawnar sub-agentes     PODE spawnar sub-agentes
   │                               │
   └──── comunicação via ──────────┘
         arquivos em disco
         (estado, kanban, locks)
```

## Comparação Estrutural

| Aspecto | Agent Teams | Delta-11 |
|---------|-------------|----------|
| Contexto por agente | Próprio (✅) | Próprio (✅) |
| Comunicação direta | Via mailbox (✅) | Via arquivos (✅ funciona) |
| Task list compartilhada | Nativa (✅) | kanban.md manual (✅ funciona) |
| File locking anti-race | Automático (✅) | Manual (.lock files) (✅ funciona) |
| Session resumption | ❌ Não suportado | ✅ Via arquivos de estado |
| Sub-agentes por teammate | ❌ Agent tool removido | ✅ Task tool disponível |
| Modelos diferentes por agente | ❌ Tudo Opus 4.6 | ✅ Qualquer modelo |
| VS Code split panes | ❌ Não suportado no VS Code | ✅ Janelas nativas do VS Code |
| Custo | ~7x sessão única | Controlável (pode usar Sonnet/Haiku) |
| Retomada de contexto | ❌ Sem /resume para teammates | ✅ Arquivos de estado persistem |
| Experimental | ⚠️ Sim, flags necessárias | ✅ Estável (protocolo próprio) |
| CLAUDE.md por agente | ✅ Carregado automaticamente | ✅ Carregado automaticamente |
| Hooks de qualidade | ✅ TeammateIdle/TaskCompleted | ✅ Hooks + sub-agentes SHIELD |

## Vantagem Decisiva Delta-11 vs Agent Teams

**Agent Teams resolve o problema de contexto** da mesma forma que Delta-11: cada agente tem seu próprio context window.

**Mas Delta-11 vai além em 4 pontos críticos:**
1. Sub-agentes por agente (build-validator, code-simplifier, SHIELD) — Agent Teams proíbe isso
2. Modelos diferentes por papel (ex: SHIELD com Sonnet, economizando custo)
3. Retomada de sessão com estado completo
4. Funciona no VS Code sem tmux/iTerm2

## Onde Agent Teams seria MELHOR que Delta-11

1. Comunicação direta entre agentes sem arquivo intermediário
2. Self-coordination mais fluida (agentes pegam tarefas autonomamente)
3. Menos setup inicial (sem AppleScript, sem dispatch manual)
4. Integrado nativamente ao Claude Code (não precisa de protocolo externo)
5. Hooks nativos para quality gates (TeammateIdle, TaskCompleted)
