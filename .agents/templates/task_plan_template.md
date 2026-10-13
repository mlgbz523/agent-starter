# 任务实施与执行追踪方案：[任务名称]

> **状态回显锁**：`[STATE: PLAN]`（规划中） | `[STATE: EXECUTE]`（已获批执行中） | `[STATE: VERIFY]`（核验中）
> **DoR 准入检查**：在向 PM 发起执行审批前，必须逐项核对并勾选第一节的【方案就绪检查 (DoR)】。

---

## 〇、 方案就绪检查 (Definition of Ready - DoR)
- [ ] **目标与边界明确**：业务目标一句话描述清晰，且已列出明确的【非目标清单 (Non-Goals)】。
- [ ] **防御性条例就绪**：已推演至少 3~5 项核心异常边界（超时/网络/空数据/脏数据/并发冲突）。
- [ ] **契约与模型锁定**：入参、出参、核心数据结构及接口签名全部显式锁定（无 TBD 或未定义字段）。
- [ ] **依赖与环境审计**：若有新依赖已执行探针验证并通过；所需环境变量已声明于 `.env.example`。
- [ ] **去伪存真验收命令**：每个任务均具备真实终端可执行的 CLI 测试命令与预期退出码（退出码为 0）。
- [ ] **安全撤销与还原点**：已记录任务起始还原点编号，具备 5 秒内无损撤销手段。

---

## 一、 架构设计与非目标边界 (Scope & Non-Goals)
- **业务一句话目标**：[描述解决什么问题]
- **核心架构方案**：[简要描述设计思路与选型理由]
- **🚫 非目标清单 (Non-Goals - 本次绝对不做的事)**：
  1. [非目标项 1]
  2. [非目标项 2]

---

## 二、 接口契约与异常防御条例 (Contracts & Edge Cases)
- **核心数据契约 (Data Contracts)**：
  ```typescript
  // 或对应语言的 interface / dataclass / schema
  interface ExampleContract {
    // 显式锁定字段与类型
  }
  ```
- **异常与边界应对矩阵 (Edge Cases Matrix)**：
  | 异常场景 | 触发条件 | 预期系统表现 / 降级策略 | 对应测试用例 |
  | :--- | :--- | :--- | :--- |
  | 场景 1 | 空输入 / 非法参数 | 抛出统一错误码，不崩溃 | `test_invalid_input()` |
  | 场景 2 | 上游服务超时 / 网络抖动 | 重试 2 次后安全降级兜底 | `test_timeout_fallback()` |
  | 场景 3 | 数据冲突 / 并发重复 | 幂等忽略或返回冲突提示 | `test_idempotency()` |

---

## 三、 外部依赖与环境审计
- **新增依赖清单**：[无新增第三方依赖 / 如下列出]
  - 依赖名称与版本：`xxx@1.0.0`（协议：MIT / Apache）
  - 探针实测命令：`node -e "..."` ➔ 状态：[已通过]
- **环境变量声明**：[无需新变量 / 已写入 .env.example]

---

## 四、 原子化实施与验收清单 (Atomic Execution Plan)

### Task 1: [原子组件/模块名称]
**1. 影响文件与边界：**
- 新建: `path/to/new_file.py`
- 修改: `path/to/existing_file.py:12-30`
- 测试: `tests/test_feature.py`

**2. 接口契约 (Interface Contracts)：**
- Consumes (依赖输入): `[参数名: 类型]`
- Produces (交付产出): `[返回值: 类型]`

**3. 原子执行步骤 (TDD Steps)：**
- [ ] **Step 1 (Red)**: 编写失败测试 `test_feature_case()`
- [ ] **Step 2 (Verify Red)**: 运行 `pytest tests/test_feature.py -k test_feature_case` ➔ 确保预期失败
- [ ] **Step 3 (Green)**: 编写最小实现代码
- [ ] **Step 4 (Verify Green)**: 重新运行同一测试 ➔ 确保退出码为 0
- [ ] **Step 5 (Checkpoint)**: 保存本地还原点 / Commit

---

## 五、 去伪存真验收矩阵与回滚预案 (Verification & Rollback)
- **任务起始还原点编号**：`[git rev-parse --short HEAD 输出]`
- **一键回滚撤销手段**：`git reset --hard [还原点] && git clean -fd`（或 `git stash pop`）
- **去伪存真全量验收命令**：
  - 测试命令：`npm test` / `pytest`
  - 退出码与输出期望：`All tests passed (exit code 0)`
