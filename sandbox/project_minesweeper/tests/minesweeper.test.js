const test = require('node:test');
const assert = require('node:assert/strict');
const { MinesweeperGame } = require('../src/minesweeper-core.js');

test('扫雷核心测试套件', async (t) => {
  await t.test('1. 初始化状态正确', () => {
    const game = new MinesweeperGame(9, 9, 10);
    assert.equal(game.rows, 9);
    assert.equal(game.cols, 9);
    assert.equal(game.mineCount, 10);
    assert.equal(game.status, 'ready');
    assert.equal(game.flagsLeft, 10);

    // 检查初始所有格子未翻开
    for (let r = 0; r < 9; r++) {
      for (let c = 0; c < 9; c++) {
        const cell = game.getCell(r, c);
        assert.equal(cell.revealed, false);
        assert.equal(cell.flagged, false);
        assert.equal(cell.isMine, false); // 在首次点击前暂未布雷
      }
    }
  });

  await t.test('2. 首次点击绝对安全且雷数准确', () => {
    const game = new MinesweeperGame(9, 9, 10);
    game.reveal(4, 4);
    assert.equal(game.status, 'playing');

    // 首击格子绝不能是雷
    const firstCell = game.getCell(4, 4);
    assert.equal(firstCell.isMine, false);
    assert.equal(firstCell.revealed, true);

    // 统计总雷数
    let totalMines = 0;
    for (let r = 0; r < 9; r++) {
      for (let c = 0; c < 9; c++) {
        if (game.getCell(r, c).isMine) totalMines++;
      }
    }
    assert.equal(totalMines, 10);
  });

  await t.test('3. 空白连通域自动扩散展开 (Flood fill)', () => {
    const game = new MinesweeperGame(3, 3, 1);
    // 人工指定雷位置：(2, 2) 是雷
    game.setupCustomBoard(3, 3, [{ r: 2, c: 2 }]);

    // 点击 (0, 0)，周围无雷(值为0)，应级联展开到所有非雷格子
    game.reveal(0, 0);

    assert.equal(game.getCell(0, 0).revealed, true);
    assert.equal(game.getCell(0, 1).revealed, true);
    assert.equal(game.getCell(1, 0).revealed, true);
    assert.equal(game.getCell(1, 1).revealed, true);
    assert.equal(game.getCell(2, 2).revealed, false);
  });

  await t.test('4. 标记与取消标记 (Flagging)', () => {
    const game = new MinesweeperGame(9, 9, 10);
    game.reveal(0, 0);

    // 标记未揭开的远端格子
    const toggled = game.toggleFlag(8, 8);
    assert.equal(toggled, true);
    assert.equal(game.getCell(8, 8).flagged, true);
    assert.equal(game.flagsLeft, 9);

    // 已标记格子不能被点击揭开
    game.reveal(8, 8);
    assert.equal(game.getCell(8, 8).revealed, false);

    // 再次切换取消标记
    game.toggleFlag(8, 8);
    assert.equal(game.getCell(8, 8).flagged, false);
    assert.equal(game.flagsLeft, 10);
  });

  await t.test('5. 触雷失败判定与全部雷展示', () => {
    const game = new MinesweeperGame(3, 3, 1);
    game.setupCustomBoard(3, 3, [{ r: 1, c: 1 }]);

    game.reveal(1, 1);
    assert.equal(game.status, 'lost');
    // 失败后该地雷应标示为触发
    assert.equal(game.hitMine.row, 1);
    assert.equal(game.hitMine.col, 1);
  });

  await t.test('6. 扫清所有非雷格获胜判定', () => {
    const game = new MinesweeperGame(2, 2, 1);
    game.setupCustomBoard(2, 2, [{ r: 1, c: 1 }]);

    game.reveal(0, 0);
    game.reveal(0, 1);
    game.reveal(1, 0);

    assert.equal(game.status, 'won');
  });

  await t.test('7. 双击/连开辅助 (Chord)', () => {
    const game = new MinesweeperGame(3, 3, 1);
    // (0, 0) 为雷，(1, 1) 周围有1个雷
    game.setupCustomBoard(3, 3, [{ r: 0, c: 0 }]);

    // 揭开 (1, 1)，neighborMines 为 1
    game.reveal(1, 1);
    assert.equal(game.getCell(1, 1).neighborMines, 1);

    // 对 (0, 0) 插旗
    game.toggleFlag(0, 0);

    // 对 (1, 1) 触发 chord
    game.chord(1, 1);

    // 周围其余非雷格应全被揭开
    assert.equal(game.getCell(0, 1).revealed, true);
    assert.equal(game.getCell(1, 0).revealed, true);
    assert.equal(game.getCell(0, 0).revealed, false); // 旗帜保留
  });
});
