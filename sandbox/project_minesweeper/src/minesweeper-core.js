class MinesweeperGame {
  constructor(rows = 9, cols = 9, mineCount = 10) {
    this.rows = rows;
    this.cols = cols;
    this.mineCount = Math.min(mineCount, rows * cols - 1);
    this.reset();
  }

  reset() {
    this.status = 'ready'; // 'ready' | 'playing' | 'won' | 'lost'
    this.flagsLeft = this.mineCount;
    this.revealedCount = 0;
    this.hitMine = null;
    this.customBoard = false;
    this.board = [];

    for (let r = 0; r < this.rows; r++) {
      const row = [];
      for (let c = 0; c < this.cols; c++) {
        row.push({
          row: r,
          col: c,
          isMine: false,
          revealed: false,
          flagged: false,
          neighborMines: 0
        });
      }
      this.board.push(row);
    }
  }

  getCell(r, c) {
    if (r < 0 || r >= this.rows || c < 0 || c >= this.cols) {
      return null;
    }
    return this.board[r][c];
  }

  getNeighbors(r, c) {
    const neighbors = [];
    for (let dr = -1; dr <= 1; dr++) {
      for (let dc = -1; dc <= 1; dc++) {
        if (dr === 0 && dc === 0) continue;
        const cell = this.getCell(r + dr, c + dc);
        if (cell) neighbors.push(cell);
      }
    }
    return neighbors;
  }

  setupCustomBoard(rows, cols, mineCoords) {
    this.rows = rows;
    this.cols = cols;
    this.mineCount = mineCoords.length;
    this.reset();
    this.customBoard = true;
    for (const { r, c } of mineCoords) {
      const cell = this.getCell(r, c);
      if (cell) cell.isMine = true;
    }
    this._calculateNeighborMines();
  }

  placeMines(safeR, safeC) {
    // 候选安全区：若网格容量充足，让首击 3x3 区域无雷；否则至少自身无雷
    const totalCells = this.rows * this.cols;
    const canIsolate3x3 = (totalCells - 9) >= this.mineCount;

    const forbidden = new Set();
    if (canIsolate3x3) {
      for (let dr = -1; dr <= 1; dr++) {
        for (let dc = -1; dc <= 1; dc++) {
          const nr = safeR + dr;
          const nc = safeC + dc;
          if (nr >= 0 && nr < this.rows && nc >= 0 && nc < this.cols) {
            forbidden.add(`${nr},${nc}`);
          }
        }
      }
    } else {
      forbidden.add(`${safeR},${safeC}`);
    }

    const available = [];
    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols; c++) {
        if (!forbidden.has(`${r},${c}`)) {
          available.push({ r, c });
        }
      }
    }

    // 随机抽取 mineCount 个位置
    for (let i = available.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [available[i], available[j]] = [available[j], available[i]];
    }

    for (let i = 0; i < this.mineCount && i < available.length; i++) {
      const { r, c } = available[i];
      this.board[r][c].isMine = true;
    }

    this._calculateNeighborMines();
  }

  _calculateNeighborMines() {
    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols; c++) {
        const cell = this.board[r][c];
        if (cell.isMine) {
          cell.neighborMines = 0;
          continue;
        }
        const neighbors = this.getNeighbors(r, c);
        cell.neighborMines = neighbors.filter(n => n.isMine).length;
      }
    }
  }

  reveal(r, c) {
    if (this.status !== 'ready' && this.status !== 'playing') {
      return;
    }

    const cell = this.getCell(r, c);
    if (!cell || cell.revealed || cell.flagged) {
      return;
    }

    if (this.status === 'ready') {
      if (!this.customBoard) {
        this.placeMines(r, c);
      }
      this.status = 'playing';
    }

    if (cell.isMine) {
      cell.revealed = true;
      this.status = 'lost';
      this.hitMine = { row: r, col: c };
      this._revealAllMines();
      return;
    }

    this._floodFill(cell);
    this._checkWinCondition();
  }

  _floodFill(startCell) {
    const queue = [startCell];
    startCell.revealed = true;
    this.revealedCount++;

    while (queue.length > 0) {
      const current = queue.shift();
      if (current.neighborMines === 0) {
        const neighbors = this.getNeighbors(current.row, current.col);
        for (const neighbor of neighbors) {
          if (!neighbor.revealed && !neighbor.flagged && !neighbor.isMine) {
            neighbor.revealed = true;
            this.revealedCount++;
            if (neighbor.neighborMines === 0) {
              queue.push(neighbor);
            }
          }
        }
      }
    }
  }

  _revealAllMines() {
    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols; c++) {
        const cell = this.board[r][c];
        if (cell.isMine) {
          cell.revealed = true;
        }
      }
    }
  }

  toggleFlag(r, c) {
    if (this.status !== 'ready' && this.status !== 'playing') {
      return false;
    }

    const cell = this.getCell(r, c);
    if (!cell || cell.revealed) {
      return false;
    }

    cell.flagged = !cell.flagged;
    this.flagsLeft += cell.flagged ? -1 : 1;
    return true;
  }

  chord(r, c) {
    if (this.status !== 'playing') return;

    const cell = this.getCell(r, c);
    if (!cell || !cell.revealed || cell.neighborMines <= 0) return;

    const neighbors = this.getNeighbors(r, c);
    const flagCount = neighbors.filter(n => n.flagged).length;

    if (flagCount === cell.neighborMines) {
      for (const neighbor of neighbors) {
        if (!neighbor.revealed && !neighbor.flagged) {
          this.reveal(neighbor.row, neighbor.col);
        }
      }
    }
  }

  _checkWinCondition() {
    const nonMineCells = this.rows * this.cols - this.mineCount;
    if (this.revealedCount >= nonMineCells) {
      this.status = 'won';
      // 获胜时自动将所有未标记地雷插旗
      for (let r = 0; r < this.rows; r++) {
        for (let c = 0; c < this.cols; c++) {
          const cell = this.board[r][c];
          if (cell.isMine && !cell.flagged) {
            cell.flagged = true;
          }
        }
      }
      this.flagsLeft = 0;
    }
  }
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { MinesweeperGame };
}
if (typeof window !== 'undefined') {
  window.MinesweeperGame = MinesweeperGame;
}
