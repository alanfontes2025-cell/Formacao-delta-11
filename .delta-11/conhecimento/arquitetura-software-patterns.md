# Base de Conhecimento: Arquitetura de Software — ATLAS

Referencia pratica para decisoes arquiteturais em projetos web.

## Padroes de Arquitetura por Complexidade

### Projeto Simples (Score 1-3)
- Monolito Next.js (App Router)
- Supabase como backend completo (auth + database + storage)
- Sem camada de API intermediaria (acesso direto via RLS)
- Deploy: Vercel

### Projeto Medio (Score 4-6)
- Next.js com API Routes como camada intermediaria
- Supabase para dados + auth
- Servicos externos (Stripe, Resend) chamados APENAS pelo servidor
- Separacao clara: paginas → API routes → Supabase
- Deploy: Vercel + Supabase Cloud

### Projeto Complexo (Score 7-10)
- Next.js + API Routes + filas de processamento (Inngest/BullMQ)
- Supabase para dados + auth + real-time
- Cache layer (Redis/Upstash) para dados frequentes
- Servicos externos com circuit breaker e retry
- Deploy: Vercel + Supabase + servicos adicionais

## Principios de Contrato de API

### Formato Padrao de Rota
```
ROTA: [METODO] /api/[recurso]
AUTENTICACAO: [sim/nao] [tipo: JWT/session/API key]
ENTRADA:
  - campo (tipo) [obrigatorio/opcional] — descricao
  - campo.max(N) — limite de caracteres (obrigatorio para strings)
VALIDACAO:
  - regra 1
  - regra 2
SAIDA SUCESSO (200/201):
  { campo: tipo }
SAIDA ERRO:
  400 — { error: "mensagem" } — validacao falhou
  401 — { error: "nao autenticado" }
  403 — { error: "sem permissao" }
  404 — { error: "nao encontrado" }
  429 — { error: "muitas requisicoes" }
  500 — { error: "erro interno" }
```

### Regras de Contrato
- TODO campo string TEM `.max()` definido (previne DoS)
- TODO campo em WHERE/ORDER BY/JOIN TEM indice no banco
- TODA foreign key declara ON DELETE explicitamente
- TODA rota com escrita valida no SERVIDOR (nunca confiar no cliente)
- Servicos externos inicializados ON-DEMAND dentro da funcao (NUNCA no topo do modulo)

## Padroes de Resiliencia

### Timeout + Retry
```
Timeout padrao: 5 segundos
Retry maximo: 3 tentativas
Backoff: exponencial (1s, 2s, 4s)
Circuit breaker: abre apos 5 falhas consecutivas
Graceful degradation: funcionalidade parcial > erro total
```

### Padrao de Inicializacao Segura
```typescript
// ERRADO — crash se variavel ausente
const stripe = new Stripe(process.env.STRIPE_KEY!) // crash no import

// CERTO — inicializacao on-demand
function getStripe() {
  if (!process.env.STRIPE_KEY) throw new Error("STRIPE_KEY nao configurada")
  return new Stripe(process.env.STRIPE_KEY)
}
```

## Decisoes de Schema de Banco

### Tabelas Obrigatorias
- `profiles` — estende auth.users com dados do app
- `audit_log` — registra acoes criticas (quem, quando, o que)

### Campos Obrigatorios em Toda Tabela
- `id` — UUID primary key (default gen_random_uuid())
- `created_at` — timestamp com timezone (default now())
- `updated_at` — timestamp atualizado via trigger

### Convencoes
- Nomes de tabela: plural, snake_case (`user_profiles`)
- Nomes de coluna: singular, snake_case (`first_name`)
- Foreign keys: `[tabela_singular]_id` (`organization_id`)
- Indexes: `idx_[tabela]_[coluna]` (`idx_profiles_user_id`)
- Policies RLS: `[tabela]_[operacao]_[quem]` (`profiles_select_own`)

## Checklist de Arquitetura (antes de finalizar Fase 2)

- [ ] Todas as rotas definidas com formato padrao completo
- [ ] Todas as tabelas com RLS habilitado
- [ ] Todas as strings com .max() definido
- [ ] Todas as FK com ON DELETE definido
- [ ] Servicos externos listados com timeout e retry
- [ ] Variaveis de ambiente listadas com descricao
- [ ] Fluxo de autenticacao definido (signup, login, logout, refresh)
- [ ] Fluxo de erro definido (401 → refresh → retry)
- [ ] Ordem de implementacao definida (banco → API → UI)
