#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// DELTA-11 — Hook Stop: Liberar Locks Automaticamente
// ═══════════════════════════════════════════════════════════════
// Dispara quando um agente PARA (sessão encerra, contexto esgota,
// ou parada explícita). Remove todos os locks criados por esse
// agente para que outros possam trabalhar nos mesmos arquivos.
//
// v4.0.1: locks agora são DIRETÓRIOS (mkdir atômico), não arquivos.
// Metadados ficam em <lock>/meta. Retrocompatível com locks-arquivo
// do formato antigo.
// ═══════════════════════════════════════════════════════════════

const fs = require('fs');
const path = require('path');

function lerMetadadosLock(lockPath, stats) {
  // Novo formato (diretório): metadados em <lock>/meta
  if (stats.isDirectory()) {
    const metaPath = path.join(lockPath, 'meta');
    if (fs.existsSync(metaPath)) {
      return fs.readFileSync(metaPath, 'utf-8');
    }
    return '';
  }
  // Formato antigo (arquivo): metadados são o próprio conteúdo
  return fs.readFileSync(lockPath, 'utf-8');
}

function removerLock(lockPath, stats) {
  if (stats.isDirectory()) {
    // Novo formato: rm -rf recursivo (Node 14.14+)
    fs.rmSync(lockPath, { recursive: true, force: true });
  } else {
    // Formato antigo: unlink simples
    fs.unlinkSync(lockPath);
  }
}

async function main() {
  let input = '';
  for await (const chunk of process.stdin) {
    input += chunk;
  }

  const data = JSON.parse(input);
  const cwd = data.cwd || process.cwd();
  const agente = data.agent_type || data.session_id?.substring(0, 8) || '';

  const locksDir = path.join(cwd, '.delta-11', 'locks');

  if (!fs.existsSync(locksDir)) {
    process.exit(0);
  }

  // Listar todas as entradas .lock (diretório novo ou arquivo legado)
  const lockEntries = fs.readdirSync(locksDir).filter(f => f.endsWith('.lock'));
  let removidos = 0;

  for (const lockEntry of lockEntries) {
    const lockPath = path.join(locksDir, lockEntry);

    let stats;
    try {
      stats = fs.statSync(lockPath);
    } catch {
      continue; // entrada sumiu entre listar e stat
    }

    try {
      const content = lerMetadadosLock(lockPath, stats);
      const agentMatch = content.match(/^AGENTE:\s*(.+)$/m);
      const lockAgent = agentMatch ? agentMatch[1].trim() : '';

      const sessionMatch = content.match(/^SESSION:\s*(.+)$/m);
      const lockSession = sessionMatch ? sessionMatch[1].trim() : '';

      const isDonoDoLock =
        (agente && lockAgent === agente) ||
        (data.session_id && lockSession === data.session_id);

      if (isDonoDoLock) {
        removerLock(lockPath, stats);
        removidos++;
      }
    } catch {
      // Se não conseguir ler metadados, remover locks velhos (mais de 2 horas)
      try {
        const idadeMs = Date.now() - stats.mtimeMs;
        const duasHoras = 2 * 60 * 60 * 1000;

        if (idadeMs > duasHoras) {
          removerLock(lockPath, stats);
          removidos++;
        }
      } catch {
        // Ignorar
      }
    }
  }

  // Logar liberação no activity-log
  if (removidos > 0) {
    const logPath = path.join(cwd, '.delta-11', 'activity-log.md');
    if (fs.existsSync(logPath)) {
      const agora = new Date();
      const hora = agora.toTimeString().substring(0, 5);
      const linha = `| ${hora} | ${agente || 'SYSTEM'} | — | (locks) | Release | ${removidos} lock(s) liberado(s) automaticamente |\n`;
      fs.appendFileSync(logPath, linha, 'utf-8');
    }
  }

  process.exit(0);
}

main().catch((err) => {
  process.stderr.write(`Aviso hook release-locks: ${err.message}`);
  process.exit(1);
});
