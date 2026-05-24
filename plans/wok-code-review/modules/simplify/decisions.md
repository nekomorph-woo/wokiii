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
    modules/simplify/design.md: 9391b2d729ad6f1b14b17e83de7bec60f874df57
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：5 条
> **设计锚点覆盖**：[EFFECT] simplify 不产出独立报告、[NECESSITY] 可独立调用
> **未覆盖锚点**：无

## 决策

### [DECISION] 内嵌插件 + 独立命令暴露

**选择**：simplify agent 定义在 wok-code-review 插件内，暴露 `/wok-simplify` 独立命令
**否决**：独立插件 wok-simplify 或纯内部 agent
**理由**：一份 agent 定义，两种调用路径。减少插件间耦合，满足独立使用需求
**影响**：commands/ 目录含 2 个文件（wok-code-review.md + wok-simplify.md）

### [DECISION] 7 维度简化标准体系

**选择**：7 个独立维度（nesting / over-guard / duplication / redundancy / over-engineering / verbosity / complexity）
**否决**：单一维度或 20+ 细分维度
**理由**：与 _define.md 中提到的优化场景对齐，每个维度有明确边界约束
**影响**：review agent 通过 `优化维度` 字段标记触发维度

### [DECISION] Opus 模型而非 Sonnet

**选择**：simplify 使用 Opus
**否决**：与审查 agent 一致使用 Sonnet
**理由**：simplify 直接修改代码，需要深度语义判断简化安全性。Opus 在代码重构任务上准确率更高
**影响**：每轮迭代增加 1-2 次 Opus 调用，但 per-file 触发且频次低

### [DECISION] 双模式输出（静默 vs 摘要）

**选择**：管道内静默，独立调用输出摘要
**否决**：始终输出摘要
**理由**：响应"不产出独立报告"非目标约束
**影响**：通过检测管道上下文切换输出行为

### [DECISION] 边界约束优先于简化覆盖率

**选择**：遇到语义风险时跳过而非强行简化
**否决**：最大化覆盖率
**理由**：错误修改代价远高于遗漏优化
**影响**：部分可简化代码可能被跳过，但这是有意的安全取舍
