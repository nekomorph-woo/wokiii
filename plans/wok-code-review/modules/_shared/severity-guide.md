---
status: draft
intent: reference
scope: global
depends: []
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

> **做什么**：三级严重度定义、分级原则和模块级升级/降级规则

## 三级定义

| 级别 | 标记 | 含义 | 默认行为 |
|------|------|------|----------|
| 🔴 Blocking | 功能中断/数据丢失/安全漏洞 | 自动修复 + 阻塞管道 |
| 🟠 Severe | 影响功能但有降级路径 | 自动修复，失败升级用户确认 |
| 🟡 Advisory | 代码质量/可维护性/优化建议 | 不自动修复，写入报告 |

## 分级原则

- 能否正常运行 → 不能 = 🔴，勉强能但风险 = 🟠，能运行但不规范 = 🟡
- 数据安全相关 → 一律 🔴
- 安全规范（密钥泄露等）相关 → 一律 🔴

## 模块级升降级规则

| 模块 | 升级条件 | 降级条件 |
|------|----------|----------|
| code-reviewer | 安全规范相关 → 🔴 | — |
| comment-analyzer | 误导性 API 文档 → 🔴；内部注释矛盾 → 🟠 | — |
| silent-failure-hunter | 涉及资源获取 → 🔴；循环内发生 → 🔴；安全敏感操作 → 🔴 | 有意降级策略（有监控/注释）→ 🟡 |
| type-design-analyzer | 接口契约不匹配 → 🔴；判别属性不一致 → 🔴 | 非类型化语言 → 全部 🟡 |
| pr-test-analyzer | 主逻辑/状态变更无测试 → 🔴 | 无测试文件 → 单条 🟠 |
