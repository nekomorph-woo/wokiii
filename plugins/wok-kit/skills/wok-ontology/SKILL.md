---
name: wok-ontology
description: >
  初始化和管理本体论驱动的软件开发方法论规则。将方法论蒸馏为阶段性行为指令，
  注入 .claude/rules/ 以影响 wok 管道技能的需求、设计、实现风格。
  Use when 用户要求初始化本体论规则、更新本体论指令、评估本体论规则质量，
  或提到 "wok-ontology" / "本体论" / "ontology" / "对象驱动"。
pipeline:
  upstream: []
  downstream: []
  gate: false
  output: none
  adaptive: false
---

# 本体论规则管理

初始化、更新、评估、移除本体论驱动的软件开发方法论规则。自管理 `ontology-*.md` 规则文件，独立于 `wok-refine-rule`。

## 职责

| # | 职责 | 说明 |
|---|------|------|
| 1 | 初始化 | 蒸馏方法论为阶段指令，注入 `.claude/rules/` |
| 2 | 更新 | 重新蒸馏或调整规则内容 |
| 3 | 评估 | 检查规则质量和管道对齐程度 |
| 4 | 移除 | 清理已注入的本体论规则 |

## 流程

### 0. 判断意图

根据上下文判断意图：初始化 / 更新 / 评估 / 移除。意图不明确时询问用户。

### 1. 初始化

将蒸馏后的规则模板从 `reference/` 拷贝到 `.claude/rules/`：

| 源文件 | 目标文件 |
|--------|----------|
| `reference/ontology-core.md` | `.claude/rules/ontology-core.md` |
| `reference/ontology-define.md` | `.claude/rules/ontology-define.md` |
| `reference/ontology-design.md` | `.claude/rules/ontology-design.md` |
| `reference/ontology-implement.md` | `.claude/rules/ontology-implement.md` |

执行步骤：

1. 逐个检查 `.claude/rules/ontology-*.md` 是否存在
2. 不存在 → 拷贝 `reference/` 下对应模板
3. 已存在 → 询问：保留 / 更新 / 查看差异
4. 输出确认清单

确认输出：

```
## ✅ 本体论规则已初始化

| 规则文件 | 状态 |
|----------|------|
| ontology-core.md | ✅ 已创建 |
| ontology-define.md | ✅ 已创建 |
| ontology-design.md | ✅ 已创建 |
| ontology-implement.md | ✅ 已创建 |

后续所有 wok 管道技能将自动受本体论规则影响。
完整方法论参考：reference/methodology-full.md
```

### 2. 更新

触发条件：方法论原文更新、管道技能结构变化、用户要求调整特定阶段指令。

执行步骤：

1. 读取 `reference/methodology-full.md` 获取最新方法论
2. 读取当前 `.claude/rules/ontology-*.md` 获取当前规则
3. 识别需要更新的部分
4. 展示变更差异
5. 用户确认后更新 rules 和 reference 模板（保持双向同步）

### 3. 评估

检查本体论规则的质量和对管道的对齐程度：

| 维度 | 检查内容 |
|------|----------|
| 完整性 | 六大概念（Entity/Attribute/Relation/Action/Constraint/State）是否在规则中体现 |
| 可操作性 | 指令是否具体可执行，不是抽象描述 |
| 阶段覆盖 | define/design/implement 是否都有对应指令 |
| 冲突检查 | 规则之间是否有矛盾 |
| 长度控制 | 每个文件 < 120 行 |

### 4. 移除

列出 `.claude/rules/ontology-*.md` 文件，用户确认后删除，输出移除确认。

## 参考材料

- [methodology-full.md](reference/methodology-full.md) — 本体论方法论完整原文（1944 行）
- [ontology-core.md](reference/ontology-core.md) — 核心原则规则模板
- [ontology-define.md](reference/ontology-define.md) — 需求定义阶段规则模板
- [ontology-design.md](reference/ontology-design.md) — 模块设计阶段规则模板
- [ontology-implement.md](reference/ontology-implement.md) — 实现阶段规则模板
