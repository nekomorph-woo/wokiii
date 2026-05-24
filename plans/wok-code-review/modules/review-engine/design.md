---
status: approved

intent: reference
scope: affected-modules
depends: [req:wok-code-review]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    _define.md: 2d3e67c5f43dd564091816351e3fc0af2486515b
    modules/_registry.md: b95b3afc3c469d1acc56b53593b99eef065ccd7d
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **做什么**：审查编排引擎，调度 5 个专业 agent 并行审查，三级分级自动修复，迭代验证直到收敛
> **接口数**：1 个 skill 命令
> **阻塞**：无

## 接口契约

<details>
<summary>/wok-code-review [--scope <范围>] [--focus <维度>] [--max-rounds <N>] [--no-fix]</summary>

### 参数

| 参数 | 格式 | 默认值 | 说明 |
|------|------|--------|------|
| `--scope` | `diff` / `branch` / `files:<path>` | `diff` | 审查范围。`diff` = 未提交变更；`branch` = 全分支 vs main；`files:<path>` = 指定文件 |
| `--focus` | 逗号分隔的 agent 名 | 全部 5 个 | 仅启用指定维度，如 `logic,error-handling` |
| `--max-rounds` | 正整数 | `3` | 最大修复-验证迭代轮次 |
| `--no-fix` | flag | off | 只审查不修复，所有问题降级为 Advisory |

### 调用方式

```
/wok-code-review                                    # 管道/独立默认
/wok-code-review --scope src/auth/                 # 指定目录
/wok-code-review --scope branch                    # 全分支审查
/wok-code-review --scope diff --no-fix             # 只审查不修复
/wok-code-review --focus logic,error-handling      # 聚焦维度
```

### 返回值

| 字段 | 类型 | 说明 |
|------|------|------|
| `_review.md` | 文件 | 审计报告，写入 `<phase-dir>/_review.md` |

### 异常

| 场景 | 处理 |
|------|------|
| 无变更文件 | 输出"无变更可审查"，不产出报告 |
| 达到 max-rounds 未收敛 | 剩余 🔴🟠 降级为 🟡，报告中标记"达到迭代上限" |
| 修复失败 | 🟠 修复失败时升级为用户确认，不阻塞管道 |
</details>

## 执行阶段

### Stage 0: 预检

1. 检测管道上下文：定位 `<phase-dir>/_define.md`
   - 存在 → 管道模式：提取设计锚点、实现模块列表作为审查基准
   - 不存在 → 独立模式：仅代码语义审查
2. 检测已有 `_review.md`：提取已报告的 🟡 问题 ID，后续轮次跳过
3. 解析 `--scope`，计算变更文件列表，过滤非代码文件

### Stage 1: 并行审查

并行调度 5 个专业 agent（可由 `--focus` 筛选）：

| Agent | 维度 | 模型 |
|-------|------|------|
| code-reviewer | CLAUDE.md 合规 + bug 检测 | Sonnet |
| comment-analyzer | 注释准确性 | Sonnet |
| silent-failure-hunter | 静默失败/错误处理 | Sonnet |
| type-design-analyzer | 类型设计质量 | Sonnet |
| pr-test-analyzer | 测试覆盖率 | Sonnet |

每个 agent 输出标准化 finding 列表，格式：

```
[<severity>] <file>:<line> — <title>
  原因: <why>
  修复方案: <how>
  优化维度: <simplify 触发标记>（可选）
```

### Stage 2: 聚合与分级

1. 收集全部 findings，按 `file:line + title` 去重
2. 分级校准（对照分级标准 reference/severity-guide.md）
3. 过滤已报告的 🟡 问题（去重）

### Stage 3: 自动修复 + 验证循环（仅 🔴🟠）

1. 逐个修复 🔴🟠 问题：
   - 管道模式下，修复前对照 PRD 锚点验证方向
   - 修复后检测优化维度 → per-file 触发 simplify agent
2. 追加一轮 Stage 1 审查（仅已修复文件）
3. 比对新旧 findings：
   - 无新 🔴🟠 → 收敛，退出循环
   - 有新 🔴🟠 → 继续修复
4. 达到 `max-rounds` → 强制终止，剩余 🔴🟠 降级为 🟡

### Stage 4: 报告写入

调用 report-writer 写入 `<phase-dir>/_review.md`：
- 当前轮次覆写，历史轮次追加
- 🔴🟠 修复后从 Open 移入 Resolved
- 🟡 仅首次出现时写入 Open

### Stage 5: 洞见生成

触发 `wok-cr-insight` 分析所有 🟡 问题，在对应问题下方追加原因分析和修改方案。

## 实现约束

- 每个 agent 必须可独立调用（满足设计锚点）
- `--no-fix` 模式下同步跳过 simplify
- 管道终点时由外部调用方使用 `--scope branch` 触发全分支审查
- DO NOT 替代 CI（构建、类型检查、测试运行）
- DO NOT 替代 linter（代码风格、格式化）
- DO NOT 做 PR review（那是官方 code-review 的职责）
