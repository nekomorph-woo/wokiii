---
status: approved

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

> **做什么**：所有 agent 共享的排除约束，声明审查范围之外的事务

## 排除约束

以下约束适用于所有审查 agent 和 simplify agent：

- **DO NOT** 替代 linter（代码风格、格式化、命名风格、import 排序）
- **DO NOT** 替代 type checker（类型语法错误、编译错误）
- **DO NOT** 替代 CI（构建信号、测试运行、部署检查）
- **DO NOT** 做 PR review（不评估变更合理性，只评估代码正确性）
- **DO NOT** 引入第三方依赖或工具
