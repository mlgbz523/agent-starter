---
name: python-concurrency-debugging
description: Use when debugging Python concurrency issues including asyncio deadlocks, race conditions, event loop blocking, or thread safety bugs
---

# Python 并发与异步调试实战指南 (Python Concurrency Debugging)

**铁律**：并发问题严禁通过“随意盲加 sleep、加大超时时间”掩盖症状，必须以确定性的根因调查为前提。

---

## 触发场景 (When to Use)
- `asyncio` 程序无故挂起（Hang）、无报错但协程不再推进。
- 偶发的死锁（Deadlock）或活锁（Livelock）。
- 竞态条件（Race Condition）导致共享变量数据不一致。
- 事件循环被耗时同步操作阻塞（Event Loop Blocking），导致其他 Task 饥饿或超时。
- 出现 `Task was destroyed but it is pending!` 或未捕获的并发异常。

---

## 核心诊断排查四步法

### 第一步：排查事件循环阻塞与未等待 Task (Asyncio Diagnostics)

1. **开启 Asyncio 调试模式（零代码入侵）**：
   在终端运行 Python 脚本或测试时注入环境变量：
   ```bash
   PYTHONASYNCIODEBUG=1 python your_script.py
   # 或在 pytest 中启用：
   pytest -o asyncio_mode=auto -s
   ```
   *作用*：自动追踪执行超过 100ms 的慢回调，并输出阻塞堆栈；警告未被 `await` 的协程对象。

2. **代码级全局诊断探针**：
   在入口处开启调试开关并监控卡死协程：
   ```python
   import asyncio
   import logging

   logging.basicConfig(level=logging.DEBUG)
   loop = asyncio.get_event_loop()
   loop.set_debug(True)
   loop.slow_callback_duration = 0.05  # 超过 50ms 判定为慢调用
   ```

3. **捕获当前所有正在运行或挂起的 Tasks**：
   当程序无响应时，打印活跃协程堆栈：
   ```python
   for task in asyncio.all_tasks():
       if not task.done():
           print(f"Task: {task.get_name()}")
           task.print_stack()
   ```

---

### 第二步：多线程死锁与堆栈现场捕获 (Thread Deadlock Detection)

当多线程出现卡死或锁竞争时，使用 Python 原生内置的 `faulthandler` 在不中断进程的前提下 dump 所有线程堆栈：

1. **代码内注册信号监听 (Linux/macOS)**：
   ```python
   import faulthandler
   import signal
   faulthandler.register(signal.SIGUSR1)
   # 当程序卡死时，在另一个终端执行：kill -USR1 <PID>，将立刻打印所有线程的当前调用行号
   ```

2. **跨平台定时安全转储 (Windows/Linux/macOS 通用)**：
   若程序在特定时间后必卡死，配置定时 dump：
   ```python
   import faulthandler
   faulthandler.dump_traceback_later(timeout=10, exit=False)
   ```

---

### 第三步：竞态条件（Race Condition）排查与最小复现用例

1. **不可变 / 线程隔离检查清单**：
   - 检查是否有非线程安全的全局字典、列表在多个 Task 或 Thread 中被直接读写。
   - `asyncio` 中虽然是单线程协作式调度，但跨越 `await` 语句时，共享状态依然可能被其他协程并发修改！

2. **竞态漏洞典型范例**：
   ```python
   # ❌ 错误：跨 await 共享可变状态引起竞态
   async def transfer_money(account, amount):
       balance = await get_balance(account)
       await asyncio.sleep(0.01)  # 调度权被让出，其他协程可能已经扣款！
       await set_balance(account, balance - amount)

   # ✅ 修复：原子锁控制
   lock = asyncio.Lock()
   async def transfer_money(account, amount):
       async with lock:
           balance = await get_balance(account)
           await set_balance(account, balance - amount)
   ```

---

### 第四步：确定性验证与防复发门禁

1. **编写并发压力测试用例**：
   严禁使用单次调用验证并发 Bug，必须使用 `asyncio.gather` 模拟高并发冲突：
   ```python
   import pytest
   import asyncio

   @pytest.mark.asyncio
   async def test_concurrent_safety():
       # 并发启动 50 个操作争抢同一资源
       tasks = [transfer_money("acc_01", 10) for _ in range(50)]
       await asyncio.gather(*tasks)
       # 校验最终余额是否保持一致性
       assert await get_balance("acc_01") == 500
   ```

2. **CLI 自动化测试执行命令**：
   ```bash
   pytest tests/test_concurrency.py -v --durations=5
   ```

---

## 常见踩坑点与红线 (Common Mistakes & Red Flags)

| 典型错误现象 | 错误做法（掩盖症状） | 真正根因与正确修复 |
| :--- | :--- | :--- |
| 协程无故超时 | 盲目增大 `timeout=60` | 存在底层阻塞调用（如 `requests.get`、`time.sleep`），需替换为 `httpx.AsyncClient` 或通过 `asyncio.to_thread`包装。 |
| 多线程数据错乱 | 用 `time.sleep` 错开执行时间 | 存在读写竞态，必须使用 `threading.Lock` 或队列 `queue.Queue` 进行原子化隔离。 |
| Task 状态丢失 | 启动 Task 后不记录引用 | `asyncio.create_task` 创建的任务若未被变量引用，可能在执行完成前被垃圾回收器（GC）静默回收。需用集合保持引用。 |

---

## 权威溯源与官方技术标准 (Citations & Sources)

1. **Python 官方标准库文档 (Official Python Docs)**：
   - [Python 官方文档：asyncio 调试模式 (Debug Mode & Slow Callbacks)](https://docs.python.org/zh-cn/3/library/asyncio-dev.html#debug-mode) - 规范了 `PYTHONASYNCIODEBUG` 与慢回调阈值设置。
   - [Python 官方文档：faulthandler 堆栈转储 (Thread Dump & Deadlock)](https://docs.python.org/zh-cn/3/library/faulthandler.html) - 规范了多线程死锁信号与定时转储机制。
   - [Python 官方文档：Coroutines and Tasks (GC Task Collection Warning)](https://docs.python.org/zh-cn/3/library/asyncio-task.html#asyncio.create_task) - 明确指出未保存引用的 Task 会被 GC 静默回收的官方告警。
2. **开源工程排错规范 (Open-Source Standards)**：
   - [Superpowers: Systematic Debugging](file:///C:/Users/15770/.gemini/skills_library/systematic-debugging/SKILL.md) - 系统化根因排错准则（`NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`）。
   - [Agentic Awesome Skills (AAS): Smart Debugging Toolkit](https://github.com/sickn33/agentic-awesome-skills/tree/main/skills/debugging-toolkit-smart-debug) - 社区开源智能体可观测性与排错工具包规范。
