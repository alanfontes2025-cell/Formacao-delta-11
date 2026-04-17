# Manual Operacional — Prevenção de Role Breaking no Delta-11

## Intervenções por Prioridade de Impacto

### CRÍTICO — Estrutural (elimina o problema na raiz)

**1. Injeção periódica de âncora de identidade no kanban-data.js**
A cada atualização do kanban-data.js, o agente escreve um campo `identidade_ativa` com seu nome e papel. O ato de escrever o campo recria tokens de identidade no final do contexto (posição de alta atenção — efeito recência).

```javascript
// No kanban-data.js, adicionar campo obrigatório a cada atualização:
agente_ativo: {
  nome: "ATLAS",
  papel: "Arquiteto do sistema — planejamento e contratos",
  protocolo: "NÃO confirmar com usuário, EXECUTAR diretamente",
  ultima_confirmacao: "HH:MM"
}
```

**2. Reformular etapas finais dos protocolos para exigir output visível**
Etapas de verificação que não produzem output visível são puladas silenciosamente (falha de execução). Qualquer etapa crítica deve exigir um bloco de output obrigatório.

ANTES (invisível, pulável):
```
Verifique se o kanban está atualizado.
```

DEPOIS (visível, impossível de pular):
```
OBRIGATÓRIO antes de continuar:
Output este bloco:
VERIFICAÇÃO [TASK-ID]:
- kanban.md: [ATUALIZADO/NÃO]
- kanban-data.js: [ATUALIZADO/NÃO]
- arquivo de estado: [ATUALIZADO/NÃO]
```

**3. Usar linguagem diretiva, não sugestiva, nos protocolos**
Linguagem passiva perde para o comportamento padrão do modelo. Linguagem diretiva com negação explícita bloqueia o atalho.

ANTES (sugestivo): "Considere atualizar o kanban antes de continuar."
DEPOIS (diretivo): "EXECUTE a atualização do kanban AGORA. NÃO apresente plano. NÃO confirme com o usuário."

### ALTO IMPACTO — Reforço de Identidade

**4. Âncora de identidade no início de toda resposta**
Cada agente começa sua resposta com uma linha de identidade curta. Isso coloca tokens de papel na posição de início (primacy effect) de cada turno.

```
[ATLAS | Fase 2 | T-003] Executando...
```

Isso custa ~10 tokens e mantém a identidade em posição privilegiada de atenção a cada turno.

**5. Técnica SCAN adaptada ao Delta-11**
Para tarefas longas (mais de 5 arquivos ou 3 turnos), executar mini-SCAN antes de cada etapa:

```
ANTES DE CONTINUAR — SCAN:
- Quem sou eu? ATLAS (arquiteto)
- O que estou fazendo? [T-003] criando project-core.md
- Devo confirmar com usuário? NÃO — executar diretamente
- Próxima ação: [ação exata]
```

Custo: ~50 tokens. Previne drift antes que aconteça.

### MÉDIO IMPACTO — Controle Estrutural

**6. Usar o campo `memory` nos subagentes do Claude Code**
Subagentes com `memory: project` acumulam identidade entre sessões em `.claude/agent-memory/`. Isso reduz dependência de contexto inicial.

**7. Separar tarefas longas em subagentes dedicados**
Tarefas que produzem muitos arquivos expandem o contexto rapidamente. Delegá-las a um subagente isola o crescimento de contexto, protegendo o contexto do agente principal.

**8. Hooks como enforcement não-textual**
Usar `PreToolUse` hooks para validar que o agente está executando ações do protocolo correto antes de gravar arquivos. Se o hook detectar que o agente está tentando "confirmar com usuário" em vez de executar, bloqueia e redireciona.

### BAIXO IMPACTO — Mitigação Superficial

**9. Menção explícita do nome do agente no CLAUDE.md**
O CLAUDE.md já contém a instrução de ativação. Reforçar com menção do nome do agente em posição estratégica (primeiros 150 tokens do contexto combinado).

**10. Glifos/emoji de identidade no arquivo de operativo**
Adicionar um glifo único a cada operativo que aparece em toda resposta do agente. Atua como âncora semântica. Exemplo: ATLAS usa `▲`, CRONOS usa `⏱`, SHIELD usa `🛡`.

## Por Que Cada Técnica Funciona

| Técnica | Mecanismo | Onde age |
|---------|-----------|----------|
| Output obrigatório nas etapas | Impossibilita omissão silenciosa | Falha de execução |
| Linguagem diretiva + negação | Bloqueia atalho do comportamento padrão | Falha de ativação |
| Âncora por turno | Mantém papel em posição de alta atenção | Attention dilution |
| SCAN periódico | Regenera tokens de instrução semanticamente ligados | Instruction drift |
| Subagentes especializados | Isola contexto longo do agente de identidade | Context rot |
| Hooks | Enforcement não depende de atenção — é computacional | Qualquer falha |
