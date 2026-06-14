# 调度顺序表

按管道类型，主 agent 调度下游 skill 生成文档。**wok-intake 不关心下游 skill 的内部格式**，只关心：

- 调用顺序
- 输入摘要要点
- 输出路径

下游 skill 改了产出格式，wok-intake **不需要同步修改**。

## feat-（大功能）

| 顺序 | Skill | 输出路径 | 输入摘要要点 |
|:---:|---|---|---|
| 1 | `wok-define` | `_define.md` | 问题、目标、设计锚点、验收标准 |
| 2 | `wok-idea` | `_roadmap.md` | feature 列表、阶段划分 |
| 3 | `wok-design` | `modules/<name>/{design.md, decisions.md}` | 接口契约、设计决策 |
| 4 | `wok-design-review`（可选） | `_check.md` | 跨模块一致性检查；无冲突可省略 |

## feat-s-（小功能）

| 顺序 | Skill | 输出路径 | 输入摘要要点 |
|:---:|---|---|---|
| 1 | `wok-define` | `_define.md` | 问题、目标、设计锚点、验收标准 |
| 2 | `wok-design`（可选） | `modules/<name>/{design.md, decisions.md}` | 接口契约、设计决策 |

## fix-（问题修复）

| 顺序 | Skill | 输出路径 | 输入摘要要点 |
|:---:|---|---|---|
| 1 | `wok-issue` | `_issue.md` | 问题描述、报错、根因、修复方案 |

## exp-（探索优化）

| 顺序 | Skill | 输出路径 | 输入摘要要点 |
|:---:|---|---|---|
| 1 | `wok-findings` | `_findings.md` | 探索范围、约束发现、模式总结、优化建议 |

## cr-（不调度）

代码审查不在本 skill 调度范围。遇到 cr- 信号直接提示用户用 `/wok-code-review`。

## 调度约束（防止主 agent 陷入下游 skill 完整流程）

调用每个下游 skill 时：

**DO**：
- 加载该 skill 的 SKILL.md
- 按 SKILL.md 中的**产出格式段**生成对应文档
- 用 Step 1 圈定的成果摘要作为输入（已包含上表的"输入摘要要点"）
- 完成后立即返回 wok-intake 调度上下文，更新 task 状态

**DO NOT**：
- 执行下游 skill 的"询问用户"步骤（intake 已在 Step 1 收集输入）
- 执行下游 skill 的"读取上游"步骤（intake 已确定无上游或已合并）
- 执行下游 skill 的"验证门"步骤（intake 完成后用户统一审阅）
- 进入下游 skill 的完整多步骤流程
- 创建下游 skill 通常会创建的远程 issue / PR（仅本地落盘）

## frontmatter 标注

所有调度产出的文档 frontmatter 中 `changed` 字段统一标注：

```yaml
changed: 初始版本（wok-intake 接入）
```

便于追溯文档来源是 wok-intake 调度而非用户直接调用对应 skill。

## 不调度的内容

以下 skill 由用户在 wok-intake 完成后**单独决定**是否调用，wok-intake 不调度：

- `wok-plan` / `wok-implement` / `wok-code-review` / `wok-handoff` / `wok-cr-insight` / `wok-apply-remarks`

这些是 plan 及之后的阶段，需要用户基于已归档文档主动启动。
