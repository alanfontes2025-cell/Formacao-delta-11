// KANBAN DATA — Formação Δ-11
// Este arquivo é atualizado pelos agentes junto com o kanban.md
// O painel.html lê este arquivo para exibir o dashboard visual
// FORMATO: não altere a estrutura, apenas o conteúdo dentro dos arrays

window.KANBAN_DATA = {
  projeto: "App Demo — Simulação de Tarefas",
  complexidade: "MÉDIA",
  fase_atual: "Fase 4 — Desenvolvimento",
  ultima_atualizacao: "16:50",
  agente_atualizador: "ENGINE",

  // Colunas "a fazer" por agente
  a_fazer: {
    ATLAS: [],
    CRONOS: [
      { id: "T-015", desc: "Monitorar tempo dos agentes na Fase 4" }
    ],
    FRONT: [
      { id: "T-012", desc: "Criar layout da página de configurações" }
    ],
    PIXEL: [
      { id: "T-013", desc: "Estilizar cards do dashboard com animações" },
      { id: "T-014", desc: "Criar componente de gráfico de progresso" }
    ],
    FORM: [
      { id: "T-016", desc: "Criar formulário de edição de perfil" }
    ],
    BACK: [],
    ENGINE: [
      { id: "T-011", desc: "Implementar endpoint de relatórios" }
    ],
    VAULT: [],
    SHIELD: [
      { id: "T-017", desc: "Testar fluxo completo de autenticação" },
      { id: "T-018", desc: "Testar permissões RLS do banco" }
    ],
    SCOUT: []
  },

  // Tarefas em execução
  fazendo: [
    { id: "T-008", desc: "Criando rotas de API para usuários... (75%)", agente: "ENGINE", inicio: "16:32" },
    { id: "T-009", desc: "Montando sidebar e navegação principal", agente: "FRONT", inicio: "16:40" },
    { id: "T-010", desc: "Monitorando tempo e dependências da fase", agente: "CRONOS", inicio: "16:20" }
  ],

  // Tarefas aguardando revisão
  revisao: [
    { id: "T-006", desc: "Componente de login e registro", por: "FORM", revisor: "SHIELD" },
    { id: "T-007", desc: "Tabela de notificações no Supabase", por: "VAULT", revisor: "SHIELD" }
  ],

  // Tarefas concluídas
  concluido: [
    { id: "T-001", desc: "Planejamento e arquitetura do projeto", por: "ATLAS", aprovado: "COMANDANTE", data: "12/03" },
    { id: "T-002", desc: "Criação do banco de dados principal", por: "VAULT", aprovado: "SHIELD", data: "12/03" },
    { id: "T-003", desc: "Políticas RLS para tabela de usuários", por: "VAULT", aprovado: "SHIELD", data: "12/03" },
    { id: "T-004", desc: "Estrutura base do Next.js e layouts", por: "FRONT", aprovado: "SHIELD", data: "12/03" },
    { id: "T-005", desc: "Design system e tokens visuais", por: "PIXEL", aprovado: "SHIELD", data: "12/03" }
  ],

  // Tarefas bloqueadas
  bloqueado: [
    { id: "T-019", desc: "Integração com gateway de pagamento", agente: "ENGINE", motivo: "Aguardando credenciais da API do Stripe", precisa: "COMANDANTE" }
  ]
};
