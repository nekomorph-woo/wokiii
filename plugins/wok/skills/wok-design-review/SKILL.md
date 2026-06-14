---
name: wok-design-review
description: 交叉验证模块设计的一致性和完整性，检查接口对齐、依赖方向和跨模块遗漏。Use when 用户要求交叉验证、检查设计一致性、审查模块设计，或提到 "wok-design-review" / "交叉验证"。
pipeline:
  upstream: [wok-design]
  downstream: [wok-plan]
  gate: false
  output: document
  adaptive: true
---

# 设计交叉验证

对模块设计做 4 项聚焦检查，不产出长篇审阅报告。发现问题直接列出，需要人工决策的标记为阻塞项。

## 快速开始

1. 读取 `modules/_registry.md` 获取模块列表
2. 执行 4 项检查
3. 产出 `<phase-dir>/_check.md`（与 `_define.md` 同级）

## 工作流程

### 1. 确定 system-name 和 phase-dir

> 读取 `~/.claude/wok/resolve-system-name.md` 执行 system-name 解析。

解析优先级（按顺序尝试）：

1. **上下文已明确** — 当前对话已有明确的 `<phase-dir>`（上游 skill 输出、用户先前指定）→ 直接使用，跳过解析
2. **用户手动指定** — 用户在请求中提供了 system-name、缩写或部分名称 → 执行 `bash ~/.claude/wok/resolve-system-name.sh <input> [phase]`
3. **无上下文无输入** — 执行 `bash ~/.claude/wok/resolve-system-name.sh`（无参数列出所有目录）→ AskUserQuestion 让用户选择

输出处理：

| 脚本输出 | 处理 |
|----------|------|
| 单行名称（无斜杠） | 扁平系统，设 `<phase-dir> = .wok-plans/<system-name>/` |
| 单行路径（含斜杠） | 多阶段系统，设 `<phase-dir> = .wok-plans/<system-name>/<phase-dir>/` |
| `PHASES:` + 多行 | AskUserQuestion 让用户选择 phase，再以选中的 phase 作为参数重新调用脚本 |
| `AMBIGUOUS:` / `AMBIGUOUS_PHASE:` | AskUserQuestion 让用户选择 system 或 phase，重新调用 |
| `NOT_FOUND: <input>` | 询问用户提供完整名称 |

### 2. 读取上游设计

检查 `<phase-dir>/modules/_registry.md` 是否存在：

- **存在**：读取 frontmatter，提取模块列表和依赖图，加载各模块 `design.md` 的 frontmatter 和接口契约
- **不存在**：从代码库和当前对话上下文中识别模块和接口定义

### 3. 执行检查

4 项聚焦检查（详见 reference/check-spec.md）：

**锚点覆盖检查**使用脚本自动执行：

```bash
python3 plugins/wok/scripts/check_anchors.py <phase-dir>
```

- exit code 0：全部通过
- exit code 2：`[SECURITY]` 缺口或 `[EXCLUSION]` 违规，输出报告中的 🚨 项转为 🔴 finding
- ⚠️ 项转为 🟡 finding

脚本未覆盖的接口一致性、依赖方向和输出格式检查，由 AI 逐模块审查。

| 检查项 | 内容 | 严重度分级 |
|--------|------|:----------:|
| **接口一致性** | 跨模块调用的参数类型、返回值、异常是否对齐 | 🔴/🟡/🟢 |
| **依赖方向** | 是否存在循环依赖、是否违反分层约束 | 🔴/🟡 |
| **跨模块遗漏** | 设计锚点是否被全部覆盖、用户故事是否有遗漏模块 | 🔴/🟡/🟢 |
| **输出格式** | decisions.md 决策/开放问题标题、_check.md finding/行动项格式是否符合 `output-format.md` | 🔴/🟡/🟢 |

### 4. 生成检查结果

产出 `<phase-dir>/_check.md`：

```markdown
---
status: draft
intent: action
scope: global
depends: [mod:*]
changed: 初始版本
---

> **检查项**：4 项
> **问题数**：<N> 个（🔴 <N> / 🟡 <N> / 🟢 <N>）
> **阻塞**：<是否有阻塞项>

## 检查结果

### 接口一致性

🟡 **Finding 1: <问题描述>**

<详细说明>

- **影响模块**：<模块列表>
- **修复**：<修复建议>

#### [OPEN] 🟡-1: <对应行动项标题>

- [ACTION] <修复动作>

🟢 **Finding 2: <已通过项>**

<说明>

### 依赖方向
### 跨模块遗漏
### 输出格式
```

> 行动项直接放在对应 finding 下方，使用 `#### [OPEN]` 标题。🟢 项不产生行动项。

**折叠规则**：
- Finding 总数 ≤ 5 且文档 ≤ 150 行 → 不使用 `<details>`
- 🟢 Finding 使用 `<details>` 折叠，summary 格式：`【审查证据】Finding N: 通过项标题`
- 非阻塞 finding（🟡）超过 3 条时，第 4 条起用 `<details>` 折叠

**输出自检**（写入 `_check.md` 后必做）：

重新读取产出的 `_check.md`，逐项核对：

- [ ] finding 标题为 `🔴/🟡/🟢 **Finding N: <问题>**`，N 从 1 连续递增
- [ ] 每个 🔴/🟡 finding 下方有且仅有一个 `#### [OPEN] <severity>-<N>: <标题>`
- [ ] 每个 `#### [OPEN]` 下方至少一行 `- [ACTION] <动作>`
- [ ] 🟢 finding **无** `#### [OPEN]` 行动项
- [ ] 全文无 `D1`/`O1`/`A1`/`F1` 等缩写引用
- [ ] 🟢 finding 已用 `<details>` 折叠；🟡 非阻塞 finding 超过 3 条时第 4 条起已折叠

任一项不通过 → 立即修正 `_check.md`，不进入处理阶段。

### 5. 处理检查结果

🟢 级问题自动修复（文档层面的机械性修正）。

🔴 阻塞项使用 `/wok-grill-me` 拷问修复方案：

- 这个问题的根因是什么？
- 修复会影响哪些模块？
- 是否需要回到上游技能重新设计？

拷问达成共识后，执行修复：

1. **反向修补**：定位受影响的设计文档段落，展示 diff，确认后修补
2. **连锁更新**：修补后检查是否影响其他文档（依赖方向、引用关系），深度上限 2 级
3. **修补顺序**：共享定义 → 模块 design.md → 模块 decisions.md → _registry.md

修补完成后，判断变更范围决定下一步：

- **轻量变更**（仅文档措辞修正、无接口变更）→ 继续处理下一个阻塞项
- **接口变更**（签名修改、新增接口、模块边界调整）→ 更新 `_check.md` 行动项状态，提示是否需要重新运行 `/wok-plan`

🟡 级标记为建议项，用户自行决定是否处理。

## 约束

- **DO NOT** 产出超过 3 份以上的报告文件 — 只有一个 `_check.md`
- **DO NOT** 审查代码实现 — 只审查设计文档
- **DO NOT** 使用缩写标记（如 `O1`、`A1`），必须使用完整 `#### [OPEN]` / `- [ACTION]` 格式
- **DO NOT** 在 `_check.md` 中使用 `D1`/`O1`/`A1`/`F1` 等缩写引用，必须用完整 `Finding N` 或 `#### [OPEN]` 标题
- **DO NOT** 跳过输出格式检查 — 即使内容正确，格式错误也必须列为 finding
- **DO NOT** 在生成 `_check.md` 后省略自检 — 重新读取产出的 `_check.md`，验证 finding 编号连续、行动项格式完整、折叠规则正确
- 检查范围随设计存量自适应：增量模式只检查变更涉及的模块
