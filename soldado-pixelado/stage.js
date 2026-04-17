/**
 * SOLDADO PIXELADO — Stage Background
 * Cenário urbano destruído estilo Street Fighter 2 / arcade CPS2
 * Todos os elementos desenhados com primitivas Canvas 2D puras
 */

window.SOLDADO_STAGE = {

  // Posições fixas de estrelas (relativas a 0-1, calculadas uma vez)
  _estrelas: null,

  // Gera estrelas com posições fixas relativas
  _gerarEstrelas: function() {
    if (this._estrelas) return;
    var dados = [];
    // 30 estrelas com posição, tamanho e fase de piscar únicos
    var semente = [
      [0.05, 0.08], [0.13, 0.03], [0.22, 0.12], [0.31, 0.05],
      [0.42, 0.15], [0.51, 0.02], [0.60, 0.09], [0.70, 0.04],
      [0.80, 0.13], [0.88, 0.07], [0.95, 0.11], [0.08, 0.22],
      [0.18, 0.28], [0.29, 0.19], [0.38, 0.31], [0.47, 0.17],
      [0.55, 0.25], [0.66, 0.20], [0.75, 0.29], [0.85, 0.16],
      [0.93, 0.24], [0.03, 0.33], [0.15, 0.36], [0.27, 0.37],
      [0.36, 0.22], [0.58, 0.34], [0.67, 0.10], [0.78, 0.38],
      [0.90, 0.30], [0.48, 0.08]
    ];
    for (var i = 0; i < semente.length; i++) {
      dados.push({
        rx: semente[i][0],
        ry: semente[i][1] * 0.38, // só no céu (0% a 38% da altura)
        fase: i * 17,              // offset de fase para piscar dessincronizado
        tamanho: (i % 3 === 0) ? 2 : 1
      });
    }
    this._estrelas = dados;
  },

  // Desenha o background completo
  // ctx: CanvasRenderingContext2D
  // w: largura do canvas
  // h: altura do canvas
  // tick: frame atual (para animações)
  draw: function(ctx, w, h, tick) {
    this._gerarEstrelas();

    // ─── 1. CÉU NOTURNO ────────────────────────────────────────────────────
    var altCeu = Math.floor(h * 0.42);

    // Gradiente manual em blocos de 2px — de roxo escuro (topo) a azul-roxo (horizonte)
    var coresCeu = [
      '#1a0a2e', '#1b0b30', '#1c0c32', '#1e0d34',
      '#200e36', '#220f38', '#24103a', '#26113c',
      '#28123e', '#2a1040', '#2b1142', '#2c1244',
      '#2d1346', '#2e1448', '#2e154a', '#2f164c',
      '#30174e', '#2e1650', '#2c1550', '#2a1450'
    ];
    var passoGradiente = altCeu / coresCeu.length;
    for (var i = 0; i < coresCeu.length; i++) {
      ctx.fillStyle = coresCeu[i];
      ctx.fillRect(0, Math.floor(i * passoGradiente), w, Math.ceil(passoGradiente) + 1);
    }

    // ─── 2. ESTRELAS PIXELADAS ─────────────────────────────────────────────
    for (var s = 0; s < this._estrelas.length; s++) {
      var estrela = this._estrelas[s];
      var sx = Math.floor(estrela.rx * w);
      var sy = Math.floor(estrela.ry * h);
      var piscar = 0.7 + 0.3 * Math.sin((tick + estrela.fase) * 0.05);
      var alpha = (s % 4 === 0) ? piscar : (s % 3 === 0 ? 0.5 + 0.5 * piscar : 1.0);
      ctx.fillStyle = 'rgba(255,255,255,' + alpha.toFixed(2) + ')';
      ctx.fillRect(sx, sy, estrela.tamanho, estrela.tamanho);
    }

    // ─── 3. PRÉDIO DE FUNDO ───────────────────────────────────────────────
    var predioX = Math.floor(w * 0.12);
    var predioW = Math.floor(w * 0.55);
    var predioY = Math.floor(h * 0.18);
    var predioH = Math.floor(h * 0.40);

    // Corpo do prédio
    ctx.fillStyle = '#4a2020';
    ctx.fillRect(predioX, predioY, predioW, predioH);

    // Highlight lateral esquerdo
    ctx.fillStyle = '#5a2828';
    ctx.fillRect(predioX, predioY, 2, predioH);

    // Topo do prédio — cornija
    ctx.fillStyle = '#6a3030';
    ctx.fillRect(predioX - 4, predioY - 4, predioW + 8, 6);
    ctx.fillStyle = '#7a3838';
    ctx.fillRect(predioX - 6, predioY - 8, predioW + 12, 5);

    // Janelas do prédio: grade 5 colunas × 4 linhas
    var janelaW = Math.floor(predioW / 8);
    var janelaH = Math.floor(predioH / 7);
    var janelaMargemX = Math.floor(janelaW * 0.6);
    var janelaMargemY = Math.floor(janelaH * 0.8);
    var numCols = 5;
    var numRows = 4;
    var janelaIluminadas = [0, 2, 5, 7, 9, 11, 13]; // índices de janelas sempre acesas

    var totalEspacoX = predioW - janelaMargemX * 2;
    var totalEspacoY = predioH - janelaMargemY * 2;
    var espacoEntreX = totalEspacoX / numCols;
    var espacoEntreY = totalEspacoY / numRows;

    for (var row = 0; row < numRows; row++) {
      for (var col = 0; col < numCols; col++) {
        var ji = row * numCols + col;
        var jx = predioX + janelaMargemX + col * espacoEntreX;
        var jy = predioY + janelaMargemY + row * espacoEntreY;
        var jw = Math.floor(janelaW * 0.9);
        var jh = Math.floor(janelaH * 0.75);

        var iluminada = false;
        for (var k = 0; k < janelaIluminadas.length; k++) {
          if (janelaIluminadas[k] === ji) { iluminada = true; break; }
        }

        // Piscar individual por janela (frequência diferente por índice)
        var fasePiscar = tick * 0.03 + ji * 0.7;
        var acesa = iluminada && (Math.sin(fasePiscar) > -0.3);

        if (acesa) {
          // Janela acesa: amarelo quente com brilho
          ctx.fillStyle = '#ffdd88';
          ctx.fillRect(Math.floor(jx), Math.floor(jy), jw, jh);
          // Brilho ao redor
          ctx.fillStyle = 'rgba(255,220,100,0.15)';
          ctx.fillRect(Math.floor(jx) - 2, Math.floor(jy) - 2, jw + 4, jh + 4);
          // Grade interna da janela
          ctx.fillStyle = 'rgba(180,140,50,0.4)';
          ctx.fillRect(Math.floor(jx) + Math.floor(jw/2), Math.floor(jy), 1, jh);
          ctx.fillRect(Math.floor(jx), Math.floor(jy) + Math.floor(jh/2), jw, 1);
        } else {
          // Janela escura
          ctx.fillStyle = '#0a1a3a';
          ctx.fillRect(Math.floor(jx), Math.floor(jy), jw, jh);
          // Reflexo sutil
          ctx.fillStyle = 'rgba(50,80,120,0.3)';
          ctx.fillRect(Math.floor(jx), Math.floor(jy), Math.floor(jw * 0.4), Math.floor(jh * 0.4));
          // Grade interna
          ctx.fillStyle = 'rgba(5,15,30,0.6)';
          ctx.fillRect(Math.floor(jx) + Math.floor(jw/2), Math.floor(jy), 1, jh);
          ctx.fillRect(Math.floor(jx), Math.floor(jy) + Math.floor(jh/2), jw, 1);
        }

        // Moldura da janela
        ctx.fillStyle = '#3a1818';
        ctx.fillRect(Math.floor(jx) - 1, Math.floor(jy) - 1, 1, jh + 2);
        ctx.fillRect(Math.floor(jx) + jw, Math.floor(jy) - 1, 1, jh + 2);
        ctx.fillRect(Math.floor(jx) - 1, Math.floor(jy) - 1, jw + 2, 1);
        ctx.fillRect(Math.floor(jx) - 1, Math.floor(jy) + jh, jw + 2, 1);
      }
    }

    // ─── 4. PAREDE DE TIJOLOS ─────────────────────────────────────────────
    var paredeY = Math.floor(h * 0.38);
    var paredeH = Math.floor(h * 0.44);
    var chaoY = Math.floor(h * 0.80);

    // Base da parede
    ctx.fillStyle = '#5a2020';
    ctx.fillRect(0, paredeY, w, paredeH);

    // Tijolos: 16px × 8px em unidades de pixel lógico
    // Ajustamos pela escala do canvas
    var tjW = Math.max(14, Math.floor(w / 30));   // largura de tijolo (aprox 30 tijolos por linha)
    var tjH = Math.max(7, Math.floor(tjW / 2));   // altura = metade da largura
    var numLinhas = Math.ceil(paredeH / tjH) + 1;
    var numColunas = Math.ceil(w / tjW) + 1;

    for (var linha = 0; linha < numLinhas; linha++) {
      var offsetX = (linha % 2 === 0) ? 0 : Math.floor(tjW / 2);
      var ty = paredeY + linha * tjH;

      if (ty > chaoY) break;

      for (var col2 = -1; col2 < numColunas; col2++) {
        var tx = col2 * tjW + offsetX - tjW;

        // Cor base do tijolo (alternada)
        var corTijolo = ((linha + col2) % 2 === 0) ? '#8b3a3a' : '#6b2d2d';

        // Tijolo ocasionalmente mais escuro (variação)
        if ((linha * 7 + col2 * 3) % 11 === 0) {
          corTijolo = '#5a2525';
        }

        // Corpo do tijolo
        ctx.fillStyle = corTijolo;
        ctx.fillRect(tx + 1, ty + 1, tjW - 2, tjH - 2);

        // Highlight no topo
        ctx.fillStyle = '#c45050';
        ctx.fillRect(tx + 1, ty + 1, tjW - 2, 1);

        // Highlight lateral esquerdo (mais sutil)
        ctx.fillStyle = 'rgba(196,80,80,0.4)';
        ctx.fillRect(tx + 1, ty + 1, 1, tjH - 2);

        // Sombra na base
        ctx.fillStyle = '#3a1515';
        ctx.fillRect(tx + 1, ty + tjH - 2, tjW - 2, 1);

        // Junta de argamassa (espaço entre tijolos)
        ctx.fillStyle = '#2a1010';
        ctx.fillRect(tx, ty, 1, tjH);         // junta vertical
        ctx.fillRect(tx, ty, tjW, 1);          // junta horizontal
      }
    }

    // Rachaduras na parede (linhas diagonais em posições fixas)
    var rachaduras = [
      { x: 0.15, y: 0.50, dx: 3, dy: 8, tamanho: 5 },
      { x: 0.42, y: 0.44, dx: -2, dy: 6, tamanho: 4 },
      { x: 0.68, y: 0.55, dx: 4, dy: 10, tamanho: 6 },
      { x: 0.28, y: 0.62, dx: -3, dy: 7, tamanho: 4 },
      { x: 0.82, y: 0.48, dx: 2, dy: 9, tamanho: 5 }
    ];
    ctx.fillStyle = '#2a0a0a';
    for (var r = 0; r < rachaduras.length; r++) {
      var ra = rachaduras[r];
      var rx = Math.floor(ra.x * w);
      var ry = Math.floor(ra.y * h);
      for (var seg = 0; seg < ra.tamanho; seg++) {
        ctx.fillRect(rx + seg * ra.dx, ry + seg * ra.dy, 1, 2);
        ctx.fillRect(rx + seg * ra.dx + 1, ry + seg * ra.dy + 3, 1, 2);
      }
    }

    // ─── 5. CHÃO DE PARALELEPÍPEDO ────────────────────────────────────────
    var chaoH = h - chaoY;

    // Base do chão
    ctx.fillStyle = '#2a1a0a';
    ctx.fillRect(0, chaoY, w, chaoH);

    // Pedras: 24×12 pixels lógicos
    var pedW = Math.max(18, Math.floor(w / 18));
    var pedH = Math.max(9, Math.floor(pedW / 2));
    var numLinhasChao = Math.ceil(chaoH / pedH) + 1;
    var numColsChao = Math.ceil(w / pedW) + 2;

    for (var lc = 0; lc < numLinhasChao; lc++) {
      var offsetChao = (lc % 2 === 0) ? 0 : Math.floor(pedW / 2);
      var pcy = chaoY + lc * pedH;

      for (var cc = -1; cc < numColsChao; cc++) {
        var pcx = cc * pedW + offsetChao - pedW;

        // Perspectiva: pedras no fundo são mais escuras
        var fatorProx = lc / numLinhasChao;
        var corPedra = ((lc + cc) % 2 === 0) ? '#3d2d1d' : '#5a4030';

        // Corpo da pedra
        ctx.fillStyle = corPedra;
        ctx.fillRect(pcx + 1, pcy + 1, pedW - 2, pedH - 2);

        // Highlight no topo
        ctx.fillStyle = '#7a5a40';
        ctx.fillRect(pcx + 1, pcy + 1, pedW - 2, 1);

        // Sombra na base
        ctx.fillStyle = '#1a0a00';
        ctx.fillRect(pcx + 1, pcy + pedH - 2, pedW - 2, 1);

        // Junta entre pedras
        ctx.fillStyle = '#1a0a00';
        ctx.fillRect(pcx, pcy, 1, pedH);
        ctx.fillRect(pcx, pcy, pedW, 1);
      }
    }

    // Linha de separação chão/parede
    ctx.fillStyle = '#1a0800';
    ctx.fillRect(0, chaoY, w, 2);
    ctx.fillStyle = '#4a2a10';
    ctx.fillRect(0, chaoY + 2, w, 1);

    // ─── 6. BARRIS ────────────────────────────────────────────────────────
    var barrX = Math.floor(w * 0.82);
    var barrChao = chaoY - 2;

    // Função para desenhar um barril
    var desenharBarril = function(cx, baseY, escala) {
      escala = escala || 1;
      var bw = Math.floor(22 * escala);   // largura
      var bh = Math.floor(32 * escala);   // altura
      var bx = cx - Math.floor(bw / 2);
      var by = baseY - bh;

      // Sombra
      ctx.fillStyle = 'rgba(0,0,0,0.4)';
      ctx.fillRect(bx + 2, by + bh - 2, bw + 2, 4);

      // Corpo principal do barril
      ctx.fillStyle = '#5a3a10';
      ctx.fillRect(bx + 2, by + 3, bw - 4, bh - 6);

      // Abaulamento lateral (barril é mais largo no meio)
      ctx.fillStyle = '#5a3a10';
      ctx.fillRect(bx + 1, by + Math.floor(bh * 0.25), bw - 2, Math.floor(bh * 0.5));
      ctx.fillRect(bx, by + Math.floor(bh * 0.35), bw, Math.floor(bh * 0.3));

      // Topo (elipse achatada)
      ctx.fillStyle = '#7a5020';
      ctx.fillRect(bx + 2, by, bw - 4, 4);
      ctx.fillRect(bx + 1, by + 1, bw - 2, 2);

      // Base
      ctx.fillStyle = '#4a3010';
      ctx.fillRect(bx + 2, by + bh - 4, bw - 4, 4);
      ctx.fillRect(bx + 1, by + bh - 3, bw - 2, 2);

      // Aros metálicos
      var posAros = [0.2, 0.5, 0.8];
      for (var a = 0; a < posAros.length; a++) {
        var ay = by + Math.floor(bh * posAros[a]);
        ctx.fillStyle = '#8b6020';
        ctx.fillRect(bx, ay, bw, 2);
        // Highlight do aro
        ctx.fillStyle = '#c08030';
        ctx.fillRect(bx + 1, ay, bw - 2, 1);
      }

      // Highlight lateral esquerdo
      ctx.fillStyle = 'rgba(200,140,60,0.25)';
      ctx.fillRect(bx + 2, by + 4, 2, bh - 8);

      // Sombra lateral direita
      ctx.fillStyle = 'rgba(0,0,0,0.3)';
      ctx.fillRect(bx + bw - 4, by + 4, 2, bh - 8);
    };

    // Barril de baixo (maior)
    desenharBarril(barrX, barrChao, 1.0);

    // Barril de cima (um pouco menor, empilhado)
    var barrilH = Math.floor(32 * 1.0);
    desenharBarril(barrX - 2, barrChao - barrilH + 3, 0.88);

    // Barril avulso no canto esquerdo
    desenharBarril(Math.floor(w * 0.07), barrChao, 0.75);

    // ─── 7. LETREIRO "COMBAT ZONE" (NEON PISCANDO) ────────────────────────
    var neonAlpha = 0.7 + 0.3 * Math.sin(tick * 0.08);
    var neonAlpha2 = 0.5 + 0.5 * Math.sin(tick * 0.08 + Math.PI);
    var corNeon = (Math.floor(tick / 20) % 2 === 0) ? '#ff2244' : '#ff4466';
    var neonY = Math.floor(h * 0.04);
    var neonX = Math.floor(w * 0.25);

    // Brilho de fundo do letreiro
    ctx.fillStyle = 'rgba(255,20,50,' + (neonAlpha2 * 0.15).toFixed(2) + ')';
    ctx.fillRect(neonX - 10, neonY - 4, Math.floor(w * 0.50) + 20, 22);

    // Fundo escuro do letreiro
    ctx.fillStyle = 'rgba(10,0,5,0.7)';
    ctx.fillRect(neonX - 6, neonY - 2, Math.floor(w * 0.50) + 12, 18);

    // Borda do letreiro
    ctx.fillStyle = 'rgba(255,30,60,' + neonAlpha.toFixed(2) + ')';
    ctx.fillRect(neonX - 7, neonY - 3, Math.floor(w * 0.50) + 14, 1);
    ctx.fillRect(neonX - 7, neonY + 16, Math.floor(w * 0.50) + 14, 1);
    ctx.fillRect(neonX - 7, neonY - 3, 1, 20);
    ctx.fillRect(neonX + Math.floor(w * 0.50) + 6, neonY - 3, 1, 20);

    // Letras "COMBAT ZONE" em pixel font simulada (blocos 4×6)
    ctx.fillStyle = 'rgba(' + (corNeon === '#ff2244' ? '255,34,68' : '255,68,102') + ',' + neonAlpha.toFixed(2) + ')';
    this._desenharTextoPixel(ctx, 'COMBAT ZONE', neonX + 4, neonY + 4, 4, 6, corNeon, neonAlpha);

    // ─── 8. SCANLINES (efeito CRT) ────────────────────────────────────────
    ctx.fillStyle = 'rgba(0,0,0,0.12)';
    for (var sl = 0; sl < h; sl += 2) {
      ctx.fillRect(0, sl, w, 1);
    }

    // Vinheta nas bordas (escurecimento lateral)
    var margemVinheta = Math.floor(w * 0.08);
    for (var v = 0; v < margemVinheta; v++) {
      var alphaV = (1 - v / margemVinheta) * 0.35;
      ctx.fillStyle = 'rgba(0,0,0,' + alphaV.toFixed(2) + ')';
      ctx.fillRect(v, 0, 1, h);
      ctx.fillRect(w - 1 - v, 0, 1, h);
    }
  },

  // ─── PIXEL FONT MANUAL ──────────────────────────────────────────────────
  // Desenha texto usando mini-bitmap de blocos (4×6 pixels por letra)
  _desenharTextoPixel: function(ctx, texto, x, y, pw, ph, cor, alpha) {
    // Mapa de bits para cada caractere (5 colunas × 7 linhas → 0=vazio, 1=pixel)
    var glyphs = {
      'A': [
        [0,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,1,1,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [0,0,0,0,0]
      ],
      'B': [
        [1,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,1,1,0,0],
        [1,0,0,1,0],
        [1,1,1,0,0],
        [0,0,0,0,0]
      ],
      'C': [
        [0,1,1,1,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [0,1,1,1,0],
        [0,0,0,0,0]
      ],
      'D': [
        [1,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,1,1,0,0],
        [0,0,0,0,0]
      ],
      'E': [
        [1,1,1,1,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,1,1,0,0],
        [1,0,0,0,0],
        [1,1,1,1,0],
        [0,0,0,0,0]
      ],
      'F': [
        [1,1,1,1,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,1,1,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [0,0,0,0,0]
      ],
      'G': [
        [0,1,1,1,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,1,1,0],
        [1,0,0,1,0],
        [0,1,1,1,0],
        [0,0,0,0,0]
      ],
      'H': [
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,1,1,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [0,0,0,0,0]
      ],
      'I': [
        [1,1,1,0,0],
        [0,1,0,0,0],
        [0,1,0,0,0],
        [0,1,0,0,0],
        [0,1,0,0,0],
        [1,1,1,0,0],
        [0,0,0,0,0]
      ],
      'J': [
        [0,1,1,1,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [1,0,1,0,0],
        [0,1,1,0,0],
        [0,0,0,0,0]
      ],
      'K': [
        [1,0,0,1,0],
        [1,0,1,0,0],
        [1,1,0,0,0],
        [1,1,0,0,0],
        [1,0,1,0,0],
        [1,0,0,1,0],
        [0,0,0,0,0]
      ],
      'L': [
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,1,1,1,0],
        [0,0,0,0,0]
      ],
      'M': [
        [1,0,0,0,1],
        [1,1,0,1,1],
        [1,0,1,0,1],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,0,0,0,0]
      ],
      'N': [
        [1,0,0,0,1],
        [1,1,0,0,1],
        [1,0,1,0,1],
        [1,0,0,1,1],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,0,0,0,0]
      ],
      'O': [
        [0,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [0,1,1,0,0],
        [0,0,0,0,0]
      ],
      'P': [
        [1,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,1,1,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [0,0,0,0,0]
      ],
      'Q': [
        [0,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,1,1,0],
        [1,0,0,1,0],
        [0,1,1,1,0],
        [0,0,0,0,0]
      ],
      'R': [
        [1,1,1,0,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,1,1,0,0],
        [1,0,1,0,0],
        [1,0,0,1,0],
        [0,0,0,0,0]
      ],
      'S': [
        [0,1,1,1,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [0,1,1,0,0],
        [0,0,0,1,0],
        [1,1,1,0,0],
        [0,0,0,0,0]
      ],
      'T': [
        [1,1,1,1,1],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,0,0,0]
      ],
      'U': [
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [1,0,0,1,0],
        [0,1,1,0,0],
        [0,0,0,0,0]
      ],
      'V': [
        [1,0,0,0,1],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,1,0,1,0],
        [0,1,0,1,0],
        [0,0,1,0,0],
        [0,0,0,0,0]
      ],
      'W': [
        [1,0,0,0,1],
        [1,0,0,0,1],
        [1,0,1,0,1],
        [1,0,1,0,1],
        [1,1,0,1,1],
        [1,0,0,0,1],
        [0,0,0,0,0]
      ],
      'X': [
        [1,0,0,0,1],
        [0,1,0,1,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,1,0,1,0],
        [1,0,0,0,1],
        [0,0,0,0,0]
      ],
      'Y': [
        [1,0,0,0,1],
        [0,1,0,1,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,0,0,0]
      ],
      'Z': [
        [1,1,1,1,0],
        [0,0,0,1,0],
        [0,0,1,0,0],
        [0,1,0,0,0],
        [1,0,0,0,0],
        [1,1,1,1,0],
        [0,0,0,0,0]
      ],
      ' ': [
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0]
      ]
    };

    var cursorX = x;
    var gapLetras = 1; // espaço entre letras

    for (var ci = 0; ci < texto.length; ci++) {
      var char = texto[ci].toUpperCase();
      var glyph = glyphs[char] || glyphs[' '];
      var larguraGlyph = glyph[0].length;

      for (var gl = 0; gl < glyph.length; gl++) {
        for (var gc = 0; gc < larguraGlyph; gc++) {
          if (glyph[gl][gc]) {
            // Brilho/halo ao redor do pixel
            ctx.fillStyle = 'rgba(255,50,80,' + (alpha * 0.3).toFixed(2) + ')';
            ctx.fillRect(cursorX + gc * pw - 1, y + gl * ph - 1, pw + 2, ph + 2);

            // Pixel principal
            ctx.fillStyle = cor;
            ctx.fillRect(cursorX + gc * pw, y + gl * ph, pw, ph);

            // Highlight interno (canto superior esquerdo)
            ctx.fillStyle = 'rgba(255,180,180,0.5)';
            ctx.fillRect(cursorX + gc * pw, y + gl * ph, Math.max(1, Math.floor(pw/2)), 1);
          }
        }
      }

      cursorX += (larguraGlyph + gapLetras) * pw;
    }
  }

};
