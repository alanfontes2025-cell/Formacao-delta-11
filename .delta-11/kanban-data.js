// KANBAN DATA — Formação Δ-11
// Este arquivo é atualizado pelos agentes junto com o kanban.md
// O painel.html lê este arquivo para exibir o dashboard visual
// FORMATO: não altere a estrutura, apenas o conteúdo dentro dos arrays

window.KANBAN_DATA = {
  projeto: "SalvaHacks Platform",
  complexidade: "ALTA",
  fase_atual: "Fase 4 — Desenvolvimento",
  ultima_atualizacao: "14:32",
  agente_atualizador: "ENGINE",

  a_fazer: {
    ATLAS: [],
    CRONOS: [],
    FRONT: [
      { id: "T-018", desc: "Sidebar responsiva com menu colapsável" },
      { id: "T-019", desc: "Componente de notificações em tempo real" }
    ],
    PIXEL: [
      { id: "T-020", desc: "Tela de dashboard com gráficos de performance" },
      { id: "T-021", desc: "Página de perfil do usuário" }
    ],
    FORM: [
      { id: "T-022", desc: "Formulário de criação de campanha com wizard 3 etapas" }
    ],
    BACK: [],
    ENGINE: [
      { id: "T-015", desc: "Webhook de pagamento Stripe → ativar assinatura" }
    ],
    VAULT: [],
    SHIELD: [
      { id: "T-023", desc: "Testes de integração das rotas de autenticação" },
      { id: "T-024", desc: "Testes de segurança RLS nas tabelas principais" }
    ],
    SCOUT: []
  },

  fazendo: [
    { id: "T-014", desc: "API de listagem de campanhas com paginação... (75%)", agente: "ENGINE", inicio: "14:10" },
    { id: "T-016", desc: "Criando layout base do painel administrativo", agente: "FRONT", inicio: "14:25" }
  ],

  revisao: [
    { id: "T-011", desc: "Middleware de autenticação JWT", por: "BACK", revisor: "SHIELD" },
    { id: "T-012", desc: "Tabelas de usuários e assinaturas no Supabase", por: "VAULT", revisor: "SHIELD" }
  ],

  concluido: [
    { id: "T-001", desc: "Planejamento e arquitetura do projeto", por: "ATLAS", data: "12/03" },
    { id: "T-002", desc: "Definição de contratos de API", por: "ATLAS", data: "12/03" },
    { id: "T-003", desc: "Setup do projeto Next.js + Supabase", por: "VAULT", data: "12/03" },
    { id: "T-005", desc: "Schema do banco de dados completo", por: "VAULT", data: "12/03" },
    { id: "T-008", desc: "Rota de login e cadastro", por: "BACK", data: "12/03" },
    { id: "T-010", desc: "Página de login e cadastro", por: "PIXEL", data: "12/03" }
  ],

  bloqueado: [
    { id: "T-017", desc: "Integração com API do Instagram", agente: "ENGINE", motivo: "Aguardando credenciais do Meta Developer", precisa: "comandante" }
  ]
};
