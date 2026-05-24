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
    modules/review-engine/design.md: d6067a367f27664c8178436edbaaedb674d5eb70
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：4 条
> **设计锚点覆盖**：全部覆盖
> **未覆盖锚点**：无

## 决策

### [DECISION] 单命令入口 + 参数化控制

**选择**：1 个 `/wok-code-review` 命令 + 4 个可选参数（`--scope`, `--focus`, `--max-rounds`, `--no-fix`）
**否决**：4 个快捷入口方案（`/wok-review-bugs` 等）——增加维护成本，新增 agent 时需同步更新映射，实际使用频率低
**理由**：wok 管道的用户是开发者，能理解参数。快捷入口的"零学习成本"收益不抵维护成本
**影响**：简化插件结构，commands/ 目录只需 1 个文件 + 1 个 simplify 快捷命令

### [DECISION] 管道上下文感知（auto-detect）

**选择**：启动时自动检测 `plans/` 目录和 `_define.md`，管道模式下注入 PRD 设计锚点作为审查基准
**否决**：纯参数化方案——审查范围和 PRD 引用全靠用户手动指定
**理由**：直接响应 `[SECURITY] 自动修复不得偏离 PRD 和设计目标` 锚点。管道模式下自动获取上下文，用户无需重复提供；独立模式下退化为纯代码语义审查，不假装有设计上下文
**影响**：Stage 0 预检增加了目录检测逻辑，但隐藏在 prompt 内部，用户无感知

### [DECISION] 多阶段管道架构

**选择**：5 阶段流水线（预检 → 并行审查 → 聚合分级 → 修复验证 → 报告写入 + 洞见生成）
**否决**：单轮审查无循环方案——发现问题但不修复，全靠用户处理
**理由**：直接响应 `[EFFECT] 🔴🟠 必须自动修复，修复后必须追加验证` 锚点。多阶段架构参考官方 code-review 的分层设计（Haiku 预检 → Sonnet 并行 → 过滤 → 输出），但用"修复-验证循环"替代"评分过滤"，主动消除问题而非被动丢弃
**影响**：每轮审查启动 5 个 Sonnet agent，加上修复验证循环，token 消耗是单次审查的 5-15 倍。通过 max-rounds 硬上限和 Stage 0 预检过滤控制成本

### [DECISION] 独立 simplify skill 暴露

**选择**：simplify agent 定义在 wok-code-review 插件内，同时暴露 `/wok-simplify` 独立 skill 命令
**否决**：simplify 作为独立插件 wok-simplify——增加插件间耦合
**理由**：grill-me 决策 4 的结论。一份 agent 定义，两种调用方式。管道内由 review-engine 内部触发，独立使用时通过 `/wok-simplify` 命令直接调用
**影响**：wok-code-review 插件的 commands/ 目录有 2 个文件（wok-code-review.md + wok-simplify.md）
