# 路线图输出格式

## 目录结构

```
wok-plans/<system-name>/
├── _roadmap.md                    ← 本文件
├── p1-<phase-name>/              ← 后续各 phase 管道循环在此创建
└── p2-<phase-name>/
```

## _roadmap.md 模板

```markdown
---
status: draft
intent: decision
scope: global
depends: []
changed: 初始版本
---

> **做什么**：规划 <项目> 的功能路线图
> **怎么做**：双轨探索（发散+侦察）→ 精选 → 版本化分组
> **阻塞**：无

## 项目上下文

<1-2 句项目描述>

## 发现的 Feature

<全部发现的 feature 列表，标注来源和复杂度>

## 精选 Feature

### [DECISION] <feature 名称>

优先级：<P0/P1/P2>
依赖：<无 / 依赖的其他 feature>

## 路线图

### p1-<phase-name> — <主题>

目标：<端到端能力描述>
模块预估：<N> 个

...

### p2-<phase-name> — <主题>
...
```

## 验证门输出

确认路线图后展示：

```
## ✅ 验证门

**产出**：<项目> 功能路线图，<N> 个 phase，<M> 个精选 feature
**决策**：<关键分组决策>
**阻塞**：无
**下一步**：确认后创建 `wok-plans/<system-name>/p1-<phase-name>/` 目录，对 Phase 1 执行 /wok-define
```
