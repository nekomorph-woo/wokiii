---
name: wok-code-review
description: >
  多 agent 并行代码审查引擎。调度 5 个专业 agent 审查代码，对全部 findings 执行洞察分析，
  输出含修改建议的报告。不执行代码修改，修复由调用方决定。
  Use when 用户要求代码审查、审查变更、提到
  "wok-code-review" / "代码审查" / "code review"。
pipeline:
  upstream: [wok-implement, wok-plan]
  downstream: []
  gate: false
  output: _review.md
  adaptive: false
---
# 多 Agent 代码审查

纯检测 + 分析 + 报告。不执行代码修改。修复由 autopilot（调 impl）或用户自行决定。

## 命令接口

```
/wok-code-review [--scope <范围>] [--focus <维度>]
```

| 参数 | 格式 | 默认值 | 说明 |
|------|------|--------|------|
| `--scope` | `diff` / `branch` / `files:<path>` | `diff` | 审查范围 |
| `--focus` | 逗号分隔的 agent 名 | 全部 | 仅启用指定 agent |

**agent 名称映射**：

| `--focus` 值 | agent |
|--------------|-------|
| `logic` | code-reviewer |
| `comment` | comment-analyzer |
| `error-handling` | silent-failure-hunter |
| `type` | type-design-analyzer |
| `test` | pr-test-analyzer |

## 参考文档

执行前读取以下共享参考文档：

* `reference/finding-format.md` — finding 输出格式规范
* `reference/severity-guide.md` — 严重度分级标准
* `reference/agent-constraints.md` — 排除约束
* `reference/pipeline-context.md` — 管道上下文协议
* `reference/report-writer.md` — 报告写入规格

## 执行阶段

### Stage 0: 预检

> 读取 `~/.claude/wok/resolve-system-name.md` 执行 system-name 解析。

1. **检测管道上下文**：搜索 `.wok-plans/` 目录下的 `_define.md`
   * 存在 → 管道模式：提取设计锚点和验收标准作为审查基准，`phase_dir` 设为 `.wok-plans/<system-name>/`
   * 不存在 → 独立模式（`cr-` 管道）：生成 `cr-` 前缀的 system-name（如 `cr-refactor-auth`），创建 `.wok-plans/cr-<name>/` 目录，`phase_dir` 设为该目录
2. **解析已有报告**：若 `<phase_dir>/_review.md` 存在，提取所有已报告 🟡 的 `file:line + title` 作为去重集合
3. **解析 `--scope`**：
   * `diff` → `git diff --name-only` 获取未提交变更
   * `branch` → `git diff --name-only main...HEAD` 获取全分支变更
   * `files:<path>` → 直接使用指定路径
4. 过滤非代码文件（图片、二进制、lock 文件等）
5. 若无变更文件 → 输出"无变更可审查"并退出
6. **提取验收标准**（仅管道模式）：读取 `_define.md` 或 `_issue.md` 的 `## 验收标准` section，提取所有 🤖 条目的编号和文字 → `acceptance_criteria` 列表。元素格式：`US-N 🤖M: <条件文字>`（M 为带圈数字，不含 checkbox 前缀）

**产出**：上下文包（含 files 列表、language、design_anchors、prd_summary、phase_dir、acceptance_criteria）

### Stage 1: 并行审查

读取 `agents/*.md` 目录下所有 agent 定义文件。按 `--focus` 参数筛选子集，未指定则调度全部 5 个。

使用 Agent 工具并行调度每个 agent：

| Agent | 输入构建方式 |
|-------|-------------|
| code-reviewer | XML 格式上下文包（`<files>` + `<rules>` + `<design-anchors>`） |
| comment-analyzer | 表格格式（files + diff + phase-context） |
| silent-failure-hunter | 表格格式（files + context + language） |
| type-design-analyzer | 表格格式（files + context） |
| pr-test-analyzer | 表格格式（scope_files + test_dir + prd_context + acceptance_criteria） |

**构建规则**：

* `files`：读取每个文件的完整内容，包含绝对路径和语言标识
* `rules`：从 `CLAUDE.md` 和 `.claude/rules/*.md` 提取项目规则摘要
* `design-anchors`：管道模式下从 `_define.md` 提取；独立模式省略
* `diff`：`git diff` 的变更内容
* `context` / `phase-context` / `prd_context`：管道模式下为设计锚点摘要；独立模式为 null

每个 agent 返回标准化 finding 列表。格式参见 `reference/finding-format.md`。

### Stage 2: 聚合与分级

1. 收集所有 agent 的 findings，按 `file:line + title` 去重
2. 对照 `reference/severity-guide.md` 校准严重度
3. **🟡 去重**：对比 Stage 0 提取的去重集合，移除已报告的 🟡
4. 分类：
   * `findings_open`：本轮所有 🔴 + 🟠 + 去重后的 🟡
   * `findings_advisory_new`：本轮新增的 🟡（仅首次出现）

### Stage 3: 洞察分析

对 **全部 findings**（🔴🟠🟡）执行洞察分析，不区分严重度。

对每个 finding 执行洞察分析流程（内化执行，不通过 Skill 调用）：

1. **读取源代码**：读取 finding 涉及的源代码上下文
2. **根因追溯**：分类为以下之一
   - 设计缺陷：需求阶段遗漏或设计不充分
   - 编码疏忽：实现过程中的疏忽或简化
   - 架构约束：现有架构导致的最优妥协
   - 上下文缺失：缺少领域知识或业务背景
3. **修改方案**：给出可直接执行的代码建议
4. **一致性评估**（管道模式）：对照 `_define.md` 设计锚点评估

洞察分析失败 → 跳过该 finding 的洞察，降级为仅原始 finding 描述。

### Stage 4: 报告写入

调用 `reference/report-writer.md` 规格写入 `<phase_dir>/_review.md`：

* 首次生成 → 创建文件，写入 header + Round 1
* 后续轮次 → 当前 Round 覆写，历史向下追加

**每个 finding 附加洞察分析**：

```markdown
> **🔍 原因分析**
> <根因分类>: <详细说明>

> **🔧 修改方案**
> <具体修改步骤，含完整代码>

> **📐 一致性评估**
> <与 PRD/设计目标的关系评估>
```

状态标记（与 reference/report-writer.md 保持一致）：

* 无 findings → `✅ Converged`
* 仅有 🟡 → `Analyzed`（所有 🔴🟠 已修复或仅有 advisory）
* 有 🔴🟠 → Round header 无额外标记（Open 区段有内容即表示未收敛）

### Stage 5: 验收标准检查（仅管道模式）

**独立模式（`cr-` 管道）跳过此阶段。**

1. **定位验收文档**：
   * `fix` 管道 → 读取 `_issue.md` 的 `## 验收标准` section
   * 其他管道 → 读取 `_define.md` 的 `## 验收标准` section
   * 无验收标准 → 跳过此阶段
2. **逐条检查**：
   * 🤖 项（自动验证）：对应代码已有测试覆盖或修复已确认 → 标记 `[x]`；未满足 → 保持 `[ ]`
   * 👤 项（人工确认）：保持 `[ ]` 不动，留给人类在 Dashboard 确认
3. **写回文件**：仅修改 `[ ]` → `[x]`，不改变其他内容
4. **结果提示**：
   * 存在未通过的 🤖 项 → 输出「N 条自动验收标准未通过，需 wok-implement 修复」
   * 存在待确认的 👤 项 → 输出「N 条验收标准需人工确认，请在 Dashboard 中操作」

## 两种调用场景

| 方面 | autopilot 调用 | 用户/cr-管道 调用 |
|------|---------------|------------------|
| 触发方式 | autopilot 在 CHECKPOINT 调用 | 用户主动 `/wok-code-review` |
| 审查范围 | `--scope diff` | 用户指定 |
| 输出 | `_review.md`（含全部分析） | `_review.md`（含全部分析） |
| 修复 | autopilot 读报告后调 impl | 用户读报告后自行决定 |
| 循环 | autopilot 负责 CR → impl → CR 循环 | 用户手动控制 |

## 异常处理

| 场景 | 处理 |
|------|------|
| 无变更文件 | 输出"无变更可审查"，不产出报告 |
| 洞察分析失败 | 跳过该 finding 的洞察，降级为仅原始描述 |
| 重复执行 | 幂等：已有洞察分析的 finding 不重复分析 |

## 实现约束

* 每个 agent 必须可独立调用
* DO NOT 执行代码修改 — CR 只检测、分析、报告
* DO NOT 替代 CI（构建、类型检查、测试运行）
* DO NOT 替代 linter（代码风格、格式化）
* DO NOT 做 PR review（不评估变更合理性）
* 管道终点全分支审查由外部调用方使用 `--scope branch` 触发
