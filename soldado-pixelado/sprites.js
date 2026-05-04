window.SOLDADO_SPRITES = {
  scale: 4,
  cols: 16,
  rows: 24,
  palette: {
    '.': null,
    'K': '#1a1a1a',
    'V': '#4a6741',
    'v': '#6b8f60',
    'S': '#c8956b',
    's': '#e8b48a',
    'B': '#3d2b1f',
    'b': '#5c3d2e',
    'G': '#7a7a7a',
    'g': '#b0b0b0',
    'H': '#4a3728',
    'h': '#6b5040',
    'R': '#ff4400',
    'Y': '#ffdd00',
    'W': '#ffffff',
    'E': '#8b6914',
  },
  frames: [
    // ------------------------------------------------------------------
    // frame 0: idle — em pé, posição de repouso (segurando arma abaixada)
    // Cada string tem exatamente 16 caracteres.
    // ------------------------------------------------------------------
    [
      '.....HHHHH......',  //  0: . . . . . H H H H H . . . . . .
      '....HHHHHHH.....',  //  1: . . . . H H H H H H H . . . . .
      '....HhHHhHH.....',  //  2: . . . . H h H H h H H . . . . .
      '....HHHHHHH.....',  //  3: . . . . H H H H H H H . . . . .
      '.....SSSSS......',  //  4: . . . . . S S S S S . . . . . .
      '....SSSsSSS.....',  //  5: . . . . S S S s S S S . . . . .
      '....SSSKSSS.....',  //  6: . . . . S S S K S S S . . . . .
      '.....SSSSS......',  //  7: . . . . . S S S S S . . . . . .
      '...VVVVVVVVV....',  //  8: . . . V V V V V V V V V . . . .
      '..VVvVVVVvVVV...',  //  9: . . V V v V V V V v V V V . . .
      '..VVVVVVVVVVV...',  // 10: . . V V V V V V V V V V V . . .
      '..VVVVVVVVVVV...',  // 11: . . V V V V V V V V V V V . . .
      '...VVBBVVVVVv...',  // 12: . . . V V B B V V V V V . . . .  (12 chars de conteúdo entre os pontos)
      '....VVVVVVV.....',  // 13: . . . . V V V V V V V . . . . .
      '...VVV..VVVV....',  // 14: . . . V V V . . V V V V . . . .
      '...VVV..VVVV....',  // 15
      '...VVV..VVVV....',  // 16
      '...VVV..VVVV....',  // 17
      '...BBB..BBBB....',  // 18: . . . B B B . . B B B B . . . .
      '...BBb..BBbB....',  // 19
      '...BBB..BBBB....',  // 20
      '...bBB..BbBB....',  // 21
      '...KKK..KKKK....',  // 22: . . . K K K . . K K K K . . . .
      '................',  // 23
    ],
    // ------------------------------------------------------------------
    // frame 1: levantando arma
    // ------------------------------------------------------------------
    [
      '.....HHHHH......',  //  0
      '....HHHHHHH.....',  //  1
      '....HhHHhHH.....',  //  2
      '....HHHHHHH.....',  //  3
      '.....SSSSS......',  //  4
      '....SSSsSSS.....',  //  5
      '....SSSKSSS.....',  //  6: . . . . S S S K S S S . . . . .
      '.....SSSSS......',  //  7
      '...VVVVVVVVV....',  //  8
      '..VVvVVVVvVVV...',  //  9
      '..VVVVVVVVVVV...',  // 10
      '.VVVVVVVVVVVV...',  // 11: . V V V V V V V V V V V V . . .
      'VSSVBBVVVVVVV...',  // 12: V S S V B B V V V V V V V . . .
      '.SSVGGGGGGgG....',  // 13: . S S V G G G G G G g G . . . .
      '...VVV..VVVV....',  // 14
      '...VVV..VVVV....',  // 15
      '...VVV..VVVV....',  // 16
      '...VVV..VVVV....',  // 17
      '...BBB..BBBB....',  // 18
      '...BBb..BBbB....',  // 19
      '...BBB..BBBB....',  // 20
      '...bBB..BbBB....',  // 21
      '...KKK..KKKK....',  // 22
      '................',  // 23
    ],
    // ------------------------------------------------------------------
    // frame 2: atirando — arma estendida, flash de fogo
    // ------------------------------------------------------------------
    [
      '.....HHHHH......',  //  0
      '....HHHHHHH.....',  //  1
      '....HhHHhHH.....',  //  2
      '....HHHHHHH.....',  //  3
      '.....SSSSS......',  //  4
      '....SSSsSSS.....',  //  5
      '....SSSKSSS.....',  //  6: . . . . S S S K S S S . . . . .
      '.....SSSSS......',  //  7
      '...VVVVVVVVV....',  //  8
      '..VVvVVVVvVVV...',  //  9
      '.VVVVVVVVVVVV...',  // 10: . V V V V V V V V V V V V . . .
      'VSSVVVVVVVVVV...',  // 11: V S S V V V V V V V V V V . . .
      'SSSGGGGGGGggYR..',  // 12: S S S G G G G G G G g g Y R . .
      '.SSVGGGGGGgGYRR.',  // 13: . S S V G G G G G G g G Y R R .
      '...VVV..VVVV....',  // 14
      '...VVV..VVVV....',  // 15
      '...VVV..VVVV....',  // 16
      '...VVV..VVVV....',  // 17
      '...BBB..BBBB....',  // 18
      '...BBb..BBbB....',  // 19
      '...BBB..BBBB....',  // 20
      '...bBB..BbBB....',  // 21
      '...KKK..KKKK....',  // 22
      '................',  // 23
    ],
    // ------------------------------------------------------------------
    // frame 3: recuo — arma levemente para cima/trás após o tiro
    // ------------------------------------------------------------------
    [
      '.....HHHHH......',  //  0
      '....HHHHHHH.....',  //  1
      '....HhHHhHH.....',  //  2
      '....HHHHHHH.....',  //  3
      '.....SSSSS......',  //  4
      '....SSSsSSS.....',  //  5
      '....SSSKSSS.....',  //  6: . . . . S S S K S S S . . . . .
      '.....SSSSS......',  //  7
      '...VVVVVVVVV....',  //  8
      '..VVvVVVVvVVV...',  //  9
      'VVVVVVVVVVVVV...',  // 10: V V V V V V V V V V V V V . . .
      'SSSVVVVVVVVVV...',  // 11: S S S V V V V V V V V V V . . .
      '.SSVBBv.gGGG....',  // 12: . S S V B B v . g G G G . . . .
      '...VGGGGGGgG....',  // 13: . . . V G G G G G G g G . . . .
      '...VVV..VVVV....',  // 14
      '...VVV..VVVV....',  // 15
      '...VVV..VVVV....',  // 16
      '...VVV..VVVV....',  // 17
      '...BBB..BBBB....',  // 18
      '...BBb..BBbB....',  // 19
      '...BBB..BBBB....',  // 20
      '...bBB..BbBB....',  // 21
      '...KKK..KKKK....',  // 22
      '................',  // 23
    ],
  ],
  animation: [
    { frame: 0, duration: 30 },
    { frame: 0, duration: 30 },
    { frame: 0, duration: 30 },
    { frame: 1, duration: 8  },
    { frame: 2, duration: 6  },
    { frame: 3, duration: 8  },
    { frame: 1, duration: 6  },
    { frame: 0, duration: 20 },
  ],
  draw: function(ctx, frameIndex, x, y) {
    const f = this.frames[frameIndex];
    const sc = this.scale;
    for (let row = 0; row < this.rows; row++) {
      for (let col = 0; col < this.cols; col++) {
        const char = f[row][col];
        const color = this.palette[char];
        if (color) {
          ctx.fillStyle = color;
          ctx.fillRect(x + col * sc, y + row * sc, sc, sc);
        }
      }
    }
  }
};
