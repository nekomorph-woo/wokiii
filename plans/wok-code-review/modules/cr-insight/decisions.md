---
status: draft
intent: explanation
scope: affected-modules
depends: [req:wok-code-review]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    modules/cr-insight/design.md: 7dd15a490714fdfc8baf5e58d8362443eda4b7dd
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：4 条
> **设计锚点覆盖**：US-3, US-5
> **未覆盖锚点**：无直接锚点，作为 review-engine 下游间接满足

## 决策

### [DECISION] 原地追加而非独立报告

**选择**：在 `_review.md` 每个问题下方直接追加分析区块
**否决**：独立产出 `_insight.md`
**理由**：US-3 要求"在问题下方追加"，强调上下文连贯性。独立文件破坏连贯性，与 US-6 单文件原则冲突
**影响**：需精确文本插入定位，每次追加检测幂等性

### [DECISION] 幂等设计

**选择**：通过检测 `🔍 原因分析` 区块判断是否已分析
**否决**：每次全量覆写
**理由**：review-engine 修复-验证循环可能多次触发 Stage 5，不幂等会导致同一问题累积多份分析
**影响**：追加内容必须严格使用固定标题格式

### [DECISION] 管道上下文感知

**选择**：自动检测设计文档存在性，有则执行一致性评估，无则标注跳过
**否决**：始终要求或始终跳过
**理由**：双场景（管道+独立）输入差异决定输出必须条件化。与 `[SECURITY] 自动修复不得偏离 PRD` 锚点关联
**影响**：实现需增加文件存在性检测

### [DECISION] 只读源码 + 只写报告

**选择**：仅读取源码，仅修改 `_review.md`
**否决**：分析时同时修改源码
**理由**：🟡 问题不自动修复（US-3），cr-insight 是分析型工具。修改代码是 review-engine 的职责
**影响**：实现简单——只需 Read + Edit 两个工具
