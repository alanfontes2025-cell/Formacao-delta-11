# Checklist Completo de Estados Possíveis

Use este checklist para garantir que NENHUM estado foi esquecido ao mapear uma tela.

## Estados de Dados

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Empty State** | Não há dados para exibir | O que mostra quando vazio? Tem CTA? Mensagem motivacional? |
| **Loading State** | Dados estão carregando | Skeleton? Spinner? Quanto tempo espera? E se travar? |
| **Error State** | Falha ao carregar dados | Qual mensagem? Tem botão "tentar novamente"? Mostra erro técnico? |
| **Partial State** | Só parte dos dados carregou | Mostra parcial ou esconde tudo? Avisa que tá incompleto? |
| **Success State** | Dados carregados com sucesso | Como são apresentados? Tem paginação? Scroll infinito? |
| **Stale State** | Dados estão desatualizados | Mostra badge "atualizar"? Recarrega automático? |
| **Cached State** | Mostrando dados do cache | Avisa que é cache? Tem indicador de "offline"? |

## Estados de Interação

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Default** | Estado inicial do componente | Como aparece antes de qualquer interação? |
| **Hover** | Mouse em cima (desktop) | Muda cor? Mostra tooltip? |
| **Focus** | Componente selecionado (teclado) | Tem outline? Mudança visual clara? |
| **Active** | Clique/tap em andamento | Mostra feedback tátil? Muda aparência? |
| **Disabled** | Componente desabilitado | Por que tá desabilitado? Tem tooltip explicando? |
| **Selected** | Item selecionado (checkbox, radio) | Mudança visual óbvia? Dá pra desselecionar? |
| **Dragging** | Sendo arrastado | Mostra onde pode soltar? Feedback visual? |

## Estados de Formulário

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Pristine** | Nunca foi tocado | Como sinaliza que tá vazio? Placeholder? |
| **Touched** | Usuário interagiu | Quando valida? No blur? No submit? |
| **Valid** | Validação passou | Mostra ícone verde? Feedback visual? |
| **Invalid** | Validação falhou | Mensagem de erro onde? Cor vermelha? Ícone? |
| **Submitting** | Enviando dados | Botão desabilitado? Mostra loading? Previne duplo submit? |
| **Submitted** | Envio concluído | Limpa form? Redireciona? Mostra confirmação? |
| **Failed Submit** | Envio falhou | Mantém dados preenchidos? Mensagem de erro clara? |

## Estados de Permissão

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Not Requested** | Nunca pediu permissão | Quando pedir? Na hora de usar ou antes? |
| **Requesting** | Aguardando resposta do OS | Mostra loading? Mensagem explicando? |
| **Granted** | Usuário permitiu | Funcionalidade ativa imediatamente? |
| **Denied** | Usuário negou | O que fazer? Mostra fallback? Pede de novo depois? |
| **Revoked** | Permissão removida depois | Detecta e avisa? Pede novamente? |

## Estados de Conectividade

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Online** | Conexão ativa | Tudo funciona normal |
| **Offline** | Sem conexão | Mostra banner? Funcionalidades offline? Cache? |
| **Slow Connection** | Conexão lenta | Mostra aviso? Carrega versão leve? |
| **Reconnecting** | Tentando reconectar | Mostra status? Auto-retry? |

## Estados de Autenticação

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Unauthenticated** | Usuário não logado | Redireciona pra login? Mostra tela pública? |
| **Authenticating** | Login em andamento | Loading? Mensagem? |
| **Authenticated** | Usuário logado | Mostra conteúdo? Carrega dados? |
| **Session Expired** | Sessão expirou | Redireciona? Tenta refresh token? Avisa antes? |
| **Unauthorized** | Sem permissão | Mensagem 403? Redireciona? Pede upgrade? |

## Estados de Pagamento/Assinatura

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Free Tier** | Plano gratuito | Mostra limitações? CTA pra upgrade? |
| **Trial Active** | Em período trial | Mostra countdown? Avisa antes de expirar? |
| **Trial Expired** | Trial acabou | Bloqueia acesso? Mostra paywall? |
| **Paid Active** | Assinatura ativa | Todas features liberadas? |
| **Payment Failed** | Cobrança falhou | Tenta novamente? Avisa usuário? Prazo de graça? |
| **Canceled** | Usuário cancelou | Acesso até fim do período? Mensagem de retenção? |

## Estados de Sincronização

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **Synced** | Tudo sincronizado | Badge verde? Timestamp? |
| **Syncing** | Sincronizando agora | Spinner? Progresso? |
| **Sync Failed** | Falha na sync | Retry manual? Auto-retry? Mensagem? |
| **Conflict** | Dados conflitantes | Mostra diff? Deixa usuário escolher? |

## Estados Temporais

| Estado | Descrição | Perguntas de Validação |
|--------|-----------|------------------------|
| **New** | Criado recentemente | Badge "novo"? Destaque visual? Por quanto tempo? |
| **Updated** | Modificado recentemente | Indicador de mudança? Changelog? |
| **Expiring Soon** | Vai expirar em breve | Aviso? Countdown? CTA pra renovar? |
| **Expired** | Expirado | Trava acesso? Mostra opção de renovar? |
| **Archived** | Arquivado | Ainda acessível? Como desarquivar? |
| **Deleted** | Deletado (soft delete) | Recuperável? Quanto tempo na lixeira? |

## Checklist de Uso

Para cada tela mapeada, passar por esta lista:

```
DADOS
□ Empty - O que mostra?
□ Loading - Como indica?
□ Error - Qual mensagem?
□ Success - Como apresenta?

INTERAÇÃO
□ Default - Estado inicial?
□ Hover - Tem feedback?
□ Focus - Navegação por teclado ok?
□ Disabled - Por quê e como mostra?

FORMULÁRIO (se aplicável)
□ Pristine - Placeholder?
□ Invalid - Mensagem de erro?
□ Submitting - Loading?
□ Failed - Mantém dados?

PERMISSÃO (se aplicável)
□ Denied - Tem fallback?
□ Revoked - Detecta?

CONECTIVIDADE
□ Offline - Funciona?
□ Slow - Otimiza?

AUTENTICAÇÃO
□ Unauthenticated - Redireciona?
□ Session Expired - Avisa?
```

**CRITICAL:** Se marcar "não sei" em qualquer item, PARAR e perguntar ao usuário antes de continuar documentação.
