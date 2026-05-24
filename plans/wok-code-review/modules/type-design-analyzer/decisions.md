---
status: draft
intent: explanation
scope: module
depends: [req:wok-code-review, mod:review-engine]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    modules/type-design-analyzer/design.md: 06bb51628aad9023d0b7d15622252f5ab60268e0
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：5 条
> **设计锚点覆盖**：[NECESSITY] 每个 review agent 必须可独立调用
> **未覆盖锚点**：无

## 决策

### [DECISION] 7 维度审查清单结构

**选择**：7 个正交维度（C1~C7）覆盖 any 滥用、类型断言、泛型、接口契约、不可变状态、类型导入、判别联合
**否决**：单一"类型质量"粗粒度审查——检查项过多时容易遗漏
**理由**：TypeScript 类型系统问题可明确归类为 7 个维度，分离后更精准
**影响**：清单较长（~25 项），但每项有明确触发条件和分级标准

### [DECISION] 三级严重度与编译器 strict 模式对齐

**选择**：🔴 限运行时崩溃，🟠 对齐编译器 strict 模式报错，🟡 为编译通过但设计可改进
**否决**：所有类型问题统一为 Advisory
**理由**：响应 `[EFFECT] 🔴🟠 必须自动修复` 锚点
**影响**：大部分落在 🟡，🟠 和 🔴 是少数但关键的目标

### [DECISION] JSON.parse 后断言为 🟠

**选择**：`JSON.parse(str) as T` 标记为 🟠
**否决**：标记为 🔴——实际场景中数据来源可信时不一定崩溃
**理由**：🟠 触发自动修复但不阻塞管道
**影响**：修复方案推荐引入运行时验证库

### [DECISION] 非类型化语言降级策略

**选择**：纯 JS 仅审查 JSDoc 和隐式 any，全部 🟡
**否决**：跳过 JS 文件——留下审查盲区
**理由**：保持覆盖，但避免触发不必要的自动修复
**影响**：JS 文件 finding 数量通常少于 TS

### [DECISION] 修复方案必须到达代码级别

**选择**：每条 finding 的修复方案必须包含具体代码片段
**否决**：仅输出问题描述
**理由**：Stage 3 自动修复需要可执行的方案
**影响**：agent 输出偏长，但每条可独立执行
