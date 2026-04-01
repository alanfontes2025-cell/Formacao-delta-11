# Fluxo UX Completo

Sistema completo para mapear TODOS os estados e fluxos de experiência do usuário, indo muito além do happy path.

## O que esta skill faz

Transforma uma ideia de feature em documentação completa de UX que inclui:

- ✅ **Todas as telas** do fluxo (não apenas principais)
- ✅ **Todos os estados** de cada tela (loading, empty, error, success, partial)
- ✅ **Todos os modais e popups** em diferentes contextos
- ✅ **Fluxos alternativos** completos (quando usuário clica "não", cancela, etc.)
- ✅ **Casos extremos** (sem internet, sessão expirada, permissões negadas)
- ✅ **Documentação técnica** completa para programadores
- ✅ **Prompts prontos** para IAs de design (Stitch, v0, Figma)
- ✅ **Fluxograma Mermaid** navegável

## Quando usar

Use esta skill quando precisar:

1. **Planejar uma feature nova** - garantir que nenhum estado foi esquecido
2. **Documentar fluxo completo** - todas as telas e interações
3. **Validar planejamento estratégico** - checar se telas casam com objetivos
4. **Gerar designs em IAs** - ter prompts prontos para Stitch, v0, etc.
5. **Passar para programadores** - especificação técnica sem ambiguidades
6. **Evitar bugs de UX** - mapear erros, loading, empty states desde o início

## Como usar

```
Ei, preciso mapear o fluxo completo de UX para [descrever a feature]
```

ou

```
Use a skill fluxo-ux-completo para documentar [feature]
```

A skill vai:
1. Fazer perguntas para entender a feature
2. Explorar TODOS os estados possíveis
3. Validar contra planejamento estratégico (se houver)
4. Gerar 3 artefatos: Markdown técnico + Fluxograma Mermaid + Prompts para IAs

## Artefatos gerados

Ao final, você terá:

### 1. Especificação Técnica (Markdown)
Documento completo com:
- Mapa de telas (árvore de decisão)
- Storyboard detalhado (cada tela, cada estado)
- Casos extremos mapeados
- Validações e tratamento de erros
- Glossário de componentes

### 2. Fluxograma Mermaid
Diagrama visual navegável mostrando:
- Todas as telas
- Todas as transições
- Fluxos alternativos
- Decisões e bifurcações

### 3. Prompts Prontos para IAs
Templates preenchidos para:
- **Stitch** - prompt detalhado seguindo estrutura otimizada
- **v0.dev** - prompt com código TypeScript/React
- **Figma AI** - prompt focado em design system

## Estrutura da skill

```
fluxo-ux-completo/
├── SKILL.md                          # Documentação principal
├── references/
│   ├── tipos-estados.md              # Checklist de TODOS os estados possíveis
│   └── padroes-ui.md                 # Padrões comuns (modais, toasts, etc.)
└── assets/templates/
    ├── spec-template.md              # Template da especificação técnica
    ├── prompt-stitch.txt             # Template de prompt para Stitch
    └── prompt-v0.txt                 # Template de prompt para v0.dev
```

## Diferenciais

**O que outras IAs fazem:**
- Mapeiam apenas 3-5 telas principais (happy path)
- Esquecem estados de loading, empty, error
- Ignoram fluxos alternativos (cancelar, voltar, timeout)
- Não validam contra estratégia de negócio

**O que ESTA skill faz:**
- ✅ Força exploração de TODOS os estados
- ✅ Mapeia cada clique, cada popup, cada bifurcação
- ✅ Valida contra PRD/planejamento estratégico
- ✅ Gera prompts prontos para implementação
- ✅ Documenta casos extremos (offline, erro, limite de plano)

## Exemplos de uso

### Exemplo 1: Sistema de Login
```
Input: "Mapear fluxo de login com email/senha e login social"

Output:
- 12 telas mapeadas (não só 3)
- Estados: loading, erro de validação, erro de API, sucesso
- Fluxos: esqueceu senha, primeiro acesso, sessão expirada
- Casos: sem internet, permissão negada (Google/Apple)
```

### Exemplo 2: Carrinho de Compras
```
Input: "Documentar fluxo de checkout"

Output:
- 8 telas + 5 modais
- Estados: carrinho vazio, produto sem estoque, cupom inválido
- Fluxos: cancelamento, timeout de pagamento, erro na entrega
- Prompts prontos para gerar no Stitch
```

## Recursos incluídos

### Checklist de Estados (`references/tipos-estados.md`)
Lista completa de estados possíveis:
- Estados de dados (empty, loading, error, success, partial, stale, cached)
- Estados de interação (hover, focus, active, disabled, selected)
- Estados de formulário (pristine, valid, invalid, submitting)
- Estados de permissão (granted, denied, revoked)
- Estados de conectividade (online, offline, slow, reconnecting)
- E muito mais...

### Padrões de UI (`references/padroes-ui.md`)
Referência rápida de componentes comuns:
- Toast / Snackbar (quando usar, decisões de design)
- Modal / Dialog (tamanhos, comportamentos)
- Alert Banner
- Skeleton Loader
- Spinner
- Navegação (bottom nav, sidebar, breadcrumbs)
- Formulários (inputs, dropdowns, file upload)
- Listagens (infinite scroll, pagination)
- Empty states

## Antipadrões evitados

Esta skill força você a NÃO cair nestes erros:

❌ Mapear apenas happy path
❌ Assumir comportamentos "óbvios" sem perguntar
❌ Esquecer micro-interações (hover, animações)
❌ Gerar prompts genéricos para IAs
❌ Documentar sem validar estratégia de negócio

## Autor

Criada com a **skill-forge** para resolver o problema de planejamentos incompletos de UX.

Versão: 1.0
Data: 2026-02-16
