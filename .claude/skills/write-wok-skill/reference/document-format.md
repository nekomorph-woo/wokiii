# 文档输出格式规范

管道技能生成的所有 markdown 文档遵循统一格式。

## 双端口设计

每个文档有两个消费端口：

- **AI 端口**：YAML frontmatter — 结构化元数据，SKILL 互调时快速筛选，不加载正文
- **人类端口**：Brief blockquote — 3-5 行，30 秒理解文件内容

## 格式模板

```markdown
---
status: draft | approved
freshness: fresh | stale | impacted
intent: decision | reference | action | explanation
scope: global | affected-modules
depends: [doc-id, ...]
changed: 变更摘要（一句话）
wok:
  feature: <feature-name>
  stage: define | design | check | plan | review
  upstream_hashes:
    <parent-doc-path>: <git-blob-hash>
  last_change:
    source: skill | remark | manual
    impact: patch | minor | major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

# 标题

> **做什么**：一句话说明
> **怎么做**：一句话说明
> **阻塞**：阻塞项，无则写"无"

## 正文段落（按意图分区）

## <details><summary>深度内容标题</summary>

按需下钻的内容。

</details>
```

## Frontmatter 字段

| 字段 | 必填 | 说明 |
|------|:----:|------|
| `status` | ✅ | `draft`（待确认）、`approved`（已确认） |
| `freshness` | ✅ | `fresh`（基于最新上游）、`stale`（上游已变更需重新生成）、`impacted`（上游已变更可能受影响） |
| `intent` | ✅ | 文档的主要意图类型（见下方分类） |
| `scope` | ✅ | 影响范围：`global`（全局）或 `affected-modules`（仅影响指定模块） |
| `depends` | ❌ | 依赖的其他文档 ID，用于 SKILL 互调时的依赖分析 |
| `changed` | ❌ | 最近一次变更的一句话摘要，用于版本间快速对比 |
| `wok` | ❌ | 管道元数据嵌套对象（见下方 `wok` 字段说明） |

## wok 字段说明

| 字段 | 说明 |
|------|------|
| `wok.feature` | 所属 feature 名称 |
| `wok.stage` | 管道阶段：`define` \| `design` \| `check` \| `plan` \| `review` |
| `wok.upstream_hashes` | 父文档路径 → git blob hash 映射，用于 stale detection |
| `wok.last_change.source` | 变更来源：`skill`（SKILL 生成）、`remark`（备注应用）、`manual`（手动编辑） |
| `wok.last_change.impact` | 影响等级：`patch`（文字修正）、`minor`（局部调整）、`major`（结构性变更） |
| `wok.version` | 文档版本号，每次 SKILL 重新生成 +1 |
| `wok.generated_at` | 首次生成时间 |
| `wok.updated_at` | 最后更新时间 |

## 意图分类

| 意图 | 读者目的 | 典型内容 |
|------|----------|----------|
| `decision` | "定了什么？" | 设计锚点、方案选择、排除项 |
| `reference` | "具体定义是什么？" | 接口签名、数据结构、配置项、参数列表 |
| `action` | "下一步做什么？" | 执行步骤、验证标准、编码顺序 |
| `explanation` | "为什么这样设计？" | 设计 rationale、方案取舍、技术权衡 |

**一个文档只承载一种主要意图。** 需要混合意图时，拆分为多个文件。

## Brief 规范

- 格式：3-5 行 blockquote（`>`）
- 结构：做什么 / 怎么做 / 阻塞项
- 禁止：表格、代码块、超过 80 字的单行
- 位置：紧接在 `# 标题` 之后，正文之前

## <details> 使用规范

- 深度内容默认折叠：接口详细参数、实现约束、设计决策详解
- 浅层内容保持展开：Brief、核心结论、状态概览
- 每个 `<details>` 必须有描述性的 `<summary>`
- 禁止嵌套超过 1 层

### Summary 格式

`<summary>` 必须携带压缩信息，格式：

```markdown
<summary>【类型】一句话结论 + 影响范围</summary>
```

类型标签：`【方案对比】`、`【边界条件】`、`【异常路径】`、`【替代方案】`、`【详细接口】`、`【审查证据】`、`【推理过程】`、`【实现约束】`

### 展开/折叠规则

**默认展开**（不使用 `<details>`）：
- 结论、决策（`[DECISION]`）、风险、验收标准、模块概览

**默认折叠**（使用 `<details>`）：
- 推理过程、证据、替代方案长解释、复杂边界细节、接口详细定义、实现约束细节

### 折叠内容结构

```markdown
<details>
<summary>【类型】一句话结论 + 影响范围</summary>

### 背景

### 证据

### 建议动作

</details>
```

## 文档 ID 约定

文档 ID 用于 `depends` 字段和跨文档引用：

| 文档类型 | ID 格式 |
|----------|---------|
| 需求定义 | `req:<feature-name>` |
| 模块设计 | `mod:<module-name>` |
| 验证报告 | `chk:<feature-name>` |
| 执行计划 | `plan:<feature-name>` |

## 语义标记

段落级语义标记，供 dashboard 提取和人类快速识别。与 frontmatter `intent` 互补（intent 是文档级，语义标记是段落级）。

| 标记 | 含义 | 格式 | Dashboard 渲染 |
|------|------|------|---------------|
| `[DECISION]` | 已确定结论 | `## [DECISION] 结论标题` + 正文（含理由、对比） | 黑色左边框 + 灰底卡片 |
| `[OPEN]` | 待决项 | `## [OPEN] 问题描述` + 上下文（项目现状、选项对比、阻塞影响） | 编辑红左边框 + 浅红底高亮 |
| `[ACTION]` | 待执行动作 | `- [ACTION] 动作描述` | 黑色左边框 + ☐ 待办条 |

使用规则：
- `[DECISION]` / `[OPEN]` 作为 `##` 级标题使用，标题行仅含标记 + 摘要
- `[ACTION]` 作为列表项使用，含完整上下文在下方缩进内容中
- 每个标记块可包含表格、引用、代码块等详细上下文
- **DO NOT** 使用缩写标记（如 `D1`、`D2`、`O1`、`A1`）。Dashboard 仅识别完整 `[DECISION]` / `[OPEN]` / `[ACTION]` 格式，缩写会导致标记账本遗漏
