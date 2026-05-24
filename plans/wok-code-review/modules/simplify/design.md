---
status: approved

intent: reference
scope: affected-modules
depends: [req:wok-code-review]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    _define.md: 2d3e67c5f43dd564091816351e3fc0af2486515b
    modules/_registry.md: b95b3afc3c469d1acc56b53593b99eef065ccd7d
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **做什么**：代码简化优化 agent，检测并修复臃肿代码、过度防御、嵌套过深、重复代码、冗余逻辑
> **接口数**：1 个 skill 命令 + 1 个管道内部调用接口
> **阻塞**：无

## 接口契约

<details>
<summary>/wok-simplify [--target <目标>] [--dimensions <维度>]</summary>

### 参数

| 参数 | 格式 | 默认值 | 说明 |
|------|------|--------|------|
| `--target` | 文件路径 / 目录 / `all` | 无（必填） | 优化目标 |
| `--dimensions` | 逗号分隔的维度名 | 全部 7 个 | 仅启用指定维度 |

### 调用方式

```
/wok-simplify --target src/auth/handler.ts
/wok-simplify --target src/auth/ --dimensions nesting
/wok-simplify --target all
```

### 返回值

直接修改目标文件，不产出独立报告。独立调用时输出变更摘要。

</details>

<details>
<summary>管道内部调用接口（review-engine → simplify）</summary>

### 输入

| 字段 | 类型 | 说明 |
|------|------|------|
| `target` | 文件路径 | 已修复的文件路径（单文件） |
| `dimensions` | 逗号分隔 | 来自 finding 的 `优化维度` 标记 |

### 输出

管道内调用时静默修改代码，不输出变更摘要。

### 触发条件

- finding 中 `优化维度` 字段非空时触发
- `--no-fix` 模式下同步跳过

</details>

## 简化标准清单

### D1: 嵌套深度（nesting）

**检测**：if/for/while/try/switch 嵌套超过 3 层

**修复**：提取子函数、guard clause、可选链替代嵌套 null 检查

**约束**：DO NOT 改变公开签名；提取的函数名必须表达语义

### D2: 过度防御（over-guard）

**检测**：类型系统已覆盖的运行时检查、不可达分支处理、冗余守卫

**修复**：移除冗余检查

**约束**：保留外部输入边界检查；保留有副作用的验证逻辑

### D3: 重复代码（duplication）

**检测**：3+ 位置相同代码片段（>5 行）、可提取函数的重复表达式

**修复**：提取共享函数、参数化差异、映射表替代 switch

**约束**：DO NOT 跨模块提取；DO NOT 为消除重复引入过度抽象

### D4: 冗余逻辑（redundancy）

**检测**：死代码、冗余条件、冗余变量、冗余集合操作

**修复**：移除死代码、简化布尔表达式、内联单次使用变量

**约束**：DO NOT 移除被外部引用的导出；DO NOT 移除带 @deprecated 的维护期代码

### D5: 过度工程化（over-engineering）

**检测**：仅一处使用的泛型/策略模式、无证据的性能优化、过度配置化

**修复**：内联单处抽象、移除无证据优化、常量替代配置

**约束**：保留标注"预留扩展"的抽象；保留公共 API 接口

### D6: 冗长表达（verbosity）

**检测**：可用解构/模板字符串/可选链替代的多步操作、过长链式调用（>5 层）

**修复**：应用语言惯用语法、引入语义中间变量

**约束**：仅使用主流版本特性；变量命名必须表达语义

### D7: 函数复杂度（complexity）

**检测**：函数超 50 行、参数超 4 个、圈复杂度超 10

**修复**：按职责拆分函数、参数对象化、IO 与逻辑分离

**约束**：DO NOT 改变公开签名；保持执行顺序语义

## 执行流程

### 独立调用

解析 target → 逐文件扫描 → 识别简化点 → 修复（遵守约束） → 写回 → 输出摘要

### 管道内调用

接收文件+维度 → 扫描 → 修复 → 写回 → 静默返回

## 实现约束

- 使用 Opus 模型（需要深度语义判断简化安全性）
- 直接修改代码，DO NOT 产出独立报告
- 管道内调用时 DO NOT 输出变更摘要
- 每个 simplify 操作必须语义保持
- DO NOT 替代 linter 或 typechecker
- 语义变更风险时跳过并记录原因
- simplify 无 `--no-fix` 参数——管道模式下是否触发由 review-engine 的 `--no-fix` 控制，独立调用时始终执行简化
