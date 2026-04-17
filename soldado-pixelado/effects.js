// ============================================================
// EFFECTS — Partículas, balas e efeitos de tiro
// ============================================================
window.SOLDADO_EFFECTS = {
  particles: [],
  bullets: [],

  // Cria efeito de tiro na posição (x, y) apontando para direita
  spawnShot: function(x, y) {
    // 1. Flash do cano: partícula grande amarela, dura 4 frames
    this.particles.push({
      x: x,
      y: y - 8,
      vx: 0,
      vy: 0,
      life: 4,
      maxLife: 4,
      type: 'flash',
      size: 20,
      color: '#ffdd00',
    });

    // 2. Faíscas: 8 partículas pequenas em direções aleatórias
    const sparkColors = ['#ff6600', '#ffaa00', '#ffff00', '#ffffff'];
    for (let i = 0; i < 8; i++) {
      const angle = (Math.random() * Math.PI * 0.8) - Math.PI * 0.4; // cone frontal
      const speed = 2 + Math.random() * 6;
      this.particles.push({
        x: x,
        y: y - 4,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 8 + Math.floor(Math.random() * 8),
        maxLife: 15,
        type: 'spark',
        size: 2 + Math.floor(Math.random() * 2),
        color: sparkColors[Math.floor(Math.random() * sparkColors.length)],
      });
    }

    // 3. Bala: projétil se movendo para direita
    this.bullets.push({
      x: x + 4,
      y: y - 5,
      vx: 18,
      vy: 0,
      life: 40,
      maxLife: 40,
      type: 'bullet',
      size: 6,
      color: '#ffffaa',
    });

    // 4. Fumaça: 3 partículas cinzas que sobem lentamente
    for (let i = 0; i < 3; i++) {
      this.particles.push({
        x: x + (Math.random() * 6 - 3),
        y: y - 4 + (Math.random() * 4 - 2),
        vx: -0.3 + (Math.random() * 0.2 - 0.1),
        vy: -0.5 - Math.random() * 0.3,
        life: 20 + Math.floor(Math.random() * 10),
        maxLife: 30,
        type: 'smoke',
        size: 4 + Math.random() * 4,
        color: '#888888',
      });
    }
  },

  // Atualiza todas as partículas (chamado a cada frame)
  update: function() {
    // Atualizar partículas
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];
      p.life--;

      // Mover conforme velocidade
      p.x += p.vx;
      p.y += p.vy;

      // Comportamentos específicos por tipo
      if (p.type === 'spark') {
        // Desaceleração gradual
        p.vx *= 0.9;
        p.vy *= 0.9;
      } else if (p.type === 'smoke') {
        // Fumaça cresce de tamanho
        p.size += 0.3;
      }

      // Remover partículas mortas
      if (p.life <= 0) {
        this.particles.splice(i, 1);
      }
    }

    // Atualizar balas
    for (let i = this.bullets.length - 1; i >= 0; i--) {
      const b = this.bullets[i];
      b.life--;
      b.x += b.vx;
      b.y += b.vy;

      // Remover balas mortas ou fora da tela
      if (b.life <= 0 || b.x > 1200) {
        this.bullets.splice(i, 1);
      }
    }
  },

  // Desenha todas as partículas no canvas
  draw: function(ctx) {
    // Desenhar balas como retângulos amarelos 6x2px
    for (const b of this.bullets) {
      ctx.fillStyle = b.color;
      ctx.fillRect(Math.floor(b.x), Math.floor(b.y), 6, 2);
      // Brilho interno mais claro
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(Math.floor(b.x) + 1, Math.floor(b.y), 3, 1);
    }

    // Desenhar partículas por tipo
    for (const p of this.particles) {
      const alpha = p.life / p.maxLife;

      if (p.type === 'flash') {
        // Flash: quadrado com gradiente de amarelo para laranja, some gradualmente
        const flashAlpha = Math.min(alpha * 1.5, 1);
        ctx.save();
        ctx.globalAlpha = flashAlpha;
        // Núcleo branco central
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(Math.floor(p.x - 6), Math.floor(p.y - 6), 12, 12);
        // Camada amarela
        ctx.fillStyle = '#ffdd00';
        ctx.fillRect(Math.floor(p.x - 10), Math.floor(p.y - 10), 20, 20);
        // Borda laranja
        ctx.globalAlpha = flashAlpha * 0.6;
        ctx.fillStyle = '#ff4400';
        ctx.fillRect(Math.floor(p.x - 14), Math.floor(p.y - 14), 28, 28);
        ctx.restore();

      } else if (p.type === 'spark') {
        // Faíscas: pontinhos coloridos
        ctx.save();
        ctx.globalAlpha = alpha;
        ctx.fillStyle = p.color;
        ctx.fillRect(Math.floor(p.x), Math.floor(p.y), p.size, p.size);
        ctx.restore();

      } else if (p.type === 'smoke') {
        // Fumaça: círculos cinzas semi-transparentes que crescem e somem
        ctx.save();
        ctx.globalAlpha = alpha * 0.4;
        ctx.fillStyle = p.color;
        const r = Math.floor(p.size);
        ctx.beginPath();
        ctx.arc(Math.floor(p.x), Math.floor(p.y), r, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      }
    }
  }
};

// ============================================================
// HUD — Interface estilo arcade
// ============================================================
window.SOLDADO_HUD = {
  score: 0,
  shots: 0,

  // Incrementa score e conta tiros (chamado ao atirar)
  registerShot: function() {
    this.shots++;
    this.score += 100;
  },

  // Mapa de pixels para cada dígito (5 colunas x 5 linhas)
  _digitMap: {
    '0': ['111','101','101','101','111'],
    '1': ['010','110','010','010','111'],
    '2': ['111','001','111','100','111'],
    '3': ['111','001','011','001','111'],
    '4': ['101','101','111','001','001'],
    '5': ['111','100','111','001','111'],
    '6': ['111','100','111','101','111'],
    '7': ['111','001','001','001','001'],
    '8': ['111','101','111','101','111'],
    '9': ['111','101','111','001','111'],
  },

  // Desenha um único dígito em pixel art
  // ctx: contexto, digit: caractere '0'-'9', x/y: posição, scale: tamanho do pixel, color: cor
  _drawDigit: function(ctx, digit, x, y, scale, color) {
    const rows = this._digitMap[digit];
    if (!rows) return;
    ctx.fillStyle = color;
    for (let row = 0; row < rows.length; row++) {
      for (let col = 0; col < rows[row].length; col++) {
        if (rows[row][col] === '1') {
          ctx.fillRect(x + col * scale, y + row * scale, scale, scale);
        }
      }
    }
  },

  // Desenha uma string numérica em pixel art
  // Retorna largura total desenhada
  _drawNumber: function(ctx, text, x, y, scale, color) {
    let curX = x;
    const charW = (3 * scale) + scale; // 3 colunas + 1 de espaço
    for (const ch of String(text)) {
      if (ch === ' ') {
        curX += charW;
        continue;
      }
      this._drawDigit(ctx, ch, curX, y, scale, color);
      curX += charW;
    }
    return curX - x;
  },

  // Desenha texto simples com letras maiúsculas em pixel font 3x5
  _letterMap: {
    'A': ['010','101','111','101','101'],
    'B': ['110','101','110','101','110'],
    'C': ['011','100','100','100','011'],
    'D': ['110','101','101','101','110'],
    'E': ['111','100','111','100','111'],
    'F': ['111','100','111','100','100'],
    'G': ['011','100','101','101','011'],
    'H': ['101','101','111','101','101'],
    'I': ['111','010','010','010','111'],
    'J': ['001','001','001','101','010'],
    'K': ['101','101','110','101','101'],
    'L': ['100','100','100','100','111'],
    'M': ['101','111','101','101','101'],
    'N': ['101','111','111','101','101'],
    'O': ['010','101','101','101','010'],
    'P': ['110','101','110','100','100'],
    'Q': ['010','101','101','110','011'],
    'R': ['110','101','110','101','101'],
    'S': ['011','100','010','001','110'],
    'T': ['111','010','010','010','010'],
    'U': ['101','101','101','101','010'],
    'V': ['101','101','101','010','010'],
    'W': ['101','101','101','111','101'],
    'X': ['101','010','010','010','101'],
    'Y': ['101','101','010','010','010'],
    'Z': ['111','001','010','100','111'],
    ' ': ['000','000','000','000','000'],
  },

  _drawText: function(ctx, text, x, y, scale, color) {
    ctx.fillStyle = color;
    let curX = x;
    const charW = (3 * scale) + scale;
    for (const ch of text.toUpperCase()) {
      const rows = this._letterMap[ch];
      if (rows) {
        for (let row = 0; row < rows.length; row++) {
          for (let col = 0; col < rows[row].length; col++) {
            if (rows[row][col] === '1') {
              ctx.fillRect(curX + col * scale, y + row * scale, scale, scale);
            }
          }
        }
      }
      curX += charW;
    }
    return curX - x;
  },

  // Desenha coração pixelado 8x8 na posição (x, y)
  _drawHeart: function(ctx, x, y) {
    // Mapa do coração (1 = pixel vermelho)
    const heart = [
      '01100110',
      '11111111',
      '11111111',
      '11111111',
      '01111110',
      '00111100',
      '00011000',
      '00000000',
    ];
    ctx.fillStyle = '#ff2244';
    for (let row = 0; row < heart.length; row++) {
      for (let col = 0; col < heart[row].length; col++) {
        if (heart[row][col] === '1') {
          ctx.fillRect(x + col, y + row, 1, 1);
        }
      }
    }
  },

  // Desenha HUD no canvas
  // ctx: context, w: largura, h: altura, tick: frame atual
  draw: function(ctx, w, h, tick) {
    const scale = 2; // escala da pixel font

    // === Barra superior ===
    ctx.fillStyle = 'rgba(0, 0, 0, 0.75)';
    ctx.fillRect(0, 0, w, 28);

    // "1P" à esquerda
    this._drawText(ctx, '1P', 10, 6, scale, '#ffffff');

    // "SCORE" + valor no centro
    const scoreStr = String(this.score).padStart(6, '0');
    const scoreLabelW = this._drawText(ctx, 'SCORE', 0, -999, scale, '#ffdd00'); // medir
    const scoreNumW = (scoreStr.length * (3 * scale + scale));
    const scoreTotalW = scoreLabelW + 4 + scoreNumW;
    const scoreStartX = Math.floor((w - scoreTotalW) / 2);
    this._drawText(ctx, 'SCORE', scoreStartX, 4, scale, '#ffdd00');
    this._drawNumber(ctx, scoreStr, scoreStartX + scoreLabelW + 4, 4, scale, '#ffdd00');

    // "SHOTS" + contador à direita
    const shotsStr = String(this.shots).padStart(4, '0');
    const shotsLabelW = (5 * (3 * scale + scale)); // "SHOTS" = 5 letras
    const shotsNumW = (shotsStr.length * (3 * scale + scale));
    const shotsTotalW = shotsLabelW + 4 + shotsNumW;
    const shotsStartX = w - shotsTotalW - 10;
    this._drawText(ctx, 'SHOTS', shotsStartX, 4, scale, '#00ffcc');
    this._drawNumber(ctx, shotsStr, shotsStartX + shotsLabelW + 4, 4, scale, '#00ffcc');

    // === Barra inferior ===
    ctx.fillStyle = 'rgba(0, 0, 0, 0.75)';
    ctx.fillRect(0, h - 20, w, 20);

    // "INSERT COIN" piscando (visível quando tick % 60 < 30)
    if (tick % 60 < 30) {
      const coinText = 'INSERT COIN';
      const coinW = coinText.length * (3 * scale + scale);
      const coinX = Math.floor((w - coinW) / 2);
      this._drawText(ctx, coinText, coinX, h - 16, scale, '#ff2244');
    }

    // Corações de vida: 3 corações no canto inferior esquerdo
    for (let i = 0; i < 3; i++) {
      this._drawHeart(ctx, 10 + i * 12, h - 16);
    }
  }
};

// ============================================================
// ENGINE — Loop principal de animação
// ============================================================
window.SOLDADO_ENGINE = {
  canvas: null,
  ctx: null,
  tick: 0,
  animStep: 0,
  animTimer: 0,
  isRunning: false,

  // Inicializa e começa a animação
  // canvasId: id do elemento canvas no HTML
  init: function(canvasId) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext('2d');
    this.ctx.imageSmoothingEnabled = false; // pixel art nítida
    this.isRunning = true;
    this.loop();
  },

  // Loop principal (requestAnimationFrame)
  loop: function() {
    if (!this.isRunning) return;

    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // 1. Limpar canvas
    ctx.clearRect(0, 0, w, h);

    // 2. Desenhar background
    window.SOLDADO_STAGE.draw(ctx, w, h, this.tick);

    // 3. Determinar frame atual do sprite
    const anim = window.SOLDADO_SPRITES.animation;
    const currentStep = anim[this.animStep];
    const currentFrame = currentStep.frame;

    // 4. Desenhar soldado (posição: x = w*0.25, y = h*0.38)
    const soldadoX = Math.floor(w * 0.25);
    const soldadoY = Math.floor(h * 0.38);
    window.SOLDADO_SPRITES.draw(ctx, currentFrame, soldadoX, soldadoY);

    // 5. Se frame de tiro (frame 2) e é o primeiro tick deste frame, spawnar efeito
    if (currentFrame === 2 && this.animTimer === 0) {
      // Posição do cano da arma (coluna 13, linha 12 do sprite, scale=4)
      const canoX = soldadoX + (13 * window.SOLDADO_SPRITES.scale);
      const canoY = soldadoY + (12 * window.SOLDADO_SPRITES.scale);
      window.SOLDADO_EFFECTS.spawnShot(canoX, canoY);
      window.SOLDADO_HUD.registerShot();
    }

    // 6. Atualizar e desenhar efeitos
    window.SOLDADO_EFFECTS.update();
    window.SOLDADO_EFFECTS.draw(ctx);

    // 7. Desenhar HUD (por cima de tudo)
    window.SOLDADO_HUD.draw(ctx, w, h, this.tick);

    // 8. Avançar animação
    this.animTimer++;
    if (this.animTimer >= currentStep.duration) {
      this.animTimer = 0;
      this.animStep = (this.animStep + 1) % anim.length;
    }

    // 9. Incrementar tick global
    this.tick++;

    // 10. Próximo frame
    requestAnimationFrame(() => this.loop());
  }
};
