---
status: draft
intent: reference
scope: global
depends: [req:wok-code-review]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    _define.md: 2d3e67c5f43dd564091816351e3fc0af2486515b
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **模块数**：9 个
> **依赖方向**：review-engine → 5 agents + simplify + report-writer；review-engine → wok-cr-insight（Stage 5）
> **阻塞**：无

## 模块概览

| 模块 | 职责 | 类型 | 依赖 | 模型 |
|------|------|------|------|------|
| review-engine | 审查编排引擎，5 阶段管道 | skill 命令 | 5 agents, simplify, report-writer | — |
| code-reviewer | CLAUDE.md 合规 + bug 检测 | agent | — | Sonnet |
| comment-analyzer | 注释准确性审查 | agent | — | Sonnet |
| silent-failure-hunter | 静默失败/错误处理 | agent | — | Sonnet |
| type-design-analyzer | 类型设计质量 | agent | — | Sonnet |
| pr-test-analyzer | 测试覆盖率 | agent | — | Sonnet |
| simplify | 代码简化优化 | agent + skill | — | Opus |
| report-writer | `_review.md` 单文件管理 | 内部模块 | — | — |
| cr-insight | 🟡 问题分析与方案 | skill 命令 | — | — |

## 依赖图

```
                        ┌──────────────┐
                        │ review-engine │
                        │   (skill)     │
                        └──┬──┬──┬──┬──┬┘
                           │  │  │  │  │
              ┌────────────┘  │  │  │  └────────────┐
              │               │  │  │                 │
   ┌──────────▼──┐  ┌───────▼┐│┌▼────────┐  ┌──────▼───┐  ┌──────────┐
   │code-reviewer│  │comment- │││silent-  │  │type-design│  │pr-test-  │
   │             │  │analyzer │││failure- │  │analyzer  │  │analyzer  │
   └─────────────┘  └─────────┘│hunter  │  └──────────┘  └──────────┘
                                └────────┘
              │
   ┌──────────▼──┐      ┌──────────────┐
   │  simplify   │      │ report-writer │
   │ (Opus)      │      │ (内部模块)    │
   └─────────────┘      └───────┬──────┘
                               │
                        ┌──────▼──────┐
                        │ _review.md  │
                        └──────┬──────┘
                               │
                        ┌──────▼──────┐
                        │  cr-insight  │
                        │ (独立插件)   │
                        └─────────────┘
```

## 共享依赖

所有 agent 依赖 `_shared/` 下的公共产物：

- [finding-format.md](../_shared/finding-format.md) — 标准化 finding 输出格式
- [severity-guide.md](../_shared/severity-guide.md) — 三级严重度定义和升降级规则
- [agent-constraints.md](../_shared/agent-constraints.md) — 排除约束（不替代 linter/CI/PR review）
- [pipeline-context.md](../_shared/pipeline-context.md) — Stage 0 上下文包结构和双态行为协议

## 插件映射

| 插件 | 包含模块 | 命令入口 |
|------|----------|----------|
| `wok-code-review` | review-engine + 5 agents + simplify + report-writer | `/wok-code-review`, `/wok-simplify` |
| `wok-cr-insight` | cr-insight | `/wok-cr-insight` |
| `wok-dashboard`（修改） | dashboard-integration | 增量修改现有渲染逻辑 |

## 持久架构决策

| 设计锚点 | 架构决策 | 影响模块 | 兼容性 |
|----------|----------|----------|--------|
| [EFFECT] 审查必须嵌入实现循环 | review-engine 的 pipeline.upstream: [wok-implement]，每轮 implement 后自动触发 | review-engine | 与现有 wok-implement 无侵入性修改，仅追加下游节点 |
| [EFFECT] 🔴🟠 必须自动修复并追加验证 | Stage 3 修复-验证循环，max-rounds 硬上限 | review-engine, 5 agents | 新增行为，无兼容性问题 |
| [EFFECT] 审计报告单文件按轮次分区 | report-writer 覆写+追加策略 | report-writer | 无兼容性影响 |
| [SECURITY] 自动修复不得偏离 PRD | Stage 0 管道上下文感知，修复前对照设计锚点校验 | review-engine, pipeline-context.md | 依赖 plans/ 目录结构，与现有管道兼容 |
| [NECESSITY] 每个 agent 必须可独立调用 | 所有 agent 定义独立输入解析逻辑 | 5 agents, simplify | 无兼容性影响 |
| [NECESSITY] 管道终点执行全分支审查 | 调用方使用 `--scope branch` 触发 | review-engine | 无兼容性影响 |
| [EXCLUSION] 不做 PR review，不替代 CI/linter | agent-constraints.md 共享排除声明 | 所有模块 | 与现有非目标一致 |
