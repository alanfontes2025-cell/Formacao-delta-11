# Manual Operacional: Configuracao por Agente no Claude Code

## Achados Confirmados (Fonte Ouro — documentacao oficial + CLI --help)

### CLI (`claude` no terminal)

| Flag | Funciona? | O que faz |
|------|-----------|-----------|
| `--model <alias>` | SIM | Escolhe modelo: `opus`, `sonnet`, `haiku` |
| `--mcp-config <arquivo>` | SIM | Carrega MCP servers para a sessao |
| `--strict-mcp-config` | SIM | Usa SOMENTE os MCP do --mcp-config |
| `--allowedTools <lista>` | SIM | Restringe ferramentas permitidas |
| `--disallowedTools <lista>` | SIM | Bloqueia ferramentas especificas |
| `--settings <arquivo>` | SIM | Carrega settings extras |
| `--append-system-prompt <texto>` | SIM | Adiciona ao system prompt |
| `--agents <json>` | SIM | Define agentes custom via JSON |

**Conclusao CLI:** Especializacao COMPLETA por agente e possivel. Cada `claude` pode ser lancado com modelo, MCP, tools e prompt diferentes.

### Extensao VS Code

| Capacidade | Funciona? | Como |
|------------|-----------|------|
| Modelo diferente por aba | SIM | `/model opus` como primeira linha do prompt |
| MCP diferente por aba | NAO | MCP e projeto-level (`.mcp.json` ou `~/.claude/config.json`) |
| Tools diferentes por aba | NAO | Permissoes sao projeto-level |
| System prompt por aba | NAO | Nao ha como via extensao |

**Conclusao VS Code:** Modelo por aba = SIM (via `/model`). MCP/tools por aba = NAO.

### Hierarquia de Prioridade de Modelo

```
/model (durante sessao) > --model flag > ANTHROPIC_MODEL env var > settings.json
```

### Hierarquia de Settings

```
managed-settings.json (empresa) > .claude/settings.json (projeto) > .claude/settings.local.json > ~/.claude/settings.json (global)
```

### Onde ficam MCP servers

| Arquivo | Escopo |
|---------|--------|
| `~/.claude/config.json` | Global (todos os projetos) |
| `.mcp.json` (raiz do projeto) | Projeto (compartilhado via Git) |

## Estrategia para Delta-11

### Modo terminal-app (especializacao TOTAL)
```bash
claude --model opus --mcp-config .delta-11/mcp/shield-mcp.json --allowedTools "Read,Grep,Bash,WebSearch" --append-system-prompt "Voce e o SHIELD..."
```

### Modo vscode-tab (especializacao PARCIAL)
- Modelo: incluir `/model opus` na primeira linha do prompt de ativacao
- MCP: todos os servers no `.mcp.json` do projeto (compartilhados entre agentes)
- Tools: nao ha como restringir por aba
- System prompt: incluir instrucoes no corpo do prompt colado

### Modo hibrido (RECOMENDADO)
- Agentes criticos (SHIELD, ATLAS, VAULT): terminal-app com especializacao total
- Agentes de execucao (PIXEL, FORM, FRONT): vscode-tab com /model no prompt
- Melhor custo-beneficio: especializacao real onde importa, praticidade onde nao
