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
    modules/report-writer/design.md: 7cf55921eee4bd338c815c1f6d271533678c5a81
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：4 条
> **设计锚点覆盖**：[EFFECT] 审计报告单文件按轮次分区
> **未覆盖锚点**：无

## 决策

### [DECISION] 单文件 + 轮次分区覆写策略

**选择**：一个 `_review.md`，当前轮次覆写、历史轮次向下追加
**否决**：每轮一个文件（分散信息）或纯追加模式（无法表达修复后状态转移）
**理由**：响应 `[EFFECT] 审计报告必须单文件按轮次分区` 锚点。单文件降低认知负载，覆写+追加支持当前状态更新和历史保留
**影响**：写入逻辑需处理文件解析和分区定位，但报告始终自包含

### [DECISION] 🟡 严格去重：仅首次发现写入

**选择**：`file:line + title` 作为去重键，仅首次出现写入 Open
**否决**：每轮都写入（噪音过高）或首次写入后删除（丢失持续信号）
**理由**：响应 US-3 和 US-6
**影响**：需维护已报告 🟡 集合，来源有解析已有 Open 区和调用方传入的 new/unchanged 区分

### [DECISION] 已修复问题使用 severity→✅ 标记

**选择**：修复后的 🔴🟠 以 `[severity→✅]` 格式写入 Resolved 区
**否决**：直接删除（丢失审计记录）
**理由**：Resolved 区提供审计可追溯性。`severity→✅` 让读者一眼看出原始级别和当前状态
**影响**：Resolved 区可能较长，但这是有意的——审计报告价值在于可追溯

### [DECISION] 内部模块协议化，无独立入口

**选择**：通过 review-engine Stage 4 的 prompt 协议调用，不暴露独立命令
**否决**：独立 skill 命令
**理由**：report-writer 的输入只能由 review-engine 产出。与 simplify 不同——simplify 有明确独立使用场景
**影响**：不生成 commands/ 文件，接口契约完全定义在 design.md
