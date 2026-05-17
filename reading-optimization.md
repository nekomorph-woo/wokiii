DDAi 长 Markdown 文档减压方案研究报告与解决方案

0. 结论摘要

你的 DDAi 当前已经形成了一条完整的“开发前置文档流水线”：

write-a-prd
  ↓
prd-to-plan / prd-to-modules / prd-to-issues
  ↓
audit-design-docs
  ↓
进入开发执行

这套体系的方向是对的。
问题不是 SKILL 错了，而是 生成能力太强，阅读入口太弱。

现在的核心矛盾是：

AI 需要完整文档来保证设计质量
但你不应该每次都阅读完整文档

所以最终方案不是“让 AI 少写”，也不是“抛弃 Markdown”，而是建立一套：

长文档保留完整性
短入口承担阅读
决策/风险/问题承担管理
执行项承担行动
详细正文按需下钻

一句话：

DDAi 不应该只生成 Markdown，而应该生成“带阅读控制台的开发文档包”。

这就是长文档减压的核心解法。

⸻

1. 背景与问题定义

1.1 当前背景

你现在的 DDAi SKILL 主要用于项目开发，尤其是从 0 或新 feature 开始时，帮助你生成：

PRD
设计方案
模块拆分
实现计划
issue 拆分
文档审计报告

这些文档的目标是好的：

降低盲目开发风险
提前澄清需求
沉淀设计依据
辅助 AI Coding 执行
提高复杂功能的可控性

但随之出现一个明显副作用：

每个 SKILL 都倾向于生成很长的 Markdown 文档
多个 SKILL 串联后，文档数量和长度急剧膨胀

于是你的实际体验变成：

想开发一个功能
↓
先生成 PRD
↓
PRD 很长
↓
再生成 plan
↓
plan 也很长
↓
再拆 modules
↓
模块 design 和 plan 更多
↓
再 audit
↓
审计报告又一堆
↓
还没写代码，人已经被 Markdown 埋了

非常工程化，也非常像给自己修了一座文档监狱。🪦

⸻

1.2 核心痛点

你的痛点不是：

Markdown 不好看
Markdown 不方便阅读
Markdown 格式不适合设计文档

真正痛点是：

文档太长
默认入口太重
不知道先看哪里
不知道哪些是决策
不知道哪些是风险
不知道哪些需要你确认
不知道哪些只是背景解释
不知道哪些内容和上版相比变化了

换句话说：

你缺的不是 Markdown 阅读器，而是文档信息分层机制。

⸻

1.3 问题本质

当前 DDAi 文档体系的问题可以总结为 5 点。

1. 生成完整性优先于阅读效率

SKILL 会努力写完整，但不会自动帮你建立阅读路径。

2. 每份文档都把完整正文当作默认入口

这导致你每次都像第一次审稿一样从头读起。

3. 决策、风险、未决问题散落在正文中

真正关键的信息没有被集中管理。

4. 文档之间缺少统一控制台

PRD、plan、modules、issues、audit 各有结构，但没有统一的“人类入口”。

5. 详细文档和日常阅读混在一起

详细设计应该是事实底座，不应该是每日默认阅读界面。

⸻

2. 研究判断：长文档该不该存在？

2.1 长文档仍然有价值

长文档不是敌人。

PRD、详细设计、模块计划、审计报告之所以长，是因为它们承担了这些职责：

记录背景
解释设计理由
保存边界条件
描述异常情况
沉淀方案取舍
支持未来追溯
辅助 AI Coding 理解上下文

如果强行让 AI 少写，可能出现反效果：

文档短了
但上下文缺了
设计依据丢了
AI Coding 执行时更容易跑偏
未来回看不知道为什么这么做

所以不能简单要求：

所有文档控制在 1000 字以内

这会变成另一种自残。只是这次不是被 Markdown 淹死，而是被信息缺失绊死。🧱

⸻

2.2 问题不在“长”，而在“没有层级”

正确判断是：

长文档可以存在
但长文档不应该作为默认阅读入口

详细正文应该定位为：

事实底座
归档材料
追溯依据
深度审查材料
AI Coding 上下文

而日常入口应该是：

Brief
Decision Summary
Open Questions
Risks
Next Actions
Change Summary
Reading Guide

这就是整个方案的关键。

⸻

3. 目标方案：DDAi Document Bundle Protocol

建议你给 DDAi 制定一个统一协议：

DDAi Document Bundle Protocol

也可以叫得人话一点：

DDAi 文档包规范

核心原则：

所有长文档型 SKILL，只要输出超过一定长度，就必须提供短入口、决策视图、风险视图、行动视图和阅读路径。

⸻

3.1 文档包基本结构

每个长文档型 SKILL 输出不再只是：

xxx.md

而应该至少在文档顶部包含一段控制区：

# <Document Title>
## Brief
## Decision Summary
## Open Questions
## Risks
## Next Actions
## Reading Guide
---
# Full Document

如果是多文档输出，则应该形成文档包：

feature-name/
  00-dashboard.md
  01-decisions.md
  02-open-questions.md
  03-risks.md
  04-next-actions.md
  90-full-document.md

但第一阶段不建议你一下子拆太多文件。
更现实的是：

先统一每个长文档的顶部控制区
再逐步演化为多文件文档包

不然你本来是要减压，结果先造了个文档包管理系统，熟悉的人类自我伤害路线。

⸻

3.2 标准控制区模板

建议所有长文档型 SKILL 统一使用下面结构。

## Brief
用 3～8 条 bullet 说明本文档的核心内容。
- 本文档解决什么问题
- 当前推荐方案是什么
- 最重要的限制是什么
- 是否可以进入下一步
## Decision Summary
| 决策点 | 结论 | 理由 | 影响范围 |
|---|---|---|---|
| ... | ... | ... | ... |
## Open Questions
| 问题 | 当前建议 | 是否阻塞 | 影响 |
|---|---|---|---|
| ... | ... | 是/否 | ... |
## Risks
| 风险 | 严重度 | 影响 | 缓解方式 |
|---|---|---|---|
| ... | 🔴/🟡/🟢 | ... | ... |
## Next Actions
- [ ] ...
- [ ] ...
- [ ] ...
## Reading Guide
| 你的目的 | 应该阅读 |
|---|---|
| 只想判断方向是否正确 | Brief + Decision Summary |
| 准备开始开发 | Next Actions + 实现计划 |
| 准备审查方案 | Risks + Open Questions + 关键设计章节 |
| 遇到实现冲突 | Full Document 对应章节 |
| 想追溯设计原因 | Decision Summary + 方案取舍章节 |

这个控制区要强制放在全文最前面。

原因很简单：

你打开文档后的前 30 秒，必须知道它值不值得继续看

否则文档再完整也是精神负担。

⸻

4. 信息分层模型

建议把所有 DDAi 文档分成 4 层。

⸻

4.1 L1：控制台层

这是你每天最应该看的。

包含：

Brief
Decision Summary
Open Questions
Risks
Next Actions
Change Summary
Review Verdict

目标：

10 秒知道主题
1 分钟知道结论
3 分钟知道风险和待确认项
5 分钟知道下一步

⸻

4.2 L2：执行层

这是准备开发时看的。

包含：

Phase Overview
Execution Order
Issue Breakdown
Acceptance Criteria
Test Requirements
Module README

目标：

知道怎么开始
知道先做什么
知道每一步怎么算完成
知道哪些任务可以交给 AI Coding

⸻

4.3 L3：设计层

这是审查和实现时按需看的。

包含：

架构设计
模块设计
接口契约
数据结构
依赖关系
异常路径
方案取舍

目标：

解决具体设计问题
处理模块边界
支持实现细节

⸻

4.4 L4：归档层

这是很少读，但必须保留的。

包含：

完整 PRD
完整设计推导
历史方案
被否决方案
背景解释
详细审计报告

目标：

未来追溯
设计复盘
AI Coding 深上下文

⸻

5. 各 SKILL 的综合改造建议

5.1 write-a-prd

当前定位

从 0 或新 feature 想法生成 PRD

应保留职责

需求澄清
目标定义
范围定义
用户故事
非目标
关键产品/工程决策

不应承担职责

详细技术设计
完整模块拆分
具体文件改动
完整实现计划

建议改造

在 PRD 顶部增加：

PRD Brief
Decision Summary
Open Questions
Risks
Non-goals
Next Actions

推荐 PRD 结构

# PRD: <Feature Name>
## Brief
## Decision Summary
## Open Questions
## Risks
## Next Actions
## Reading Guide
---
## Problem
## Goals
## Non-goals
## User Stories
## Functional Requirements
## UX / Interaction Requirements
## Implementation Decision Summary
## Acceptance Criteria
## Out of Scope
## Appendix

特别建议

write-a-prd 应该限制追问范围：

只追问影响目标、范围、用户价值、架构边界、执行风险的问题
低风险细节给默认建议，不要反复追问

否则它会变成需求审讯器。你只是想开发功能，不是被 PRD 拷打认罪。

⸻

5.2 prd-to-plan

当前定位

PRD → 分阶段实现计划

适用场景

中小型功能
模块边界不复杂
主要需要知道先做什么、后做什么

应保留职责

阶段拆分
垂直切片
阶段验收标准
阶段依赖
执行顺序

不应承担职责

完整详细设计
模块宇宙拆分
具体代码文件级任务

建议改造

增加：

Plan Brief
Phase Overview
Decision Snapshot
Phase Dependency Map
Execution Order

推荐结构

# Implementation Plan: <Feature Name>
## Plan Brief
## Phase Overview
| Phase | 目标 | 验收方式 | 是否可独立验证 |
|---|---|---|---|
## Decision Snapshot
| 决策 | 结论 | 影响阶段 |
|---|---|---|
## Phase Dependency Map
## Execution Order
## Risks
## Reading Guide
---
## Phase 1: <Name>
### Goal
### Build Scope
### Acceptance Criteria
### Test Requirements
### Not Included
## Phase 2: <Name>
...

核心原则

每个 Phase 必须是：

可验证的一条纵向切片

不要变成：

Phase 1: 数据库
Phase 2: 后端
Phase 3: 前端

那是瀑布开发穿上 AI 外套，没必要。🧥

⸻

5.3 prd-to-modules

当前定位

大 PRD → 模块拆分 → 模块设计 + 模块计划

适用场景

大型功能
多个相对独立能力
模块边界复杂
需要多 agent 并行
模块之间有接口和依赖

最大风险

它会把：

一个长 PRD

变成：

一个 registry
多个 module design
多个 module plan

也就是文档增殖。

建议改造重点

1. 强化 _registry.md

_registry.md 必须成为总控台，而不是普通索引。

推荐结构：

# Modules Registry
## Brief
## Module Overview
| 模块 | 职责 | 类型 | 优先级 | 依赖 | 状态 |
|---|---|---|---|---|---|
## Global Decisions
| 决策 | 结论 | 影响模块 | 理由 |
|---|---|---|---|
## Dependency Graph
## Execution Order
## Cross-module Risks
## Open Questions
## Reading Guide

2. 每个模块增加 README.md

模块目录建议：

<module-name>/
  README.md
  design.md
  plan.md

README.md 是模块入口。

推荐结构：

# Module: <Module Name>
## Brief
## Responsibility
## Inputs / Outputs
## Dependencies
## Provided Interfaces
## Consumed Interfaces
## Key Decisions
## Risks
## When to Read Full Design

3. 模块设计深度分级

不是所有模块都需要完整设计文档。

建议分为：

Core Module
Normal Module
Utility Module

对应设计深度：

Core：完整 design.md，包含方案对比和边界分析
Normal：标准 design.md，保留关键接口和依赖
Utility：轻量 design.md，只写职责、接口、限制

这样不会给每个小工具模块都写传记。螺丝钉不需要自传。🔩

⸻

5.4 prd-to-issues

当前定位

PRD / plan / modules → GitHub/GitLab issues

适用场景

已经准备进入执行
需要把设计拆成可领取任务
需要区分 HITL 和 AFK

应保留职责

生成 issue
垂直切片拆分
依赖标记
HITL / AFK 分类
验收标准

建议改造

创建 issue 前必须生成：

Issue Breakdown Summary

推荐结构：

# Issue Breakdown Summary
## Brief
## Execution Batches
### Batch 1: 可立即开始
- ...
### Batch 2: 依赖 Batch 1
- ...
## Issue Overview
| Issue | 类型 | 优先级 | 批次 | 依赖 | 覆盖用户故事 |
|---|---|---|---|---|---|
## HITL Decisions
| Issue | 需要用户决策 | 影响 |
|---|---|---|
## Risks
## Next Actions

AFK Issue 模板

## Parent PRD
## Type
AFK
## Priority
P0 / P1 / P2
## Build Scope
## Non-goals
## Acceptance Criteria
## Test Requirements
## Blocking Dependencies
## Covered User Stories

HITL Issue 模板

## Parent PRD
## Type
HITL
## Priority
P0 / P1 / P2
## Decision Required
## Background
## Options
## Recommended Option
## Impact
## Issues Unblocked After Decision

核心原则

prd-to-issues 不应该写成散文。
它应该像工作队列生成器，少讲故事，多给结构。

⸻

5.5 audit-design-docs

当前定位

多文档审计、对齐、找矛盾、暴露假设、反向修补

价值判断

这是 DDAi 文档体系里非常重要的质量闸门。

它可以防止：

PRD 说 A
plan 说 B
module design 说 C
issue 最后做 D

软件工程的经典灾难合集，久演不衰。🎭

建议改造重点

1. 新增 00-review-dashboard.md

当前它输出 7 份报告，但缺少一个总入口。

建议增加：

00-review-dashboard.md

推荐结构：

# Review Dashboard
## Review Verdict
PASS / CONDITIONAL PASS / BLOCKED
## Brief
## Top Findings
| 严重度 | 问题 | 影响 | 建议动作 |
|---|---|---|---|
## Decisions Required
| 问题 | 选项 | 推荐 | 是否阻塞 |
|---|---|---|---|
## Auto-fix Summary
| 类型 | 文件 | 修复内容 |
|---|---|---|
## Remaining Risks
## Reading Guide
## Report Index

2. 增加 Review Verdict

建议定义：

PASS：无阻塞问题，无关键待确认项
CONDITIONAL PASS：无阻塞问题，但存在警告或非阻塞待确认项
BLOCKED：存在阻塞问题或关键待确认项

你先看 verdict，就知道能不能继续开发。

3. 收紧自动修补边界

当前自动修补范围略激进。

建议改为：

可自动修：
- 明确引用悬空
- 章节号失效
- 拼写/大小写/命名轻微不一致
- 用户已经明确决策后的文档同步
需确认后修：
- 字段类型不一致
- API 契约变化
- 模型归属变化
- 依赖方向变化
- 结构性设计调整

否则 AI 热心修文档，顺手把真实设计意图修没。很像热心同事，非常危险。

⸻

6. 新增 SKILL 建议：doc-to-dashboard

你现在有生成型、转换型、审计型 SKILL，但缺少一个后处理型 SKILL。

建议新增：

doc-to-dashboard

或者：

summarize-dev-docs

更 DDAi 风一点可以叫：

build-doc-dashboard

⸻

6.1 新 SKILL 定位

输入一份或多份长 Markdown
输出阅读控制台
不改变原文设计
不重新发明方案
只负责压缩、提取、导航、决策聚合

⸻

6.2 使用场景

已有 PRD 太长
已有 plan 太长
已有 module docs 太多
audit 报告太分散
想快速理解一个 feature 的所有文档
准备给 AI Coding 前先看关键点

⸻

6.3 输入

文档路径或目录路径
输出目录
压缩粒度：single-doc / feature-bundle / module-bundle

⸻

6.4 输出

00-dashboard.md
01-decisions.md
02-open-questions.md
03-risks.md
04-next-actions.md
05-reading-guide.md

也可以第一版只输出一个：

00-dashboard.md

不要一开始就产五个文件。我们是来减压的，不是来办文档展览会的。

⸻

6.5 Dashboard 模板

# Document Dashboard: <Name>
## Brief
## What This Document Set Is About
## Current Verdict
READY / NEEDS REVIEW / BLOCKED
## Key Decisions
| 决策 | 结论 | 来源文档 | 影响 |
|---|---|---|---|
## Open Questions
| 问题 | 是否阻塞 | 来源文档 | 建议动作 |
|---|---|---|---|
## Risks
| 风险 | 严重度 | 来源文档 | 缓解方式 |
|---|---|---|---|
## Next Actions
- [ ] ...
## Reading Path
| 目的 | 阅读路径 |
|---|---|
| 快速了解 | ... |
| 准备开发 | ... |
| 准备审查 | ... |
| 排查冲突 | ... |
## Source Documents
| 文档 | 类型 | 作用 |
|---|---|---|
| ... | ... | ... |

⸻

7. 推荐工作流

7.1 小功能工作流

适合：

小插件增强
单点功能
简单 bugfix
明确实现方向

推荐：

write-a-prd
  ↓
prd-to-plan
  ↓
prd-to-issues

可以跳过：

prd-to-modules
audit-design-docs

除非你觉得文档已经开始互相打架。

⸻

7.2 中等功能工作流

适合：

有完整用户流程
有状态变化
有多个边界条件
但模块拆分不复杂

推荐：

write-a-prd
  ↓
prd-to-plan
  ↓
audit-design-docs
  ↓
prd-to-issues

这里 audit 主要用于确保 PRD 和 plan 对齐。

⸻

7.3 大型功能工作流

适合：

多个模块
多 agent 并行
边界复杂
接口较多
长期维护

推荐：

write-a-prd
  ↓
prd-to-modules
  ↓
audit-design-docs
  ↓
prd-to-issues

必要时：

doc-to-dashboard

插在任何阶段后面，用来降低阅读压力。

⸻

7.4 已有想法很明确时

不必强制从 PRD 开始。

可以：

手写 brief
  ↓
prd-to-plan
  ↓
prd-to-issues

或者：

已有 plan
  ↓
prd-to-issues

流程是工具，不是宗教。别拜。🙏

⸻

8. 文档长度治理规则

建议你给所有 SKILL 加一组硬规则。

8.1 长度阈值规则

当输出文档预计超过 1500 字：
必须包含 Brief / Decision Summary / Open Questions / Risks / Next Actions / Reading Guide
当输出文档预计超过 3000 字：
必须在顶部给出章节阅读优先级
当输出多个文件：
必须生成 dashboard 或 registry 作为总入口

⸻

8.2 不允许全文默认阅读规则

在每个长文档 SKILL 中加入：

完整正文用于归档和下钻，不作为默认阅读入口。
必须优先生成可供用户快速判断的控制区。

⸻

8.3 决策集中规则

所有决策必须集中到：

Decision Summary

正文中可以解释，但不能只散落在正文里。

⸻

8.4 未决问题集中规则

所有待用户确认的问题必须集中到：

Open Questions

并标记：

是否阻塞
影响范围
当前建议

⸻

8.5 风险集中规则

所有风险必须集中到：

Risks

并标记：

严重度
影响
缓解方式

⸻

8.6 下一步集中规则

所有行动项必须集中到：

Next Actions

并使用 checkbox。

⸻

9. 建议写进所有 SKILL 的通用片段

你可以把下面这段作为通用规范，加入所有长文档型 SKILL。

## 长文档阅读减压要求
当本技能生成 PRD、设计文档、计划文档、模块文档、审计报告或其他超过 1500 字的 Markdown 文档时，必须在文档正文前生成“阅读控制区”。
阅读控制区必须包含：
1. Brief：用 3～8 条 bullet 总结本文档核心内容
2. Decision Summary：集中列出所有关键决策、结论、理由和影响范围
3. Open Questions：集中列出所有待确认问题，并标记是否阻塞
4. Risks：集中列出风险、严重度、影响和缓解方式
5. Next Actions：列出后续行动项，使用 checkbox
6. Reading Guide：说明不同阅读目的下应该阅读哪些章节
完整正文仍需保留，但完整正文不是默认阅读入口。用户应能通过阅读控制区快速判断：
- 当前文档是否可以进入下一步
- 哪些决策已经确定
- 哪些问题仍需确认
- 哪些风险可能阻塞开发
- 下一步应该做什么

⸻

10. 分阶段落地计划

Phase 1：最小改造，立刻减压

目标：

不大改现有 SKILL，只统一长文档头部

改动：

所有长文档 SKILL 增加阅读控制区
write-a-prd 增加 PRD Brief
prd-to-plan 增加 Phase Overview
prd-to-modules 强化 _registry.md
prd-to-issues 增加 Issue Breakdown Summary
audit-design-docs 增加 Review Dashboard

收益：

打开文档后先看控制区，不再从头硬读

优先级最高。

⸻

Phase 2：新增后处理 SKILL

新增：

doc-to-dashboard

目标：

处理已有长文档和多文档目录

收益：

不用等所有旧 SKILL 都改完
已有文档也能生成阅读入口

⸻

Phase 3：文档包化

开始把复杂产物拆成：

dashboard
decisions
risks
open questions
next actions
full document

但不要对所有功能强制使用。

建议只对：

大型 feature
modules 输出
audit 输出

启用完整文档包。

⸻

Phase 4：自动质量检查

给所有 SKILL 最后增加检查：

是否有 Brief
是否有 Decision Summary
是否有 Open Questions
是否有 Risks
是否有 Next Actions
是否有 Reading Guide

如果缺少，必须补齐。

⸻

11. 最终推荐方案

我建议你不要推翻现有 DDAi SKILL。

你的现有体系价值很高，只需要从：

生成文档

升级为：

生成可阅读、可决策、可执行的文档包

最终目标结构：

每个文档：
  顶部有阅读控制区
  中部是结构化正文
  底部是详细补充
每个文档集合：
  有 dashboard / registry
  有 decisions
  有 risks
  有 open questions
  有 next actions
每个开发阶段：
  小功能用 plan
  大功能用 modules
  执行前用 issues
  复杂文档用 audit
  看不动时用 doc-to-dashboard

⸻

12. 最终一句话

你的问题不是“AI 写太多”。

你的问题是：

AI 写完之后，没有替你把信息分层、建索引、抽决策、标风险、列行动。

所以解决方案是：

保留长文档作为事实底座
强制生成阅读控制区作为默认入口
集中管理决策、风险、未决问题和下一步
用 dashboard / registry 处理多文档集合
新增 doc-to-dashboard 作为后处理减压 SKILL

这样 DDAi 才会从：

Markdown 生产机器

变成：

开发设计信息管理系统

听起来稍微像个中台，但别害怕，它至少是为你一个人服务，不需要开会、不需要汇报、不需要画战略蓝图。已经很慈悲了。📄🧯
