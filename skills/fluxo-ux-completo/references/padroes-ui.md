# Padrões Comuns de UI/UX

Referência rápida de padrões comuns para usar na documentação de fluxos.

## Componentes de Feedback

### Toast / Snackbar
**Quando usar:** Feedback rápido de ações (salvou, erro, copiado, etc.)

**Decisões de design:**
- Posição: Topo centro / Topo direita / Bottom centro
- Duração: 3s padrão / 5s com ação / Infinito se erro crítico
- Pode fechar manualmente? Sim/Não
- Empilha múltiplos? Sim (max 3) / Não (substitui)
- Ação secundária? (Desfazer, Ver detalhes, etc.)

**Estados:**
- Success: Verde, ícone ✓
- Error: Vermelho, ícone ✕
- Warning: Amarelo, ícone ⚠
- Info: Azul, ícone ℹ

---

### Modal / Dialog
**Quando usar:** Ação importante que precisa atenção total

**Decisões de design:**
- Tamanho: Small (400px) / Medium (600px) / Large (800px) / Fullscreen
- Fecha com ESC? Sim/Não
- Fecha clicando fora? Sim/Não (cuidado com perda de dados)
- Tem backdrop blur? Sim/Não
- Header fixo? Footer fixo?

**Tipos comuns:**
- **Confirmação:** Sim/Não para ação destrutiva
- **Formulário:** Editar/criar algo
- **Informação:** Apenas mostrar info + fechar
- **Wizard:** Multi-step com progresso

---

### Alert Banner
**Quando usar:** Informação persistente que precisa atenção

**Decisões de design:**
- Posição: Topo da tela / Dentro de seção específica
- Pode fechar? Sim/Não
- Fecha permanentemente? (usa localStorage)
- Tem ação? (Saiba mais, Ativar, etc.)

**Tipos:**
- **Info:** Novidade, update, dica
- **Warning:** Ação necessária, prazo próximo
- **Error:** Problema que precisa correção
- **Success:** Confirmação de ação importante

---

### Skeleton Loader
**Quando usar:** Loading de conteúdo com layout conhecido

**Decisões de design:**
- Forma: Retângulos / Círculos / Formato do componente real
- Animação: Shimmer (wave) / Pulse / Nenhuma
- Cor: Cinza claro / Cor da marca em opacity baixa
- Quantos itens mostrar? (mesmo número do paginado)

---

### Spinner / Loading Indicator
**Quando usar:** Loading sem layout previsível

**Decisões de design:**
- Tipo: Circular / Linear (barra) / Dots / Custom
- Posição: Centro da tela / Inline / No lugar do botão
- Tamanho: 16px (inline) / 32px (seção) / 64px (fullscreen)
- Cor: Primária / Neutral / Contraste

---

## Padrões de Navegação

### Bottom Navigation (Mobile)
**Quando usar:** 3-5 seções principais no app mobile

**Decisões:**
- Quantos items? (ideal: 4-5, max: 5)
- Item ativo muda cor? Tem label?
- Mostra badge de notificação?
- Ação central destacada? (botão flutuante)

---

### Sidebar Navigation
**Quando usar:** Muitas seções, desktop-first

**Decisões:**
- Sempre visível ou colapsável?
- Largura fixa ou responsiva?
- Sub-menus expandem inline ou flyout?
- Posição de ação primária? (topo/bottom)

---

### Breadcrumbs
**Quando usar:** Navegação hierárquica profunda

**Decisões:**
- Mostra home? Mostra ícones?
- Último item é link ou texto?
- Trunca no mobile? Como?

---

## Padrões de Formulário

### Input Field
**Estados obrigatórios:**
- Default (vazio, sem foco)
- Focus (selecionado)
- Filled (com valor válido)
- Error (com mensagem)
- Disabled (não editável)
- Read-only (mostra valor mas não edita)

**Decisões:**
- Label: Floating / Above / Inline
- Helper text: Below / Tooltip
- Error message: Inline below / Toast / Modal
- Validação: On blur / On change / On submit
- Ícone: Leading / Trailing / Ambos

---

### Dropdown / Select
**Decisões:**
- Busca inclusa? (se >10 opções)
- Multi-select? Como mostra selecionados?
- Opções agrupadas?
- Virtualização? (se >100 opções)
- Cria opção nova? (Combobox)

---

### File Upload
**Decisões:**
- Drag & drop? Só botão?
- Preview da imagem/arquivo?
- Múltiplos arquivos?
- Validação: Tipo / Tamanho / Dimensões
- Progresso de upload? (barra, %)
- O que fazer se falhar? (retry, remove)

---

## Padrões de Listagem

### Infinite Scroll
**Quando usar:** Feed contínuo, descoberta

**Decisões:**
- Trigger: Quanto antes do fim? (300px padrão)
- Loading: Skeleton no fim / Spinner
- Fim da lista: Mensagem / Vazio
- Volta ao topo? Botão flutuante (aparece após scroll)

---

### Pagination
**Quando usar:** Dados tabulares, busca específica

**Decisões:**
- Posição: Bottom / Top e Bottom
- Formato: Números / Prev-Next / Jump to page
- Itens por página: Fixo / Selecionável
- Mostra total de items?

---

### Pull to Refresh
**Quando usar:** Apps mobile com dados que mudam

**Decisões:**
- Animação de pull: Seta / Spinner / Custom
- Feedback tátil? (haptic)
- Quanto precisa puxar? (80px padrão)

---

## Padrões de Empty State

### First Use Empty
**Quando:** Usuário nunca criou nada ainda

**Elementos:**
- Ilustração amigável
- Título motivacional
- Texto explicativo breve
- CTA primário grande
- Link "Saiba mais" (opcional)

---

### Search No Results
**Quando:** Busca não retornou nada

**Elementos:**
- Mostra o termo buscado
- Sugestão: "Tente buscar X"
- Limpa busca facilmente
- Mostra itens relacionados (se houver)

---

### Error Empty
**Quando:** Falha ao carregar dados

**Elementos:**
- Ícone de erro
- Mensagem clara do problema
- Botão "Tentar novamente"
- Link "Reportar problema" (opcional)

---

## Padrões de Transição

### Navegação entre telas
- **Push:** Nova tela entra da direita (forward)
- **Pop:** Tela sai para direita (back)
- **Modal:** Slide up de baixo + backdrop
- **Tab switch:** Fade ou nenhuma transição

### Micro-interações
- **Hover:** 150ms ease
- **Click/Tap:** Escala 0.95 + 100ms
- **Expand/Collapse:** 300ms ease-in-out
- **Fade in/out:** 200ms ease

---

## Checklist de Decisões por Componente

Use ao documentar cada tela:

```
FEEDBACK
□ Toast: posição, duração, empilha?
□ Modal: tamanho, fecha como?
□ Alert: pode fechar? tem ação?
□ Loading: skeleton ou spinner?

NAVEGAÇÃO
□ Bottom nav: quantos items?
□ Sidebar: colapsável?
□ Breadcrumbs: mostra home?

FORMULÁRIO
□ Input: tipo de validação?
□ Dropdown: tem busca?
□ Upload: drag&drop?

LISTAGEM
□ Scroll: infinite ou pagination?
□ Pull to refresh?
□ Empty state: qual tipo?

TRANSIÇÃO
□ Entre telas: qual animação?
□ Micro-interações: quais?
```
