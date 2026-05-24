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

> **做什么**：Stage 0 产出物（上下文包）结构和管道模式双态行为协议

## Stage 0 上下文包

review-engine Stage 0 预检产出统一上下文包，分发给所有 agent：

```yaml
# 必填（所有模式）
files: <string[]>           # 过滤后的变更文件绝对路径列表
language: <string>          # 主语言标识

# 仅管道模式
design_anchors: <string>    # 从 _define.md 提取的设计锚点文本
prd_summary: <string>       # 从 _define.md 提取的目标和验收标准摘要
phase_dir: <string>          # plans/<system-name>/ 的绝对路径

# 仅独立模式
# 以上管道字段为 null/空
```

## 双态行为协议

| 维度 | 管道模式（_define.md 存在） | 独立模式（_define.md 不存在） |
|------|---------------------------|---------------------------|
| 审查基准 | CLAUDE.md + 设计锚点 | 仅 CLAUDE.md |
| 修复方向校验 | 对照 PRD 验证不偏离 | 无校验 |
| 一致性评估 | 必须执行 | 标注"无管道上下文"并跳过 |
| simplify 触发 | 正常触发 | 正常触发 |
| 报告写入 | `<phase-dir>/_review.md` | 当前目录或 `--output` 指定路径 |

## 检测逻辑

1. 查找 `plans/` 目录下的 `_define.md`
2. 存在 → 管道模式，提取设计锚点
3. 不存在 → 独立模式，所有管道专属字段置空
