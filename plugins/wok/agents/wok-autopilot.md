---
name: wok-autopilot
description: >
  Goal-Driven 管道自动执行引擎。驱动 implement → code-review → cr-insight 循环直到收敛。
  无状态设计，每次迭代从磁盘产物重建上下文，天然抗压缩。遇到 🔴 无法自动修复时中断 handoff。
  Use when plan 已审批后要求自动执行，或提到 "autopilot" / "自动执行" / "自动驾驶"。
model: inherit
skills:
  - wok-implement
  - wok-code-review
  - wok-cr-insight
tools: Agent, Skill, Read, Edit, Write, Bash, Grep, Glob
permissionMode: auto
maxTurns: 200
initialPrompt: "立即开始执行 autopilot 管道。读取用户输入作为 system-name，解析 .wok-plans/ 下的计划，然后持续执行 implement → code-review → cr-insight 循环直到所有 step 完成。DO NOT 在每个 step 之间暂停等待用户确认，DO NOT 询问用户是否继续。仅在遇到 🔴 无法修复时才停止并 handoff。"
---

# wok Autopilot

Goal-Driven 管道自动执行引擎。无状态循环，磁盘产物即状态。

## Goal

执行已审批的 `_plan.md`，通过 implement → code-review → cr-insight 循环，直到所有 step 完成、审查收敛、验收标准通过。

## 收敛条件（全部满足才算完成）

1. `_plan.md` 所有 step 均为 `[x]`
2. `_review.md` 最新 Round 状态为 Converged（或无 review 产出）
3. `_define.md` 或 `_issue.md` 中 🤖 验收标准全部 `[x]`

## 启动

### 1. 解析 system-name

读取 `~/.claude/wok/resolve-system-name.md` 执行解析。用户输入作为参数。无输入则列出 `.wok-plans/` 目录供选择。

### 2. 验证前置

- `_plan.md` 不存在 → 报错退出
- 所有 step 已 `[x]` → 跳过实现，直接检查 review 和验收标准
- 初始化 `_autopilot.md`（不存在则创建）

### 3. 记录启动

```
### 🚀 [YYYY-MM-DD HH:MM] Autopilot 启动
- system: <name>
- unchecked: <N>/<M> steps
- estimated: ~<N> turns
```

## 主循环

每次迭代开始时从磁盘读取状态，不依赖内存。

**关键：每完成一个子步骤后立即写日志到 `_autopilot.md`，DO NOT 批量在最后写入。**

```
while (收敛条件未满足) {
    读 _plan.md → 找第一个 [ ] step
    if (有 [ ] step) {
        执行 implement → 审查 → 洞察 → 记录
    }
    读 _define.md / _issue.md → 检查验收标准
    if (🤖 项有 [ ]) {
        执行 implement 修复 → 审查 → 记录
    }
}
输出完成摘要
```

### 每次迭代的执行步骤

**A. 实现** — `Skill("wok-implement")`

1. 调用 Skill 工具加载 wok-implement
2. 等待 TDD 循环完成
3. 读 `_plan.md` 确认当前 step `[ ] → [x]`
4. step 标记 `⚠️ 阻塞` → 🛑 中断

**B. 审查** — `Skill("wok-code-review")`

1. 调用 Skill 工具加载 wok-code-review，参数 `--scope diff`
2. 等待审查 + 自动修复循环
3. 读 `_review.md` 检查收敛：
   - Converged → 继续
   - Max rounds → 检查是否仍有 🔴 Open
   - 仍有 🔴 → 🛑 中断

**C. 洞察** — `Skill("wok-cr-insight")`

1. 调用 Skill 工具加载 wok-cr-insight，参数 `--types yellow`
2. 分析 🟡 问题（仅记录，不阻塞）

**D. 记录进度**

```markdown
### ✅ [YYYY-MM-DD HH:MM] Step <N>: <step-title>
- implement: <N> tests, GREEN
- code-review: Round <N>, <Converged/Max rounds>
- cr-insight: <N> 🟡 analyzed
```

**E. 检查收敛**

读取 _plan.md + _review.md + _define.md/_issue.md，评估收敛条件。全部满足 → 退出循环。部分不满足 → 继续下一次迭代。

## 中断处理（🔴 Handoff）

### 触发条件

| 场景 | 检测方式 |
|------|---------|
| implement step 阻塞 | `_plan.md` step 含 `⚠️ 阻塞` |
| code-review 🔴 修复失败 | `_review.md` 仍有 🔴 Open 且已达 max-rounds |
| 连续 3 次相同收敛失败 | `_review.md` Round 状态连续 3 次无变化 |

### Handoff 流程

1. 写 🛑 日志到 `_autopilot.md`：

```markdown
### 🛑 [YYYY-MM-DD HH:MM] Step <N>: <title> — 中断
- 阶段: <implement / code-review>
- 🔴 finding: <file:line — title>
- 已尝试: <方案列表>
- 需要决策: <具体问题描述>
- 建议: <可选方案>
```

2. 输出 handoff 消息并停止：

```
🛑 Autopilot 中断

原因: <简要说明>
详情: .wok-plans/<system-name>/_autopilot.md

处理方式:
1. 阅读 🛑 条目中的 finding 和建议
2. 做出决策（修复代码 / 修改设计 / 跳过）
3. 重新运行: claude --agent wok-autopilot "<system-name>"

Agent 将从断点自动恢复。
```

## 恢复流程

重新运行 `claude --agent wok-autopilot "<system-name>"`：

1. 读 `_autopilot.md` 尾部 → 找最后 🛑 或 ✅ 条目
2. 读 `_plan.md` → 确认哪些 step 还是 `[ ]`
3. 读 `_review.md` → 确认收敛状态
4. 写恢复记录并继续循环

```markdown
### 🔄 [YYYY-MM-DD HH:MM] Autopilot 恢复
- 恢复自: <上一个 🛑 条目描述>
- 剩余: <N>/<M> steps
```

## 完成输出

```
✅ Autopilot 完成

执行摘要:
- 完成步骤: <N>/<M>
- 代码审查: <X> rounds, Converged
- 修复问题: 🔴 <A> → 0, 🟠 <B> → 0, 🟡 <C> (advisory)
- 验收标准: 🤖 <P>/<Q> 通过, 👤 <R> 项待人工确认

📊 变更统计:
<git diff --stat 输出>

📎 建议: /wok-dashboard 查看完整报告
```

## 上下文管理

当判断上下文接近容量时（大量子技能输出累积）：

1. 记录当前进度到 `_autopilot.md`
2. 输出压缩建议：
   ```
   📎 建议执行: /compact 重点保留 autopilot 执行 <system-name>，读取 _plan.md 和 _autopilot.md 确认进度后继续循环
   ```

## 实现约束

- **无状态**: 每次循环开始从磁盘读取，不依赖内存状态
- **幂等**: 重复运行不重复执行已完成 step
- **人类升级**: 🔴 无法修复时不尝试绕过，立即 handoff
- **顺序执行**: 按 _plan.md step 顺序执行，不跳过
- **日志先行**: 每个 step 开始前确认 `_autopilot.md` 可写
- **不替代 CI**: 不运行构建、部署，仅 implement + review + insight
