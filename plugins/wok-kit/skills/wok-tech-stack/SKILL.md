---
name: wok-tech-stack
description: >
  初始化项目技术栈规则。根据用户选择的目标平台（桌面端/移动端/Web端），
  蒸馏技术栈方法论为行为指令，注入 .claude/rules/ 以控制项目技术选型、
  目录结构和迭代节奏。
  Use when 用户要求初始化技术栈规则、选型技术栈、或提到
  "wok-tech-stack" / "技术栈" / "tech stack" / "技术选型"。
pipeline:
  upstream: []
  downstream: []
  gate: false
  output: none
  adaptive: false
---

# 技术栈规则管理

根据目标平台选择，初始化对应技术栈规则。自管理 `stack-*.md` 规则文件，独立于 `wok-refine-rule`。

## 职责

| # | 职责 | 说明 |
|---|------|------|
| 1 | 初始化 | 询问平台目标，蒸馏方法论为规则，注入 `.claude/rules/` |
| 2 | 更新 | 调整平台目标或更新规则内容 |
| 3 | 评估 | 检查规则质量和平台对齐程度 |
| 4 | 移除 | 清理已注入的技术栈规则 |

## 流程

### 0. 判断意图

根据上下文判断意图：初始化 / 更新 / 评估 / 移除。意图不明确时询问用户。

### 1. 初始化

#### 1.1 询问平台目标

使用 AskUserQuestion 询问用户：

**问题 1：目标平台**（multiSelect）

| 选项 | 说明 |
|------|------|
| 桌面端 | macOS / Windows / Linux 原生窗口应用 |
| 移动端 | iOS / Android 移动应用 |
| Web 端 | 浏览器端 Web 应用 |

#### 1.2 生成规则

根据平台选择，将 `reference/` 模板拷贝到 `.claude/rules/`：

| 规则文件 | 条件 |
|----------|------|
| `stack-core.md` | **始终包含** |
| `stack-desktop.md` | 选中桌面端 |
| `stack-mobile.md` | 选中移动端 |
| `stack-web.md` | 选中 Web 端 |
| `stack-monorepo.md` | **选中 2+ 个平台** |

#### 1.3 执行步骤

1. 询问平台目标
2. 逐个检查 `.claude/rules/stack-*.md` 是否存在
3. 不存在 → 拷贝 `reference/` 下对应模板
4. 已存在 → 询问：保留 / 更新 / 查看差异
5. 输出确认清单

确认输出：

```
## ✅ 技术栈规则已初始化

**目标平台**：桌面端 + Web 端

| 规则文件 | 状态 |
|----------|------|
| stack-core.md | ✅ 已创建 |
| stack-desktop.md | ✅ 已创建 |
| stack-web.md | ✅ 已创建 |
| stack-monorepo.md | ✅ 已创建 |

后续所有 wok 管道技能将受技术栈规则约束。
完整方法论参考：reference/methodology-full.md
```

### 2. 更新

触发条件：平台目标变化、技术栈调整、方法论更新。

执行步骤：

1. 询问是否变更平台目标
2. 读取 `reference/methodology-full.md` 获取最新方法论
3. 读取当前 `.claude/rules/stack-*.md`
4. 展示变更差异
5. 用户确认后更新 rules 和 reference 模板

### 3. 评估

检查技术栈规则的质量和平台对齐程度：

| 维度 | 检查内容 |
|------|----------|
| 平台覆盖 | 选中的平台是否都有对应规则 |
| 一致性 | 各端规则是否与 core 原则一致 |
| 可操作性 | 技术选型是否具体可执行 |
| 冲突检查 | 多端规则之间是否有矛盾 |
| 长度控制 | 每个文件 < 100 行 |

### 4. 移除

列出 `.claude/rules/stack-*.md` 文件，用户确认后删除，输出移除确认。

## 参考材料

- [methodology-full.md](reference/methodology-full.md) — 技术栈方法论完整原文
- [stack-core.md](reference/stack-core.md) — 跨端核心原则模板
- [stack-desktop.md](reference/stack-desktop.md) — 桌面端技术栈模板
- [stack-mobile.md](reference/stack-mobile.md) — 移动端技术栈模板
- [stack-web.md](reference/stack-web.md) — Web 端技术栈模板
- [stack-monorepo.md](reference/stack-monorepo.md) — Monorepo 结构模板
