#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// DELTA-11 — Hook PostToolUse: Logar Atividade em Tempo Real
// ═══════════════════════════════════════════════════════════════
// Dispara APÓS cada Write/Edit/Bash. Registra automaticamente
// o que foi feito no activity-log.md para visibilidade de todos
// os agentes trabalhando em paralelo.
// ═══════════════════════════════════════════════════════════════

const fs = require('fs');
const path = require('path');

async function main() {
  let input = '';
  for await (const chunk of process.stdin) {
    input += chunk;
  }

  const data = JSON.parse(input);
  const toolName = data.tool_name;
  const toolInput = data.tool_input || {};
  const cwd = data.cwd || process.cwd();

  // Só logar operações relevantes (Write, Edit, Bash)
  const toolsParaLogar = ['Write', 'Edit', 'Bash'];
  if (!toolsParaLogar.includes(toolName)) {
    process.exit(0);
  }

  // Extrair informações relevantes
  let arquivo = '';
  let descricao = '';

  if (toolName === 'Write' || toolName === 'Edit') {
    const filePath = toolInput.file_path || '';
    arquivo = path.relative(cwd, filePath);

    if (toolName === 'Edit') {
      const oldStr = (toolInput.old_string || '').substring(0, 50);
      descricao = `Edit: "${oldStr}..."`;
    } else {
      descricao = 'Write: arquivo criado/reescrito';
    }
  } else if (toolName === 'Bash') {
    const cmd = (toolInput.command || '').substring(0, 80);
    arquivo = '(terminal)';
    descricao = `Bash: ${cmd}`;
  }

  // Determinar agente (agent_type ou session_id como fallback)
  const agente = data.agent_type || data.session_id?.substring(0, 8) || 'MAIN';

  // Montar linha de log
  const agora = new Date();
  const hora = agora.toTimeString().substring(0, 5);
  const dataStr = agora.toISOString().substring(0, 10);

  // Ler lock ativo para extrair tarefa (se existir)
  // v4.0.1: suporta lock-diretório (novo) e lock-arquivo (legado)
  let tarefa = '—';
  const locksDir = path.join(cwd, '.delta-11', 'locks');
  if (fs.existsSync(locksDir)) {
    try {
      const lockEntries = fs.readdirSync(locksDir).filter(f => f.endsWith('.lock'));
      for (const lockEntry of lockEntries) {
        const lockPath = path.join(locksDir, lockEntry);
        let lockContent;
        try {
          const st = fs.statSync(lockPath);
          if (st.isDirectory()) {
            const metaPath = path.join(lockPath, 'meta');
            lockContent = fs.existsSync(metaPath) ? fs.readFileSync(metaPath, 'utf-8') : '';
          } else {
            lockContent = fs.readFileSync(lockPath, 'utf-8');
          }
        } catch {
          continue;
        }
        const agentMatch = lockContent.match(/^AGENTE:\s*(.+)$/m);
        if (agentMatch && agentMatch[1].trim() === agente) {
          const tarefaMatch = lockContent.match(/^TAREFA:\s*(.+)$/m);
          if (tarefaMatch) {
            tarefa = tarefaMatch[1].trim();
          }
          break;
        }
      }
    } catch {
      // Ignorar erros de leitura de lock
    }
  }

  // Caminho do activity-log
  const logPath = path.join(cwd, '.delta-11', 'activity-log.md');

  // v4.0.1: mutex atômico (mkdir) para proteger bloco
  // "verificar cabeçalho do dia + append de linha".
  // Sem isso, dois agentes podem ver o marcador ausente e ambos
  // adicionarem o cabeçalho, causando duplicação.
  const mutexPath = path.join(cwd, '.delta-11', 'locks', 'activity-log.mutex');

  // Tentar adquirir mutex (retry com backoff — máximo 10 tentativas = ~1s)
  let mutexAdquirido = false;
  for (let tentativa = 0; tentativa < 10; tentativa++) {
    try {
      fs.mkdirSync(mutexPath);
      mutexAdquirido = true;
      break;
    } catch (err) {
      if (err.code === 'EEXIST') {
        // Backoff de 100ms entre tentativas
        const delay = Date.now() + 100;
        while (Date.now() < delay) { /* busy wait curto */ }
      } else {
        break; // erro real, desistir
      }
    }
  }

  try {
    // Criar arquivo se não existir
    if (!fs.existsSync(logPath)) {
      const header =
        `# Activity Log — Delta-11\n\n` +
        `> Gerado automaticamente por hooks. Não editar manualmente.\n\n`;
      fs.writeFileSync(logPath, header, 'utf-8');
    }

    // Verificar se precisa adicionar cabeçalho do dia
    const conteudo = fs.readFileSync(logPath, 'utf-8');
    const marcadorDia = `## ${dataStr}`;

    let linhaParaAdicionar = '';

    if (!conteudo.includes(marcadorDia)) {
      linhaParaAdicionar +=
        `\n${marcadorDia}\n\n` +
        `| Hora  | Agente | Tarefa | Arquivo | Ação | Descrição |\n` +
        `|-------|--------|--------|---------|------|-----------|\n`;
    }

    // Escapar pipes no conteúdo da descrição
    const descricaoSafe = descricao.replace(/\|/g, '\\|');
    const arquivoSafe = arquivo.replace(/\|/g, '\\|');

    linhaParaAdicionar += `| ${hora} | ${agente} | ${tarefa} | ${arquivoSafe} | ${toolName} | ${descricaoSafe} |\n`;

    // Append atômico (O_APPEND garante atomicidade para writes pequenos no POSIX)
    fs.appendFileSync(logPath, linhaParaAdicionar, 'utf-8');
  } finally {
    // Liberar mutex SEMPRE, mesmo em erro
    if (mutexAdquirido) {
      try {
        fs.rmSync(mutexPath, { recursive: true, force: true });
      } catch {
        // Se falhar ao liberar, não bloqueia — release-locks vai pegar depois
      }
    }
  }

  process.exit(0);
}

main().catch((err) => {
  // Erros de logging não devem bloquear execução
  process.stderr.write(`Aviso hook log-activity: ${err.message}`);
  process.exit(1);
});
