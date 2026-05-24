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
    modules/silent-failure-hunter/design.md: d39ca685ebec29a9e8ec0f71554da11a359da0b8
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

### [DECISION] 按失败模式而非语言组织审查清单

**选择**：6 个失败模式类别 + 语言特定规则作为补充
**否决**：按语言分章节组织——相同失败模式在不同语言中重复定义
**理由**：错误处理的本质是失败模式，语言只是表象。按模式组织使 agent prompt 结构清晰
**影响**：主清单语言无关，语言特定规则作为附录

### [DECISION] 严重度升级条件机制

**选择**：基础严重度 + 上下文升级条件
**否决**：预定义完整严重度决策树——上下文组合爆炸
**理由**：静态规则无法覆盖所有上下文。基础严重度覆盖 80% 场景，升级条件覆盖高危模式
**影响**：agent 有一定裁量权，但升级条件是硬规则

### [DECISION] 不检测合理的错误边界

**选择**：审查清单明确排除已知的合理错误边界模式
**否决**：全量报告所有 catch 块——噪音过高
**理由**：区分"有意降级"和"无意吞没"是审查核心价值
**影响**：agent 需识别降级意图信号：注释说明、日志级别 warn 以上、fallback 有监控标记

### [DECISION] 修复方案要求可执行

**选择**：finding 的修复方案必须包含具体代码片段或明确操作步骤
**否决**：仅描述问题方向
**理由**：review-engine Stage 3 自动修复依赖修复方案的可操作性
**影响**：agent 输出稍长，但 Stage 3 修复成功率更高

### [DECISION] 资源泄漏按循环上下文升级

**选择**：资源泄漏基础 🟠，循环内发生时升级为 🔴
**否决**：统一 🟠——掩盖循环内累积效应
**理由**：单次泄漏进程退出后自动回收，循环内每次迭代泄漏在 N 次迭代后资源耗尽
**影响**：agent 需识别 catch 块的循环上下文
