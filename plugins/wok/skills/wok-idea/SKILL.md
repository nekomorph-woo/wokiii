---
name: wok-idea
description: 消化需求描述并设计版本化路线图。处理从零散想法到完整 PRD 的各种输入规模，通过发散和侦察双轨探索，收敛为精选 feature 列表和分阶段 roadmap。Use when 用户缺乏功能想法、需要灵感、有大段需求/PRD 需要消化、或提到 "wok-idea" / "roadmap" / "功能规划" / "路线图"。
pipeline:
  upstream: [wok-findings]
  downstream: [wok-define]
  gate: true
  output: document
  adaptive: false
---

# 功能路线图设计

消化需求描述，探索功能灵感，收敛为版本化路线图。不定义接口或实现设计——那是下游技能的职责。

## 快速开始

> 读取 `~/.claude/wok/resolve-system-name.md` 执行 system-name 解析。

### system-name 约定

wok-idea 是 `feat-`（大功能）管道的入口。生成的 system-name 使用 `feat-` 前缀：

- 格式：`feat-<项目名>`（如 `feat-smart-home`、`feat-e-commerce`）
- 目录：`.wok-plans/feat-<项目名>/`

1. 接收需求输入（零散想法 / 大段描述 / 完整 PRD）
2. 双轨并行探索（发散 + 侦察）
3. 与用户讨论发现
4. 精选 feature → 设计分阶段 roadmap
5. 产出 `_roadmap.md`（格式见 [reference/output-format.md](reference/output-format.md)）

## 工作流程

### 1. 了解上下文与需求输入

判断用户的输入类型：

| 输入类型 | 示例 | 处理方式 |
|----------|------|----------|
| 零散想法 | "我想做一个智能家居系统" | 进入 §2 发散探索 |
| 结构化需求 | 500-1000 字的需求描述 | 提取核心需求，补充发散 |
| 完整 PRD | 聊天记录整理的 PRD 文档 | 解析 PRD 结构，提取 feature 列表作为 Track A 输入 |

**大输入消化**：用户提供了完整 PRD 或长篇需求时，不要跳过发散探索。将 PRD 解析为初步 feature 列表，再与发散探索的结果合并。PRD 提供结构，发散提供灵感，两者互补。

询问用户补充（如未在输入中体现）：
- 当前版本已有哪些功能？
- 技术栈和现有架构约束？
- 想要探索的方向或解决的问题？

**读取上游**（可选）：检查 `.wok-plans/<system-name>/` 下是否已有产出物（`_roadmap.md` 或 phase 子目录），了解已有设计存量。检查 `.wok-plans/<system-name>/_findings.md` 是否存在：
- **存在**：读取并提取设计约束、现有模式、潜在问题作为需求输入的补充上下文
- **不存在**：跳过

### 2. 双轨探索

并行执行两条探索轨道：

**Track A — 发散**（主上下文）：

基于项目上下文，从以下角度发散功能点：
- 用户视角：用户当前最痛的点是什么？用户用完会说什么"要是能..."？
- 竞品视角：同类产品有什么而我们没有？
- 技术视角：现有架构中哪些模块有明显的扩展空间？
- 趋势视角：领域内近期有什么新技术/新模式值得关注？

**Track B — 侦察**（使用 Agent 子代理）：

基于项目实际功能领域，搜索互联网获取灵感：
- 搜索同类开源项目的 feature 列表和 roadmap
- 搜索相关领域的技术博客、社区讨论
- 搜索竞品的更新日志和用户反馈

搜索策略：用 3-5 个不同角度的查询词，覆盖中英文来源。使用 WebSearch 和 WebReader 工具。

### 3. 综合发现

合并两条轨道的结果，去重后分类展示。展示格式见 [reference/discovery-format.md](reference/discovery-format.md)。

每个 feature 附带简要说明：做什么、为什么有价值、复杂度评估（S/M/L）。

### 4. 精选 feature

使用 AskUserQuestion 让用户选择感兴趣的 feature（multiSelect）。

对用户选中的每个 feature，追问：
- 优先级排序（哪些必须做、哪些可以等）
- 有无依赖关系（A 完成后才能做 B）

### 5. 设计路线图

将精选 feature 按阶段分组。分组原则：

| 原则 | 说明 |
|------|------|
| 用户价值优先 | 先做用户能感知到的功能 |
| 基础设施优先 | 为后续功能提供底座的先做 |
| 风险可控 | 每个阶段的复杂度均衡 |
| 依赖排序 | 有前置依赖的排在后面 |

**phase 粒度约束**：每个 phase 控制在 1-3 个模块，确保下游管道（wok-define → wok-implement）单次产出在人类可审阅范围内。

| 指标 | 控制目标 |
|------|----------|
| 每个 phase 模块数 | 1-3 个 |
| 每个 phase 设计产出 | ~3000 行以内 |
| 每个 phase 可验证性 | 产出端到端可验证的能力 |

如果某个 phase 预估超过 3 个模块，拆分为子 phase。阶段格式见 [reference/discovery-format.md](reference/discovery-format.md)。

### 6. 产出路线图

产出 `.wok-plans/<system-name>/_roadmap.md`，格式见 [reference/output-format.md](reference/output-format.md)。

### 7. 验证门

展示路线图概要，用户确认后更新 status 为 approved。验证门输出格式见 [reference/output-format.md](reference/output-format.md)。

## 迭代使用

本技能产出多 phase 路线图后，每个 phase 独立走下游管道：

```
Phase 1: wok-define → wok-design → wok-design-review → wok-plan → wok-implement
                                    ↓ （代码库已进化）
Phase 2: wok-define（已知 Phase 1 约束）→ wok-design（adaptive: true）→ wok-design-review → wok-plan → wok-implement
```

- **wok-findings** 仅在 Phase 1 首次执行（探索代码库现状）
- **后续 phase** 的 wok-design 使用 adaptive 模式，基于已有代码库和设计存量做增量设计
- 每个 phase 的 wok-design-review 交叉验证仅覆盖该 phase 的模块，复杂度可控

## 约束

- **DO NOT** 定义接口或实现设计 — 这是 `wok-define` 和下游技能的职责
- **DO NOT** 评估技术可行性细节 — roadmap 是方向性规划，不做技术深入
- **DO NOT** 跳过用户精选步骤 — roadmap 必须反映用户偏好，不可自作主张
- feature 的复杂度评估仅供参考，不作为排期的依据
