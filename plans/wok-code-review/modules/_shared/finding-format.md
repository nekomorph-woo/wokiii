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

> **做什么**：标准化 finding 输出格式和空结果哨兵值，供所有 agent 和 report-writer 共用

## Finding 输出格式

每条 finding 严格遵循 3 行纯文本格式：

```
[<severity>] <file>:<line> — <title>
  原因: <why>
  修复方案: <how>
```

**字段规范**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `severity` | `"🔴"` / `"🟠"` / `"🟡"` | 严格使用 emoji 标记，不使用文字 |
| `file` | 相对路径 | 相对于项目根目录 |
| `line` | 正整数 | 行号，文件级问题使用 `file` |
| `title` | 字符串 ≤60 | 简洁描述，不含换行 |
| `原因` | 字符串 | 为什么是问题 |
| `修复方案` | 字符串 | 如何修复，必须具体可执行 |

**扩展字段**（仅部分 agent 使用）：

| 字段 | 适用 agent | 说明 |
|------|-----------|------|
| `优化维度` | code-reviewer, silent-failure-hunter | 标记可由 simplify 处理的维度 |
| `来源` | 所有 agent | 发现此问题的 agent 名 |

**finding 之间空一行**。

## 空结果哨兵值

所有 agent 在无 finding 时统一输出：

```
[OK] 无问题
```
