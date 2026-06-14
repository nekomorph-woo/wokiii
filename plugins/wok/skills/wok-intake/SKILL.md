---
name: wok-intake
description: 把在非 wok 管道对话中完成的成果（找 bug、设计方案、idea 探讨、代码探索）接入 wok 管道。推理候选管道类型让用户选择，按所选管道归档对应文档（仅到 wok-plan 之前）。Use when 用户在普通对话或 Plan Mode 完成探索/设计后想要 wok 管道落盘，或提到 "intake to wok" / "接入管道" / "落盘到 wok" / "wok-intake" / "成果归档"。
pipeline:
  upstream: []
  downstream: [wok-plan]
  gate: false
  output: document
  adaptive: false
---

# wok 管道接入

把在**非 wok 管道对话**中（Claude Code 普通对话、Plan Mode、其他工具产出）完成的成果接入 wok 管道，归档为对应阶段的文档。

## 适用场景

- 在普通对话中完成了 bug 排查、根因分析 → 接入 `fix-` 管道
- 在 Plan Mode 中设计了大致方案 → 接入 `feat-s-` 或 `feat-` 管道
- 探索代码后总结了约束/模式 → 接入 `exp-` 管道
- 讨论 idea 后想要落地 → 接入 `feat-` 管道

**不适配场景**：

- 代码审查 → 直接用 `/wok-code-review`（cr- 管道不归档到 plan 之前）
- 完整的从零规划 → 直接用对应入口 skill（`/wok-idea` / `/wok-define` / `/wok-issue` / `/wok-findings`）

## 工作流程

### 1. 圈定范围

询问用户成果的来源（默认当前对话上下文）：

| 来源 | 处理 |
|------|------|
| 当前对话上下文 | 提取最近 N 轮对话的关键信息 |
| 指定文件 | Read 用户提供的文件路径（截图/文档/代码片段） |
| git diff / commit | Bash 提取变更内容 |

提取后**简要复述**给用户确认：成果包含什么、关键信息有哪些。

### 2. 推理候选管道

按内容信号推理 2-3 个候选管道，按置信度排序。推理规则详见 [reference/inference-rules.md](reference/inference-rules.md)。

| 信号 | 候选管道 |
|------|----------|
| 功能描述 + 用户故事 + 多模块 | `feat-` |
| 功能描述 + 用户故事 + 单模块 | `feat-s-` |
| 问题/报错 + 根因分析 | `fix-` |
| 代码探索 + 约束/模式总结 | `exp-` |

**不推理 `cr-`**：审查变更不归档到 plan 之前，提示用户直接用 `/wok-code-review`。

### 3. AskUserQuestion 选择管道

```json
{
  "question": "选择接入的管道类型",
  "header": "管道",
  "options": [
    {"label": "<候选1> (推荐)", "description": "<推理理由>"},
    {"label": "<候选2>", "description": "<推理理由>"},
    {"label": "<候选3>", "description": "<推理理由>"}
  ],
  "multiSelect": false
}
```

第一项是最可能匹配，标 `(推荐)`。如果用户想审查代码变更，引导用 `/wok-code-review`。

### 4. 确定 system-name

- 询问用户 system-name（建议基于内容关键词生成 2-3 个候选）
- 前缀根据所选管道自动加：
  - `feat-` / `feat-s-` / `fix-` / `exp-`
- 用户可调用 `bash ~/.claude/wok/resolve-system-name.sh <input>` 验证（脚本不存在时跳过）

### 5. 调度下游 skill 生成文档

按所选管道的调度顺序，主 agent **依次调用下游 skill** 生成对应文档。wok-intake 自身不写文档内容，只负责调度。详细调度表见 [reference/dispatch-table.md](reference/dispatch-table.md)。

| 管道 | 调度顺序 |
|------|----------|
| `feat-` | `wok-define` → `wok-idea` → `wok-design` → `wok-design-review`（可选） |
| `feat-s-` | `wok-define` → `wok-design`（可选） |
| `fix-` | `wok-issue` |
| `exp-` | `wok-findings` |

**调度清单跟踪**（防止主 agent 陷入下游 skill 完整流程）：

1. **建清单**：用 TaskCreate 为每个待调度的下游 skill 创建一个 task（subject = `调度 <skill-name> 生成 <文件名>`）
2. **逐个执行**：
   - TaskUpdate → in_progress
   - 调用 `Skill("<skill-name>")` 加载其 SKILL.md
   - **只执行该 skill 的"产出文档"核心步骤**，按 [reference/dispatch-table.md](reference/dispatch-table.md) 的"调度约束"跳过询问/上下游检查/验证门
   - 用 Step 1 圈定的成果摘要作为输入，写入指定路径
   - TaskUpdate → completed
   - 输出过渡语：「已完成 `<skill-name>` → `<文件>`，继续调度下一个」
3. **全清单完成**才进入 Step 6

**调度约束**（详见 dispatch-table.md）：

- **DO NOT** 执行下游 skill 的询问用户 / 读取上游 / 验证门步骤 — intake 已处理
- **DO NOT** 进入下游 skill 的完整多步骤流程 — 只取"产出文档"段
- **DO NOT** 创建远程 issue / PR — 仅本地落盘

所有调度产出的文档 frontmatter 中 `changed` 字段统一写 `初始版本（wok-intake 接入）`。

### 6. 输出建议

```
✅ 接入完成

管道类型: <prefix>-
目录: .wok-plans/<prefix>-<system-name>/

已归档文档:
- <文件1 路径> (<行数> 行)
- <文件2 路径> (<行数> 行)

⚠️ 请检查上述文档内容，按需修改。

下一步建议:
1. 审阅文档，按需修改
2. 运行 /wok-plan <system-name> 开始规划实现
3. 实现阶段会调用 wok-implement → wok-code-review
```

## 与其他 skill 的区别

| Skill | 场景 | 产出 |
|-------|------|------|
| `/wok-idea` / `/wok-define` / `/wok-issue` / `/wok-findings` | 从零开始走管道 | 对应阶段文档 |
| **`/wok-intake`**（本 skill） | 已有成果，反向接入管道 | 同上（仅 plan 之前阶段） |
| `/wok-plan` | 上下游文档已就绪，开始编码规划 | `_plan.md` |

## 约束

- **DO NOT** 归档 `cr-` 管道文档 — 审查变更用 `/wok-code-review`，产出 `_review.md` 不属于 plan 之前
- **DO NOT** 归档到 `wok-plan` 及之后阶段（`_plan.md` / `_autopilot.md` / `_review.md`）— 这些需要用户确认后由对应 skill 生成
- **DO NOT** 在归档中途询问用户确认 — 批量生成，完成后提示用户检查
- **DO NOT** 在推理时给出单一候选 — 至少 2 个，让用户选择
- **DO NOT** 把对话原文整段复制到文档 — 提取关键信息并按对应 skill 的文档格式重写
- **DO NOT** 自己写文档内容 — 调度下游 skill 生成，wok-intake 是调度者不是执行者
- **DO NOT** 进入下游 skill 的完整多步骤流程 — 只取"产出文档"段，跳过询问/上下游检查/验证门
- **DO NOT** 跳过 TaskCreate 调度清单 — 防止主 agent 陷入下游 skill 流程后遗忘主任务
