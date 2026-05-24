---
status: approved

intent: reference
scope: module
depends: [req:wok-code-review, mod:review-engine]
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

> **做什么**：类型设计质量审查，检测类型安全、any 滥用、类型断言风险、泛型使用、接口契约一致性、不可变状态违规
> **接口数**：1 个 agent prompt
> **模型**：Sonnet
> **阻塞**：无

## 接口契约

<details>
<summary>agent: type-design-analyzer</summary>

### 输入

| 字段 | 类型 | 说明 |
|------|------|------|
| `files` | `string[]` | 待审查文件路径列表 |
| `context` | `string \| null` | 管道模式下为 `_define.md` 摘要；独立模式下为 null |

### 输出

标准化 finding 列表：

```
[<severity>] <file>:<line> — <title>
  原因: <why>
  修复方案: <how>
  优化维度: <simplify 触发标记>（可选）
```

无 finding 时输出：`[OK] 无问题`

</details>

## 审查标准清单

### C1: any 滥用检测

| 检查项 | 严重程度 |
|--------|----------|
| 显式 `: any` | 🟡 |
| 隐式 any（noImplicitAny） | 🟠 |
| `as any` 类型断言 | 🟠 |
| `@ts-ignore` / `@ts-expect-error` | 🟠 |
| `any[]` 数组类型 | 🟡 |

### C2: 类型断言风险

| 检查项 | 严重程度 |
|--------|----------|
| 双重断言 `as unknown as T` | 🟠 |
| 不安全断言缺乏 guard | 🟠 |
| 断言链 `x as A as B` | 🟡 |
| `JSON.parse(str) as T` 无运行时验证 | 🟠 |

### C3: 泛型使用

| 检查项 | 严重程度 |
|--------|----------|
| 泛型参数未使用 | 🟡 |
| 泛型约束过宽/过窄 | 🟠/🟡 |
| 泛型推断失败点 | 🟡 |

### C4: 接口契约一致性

| 检查项 | 严重程度 |
|--------|----------|
| 接口定义与实现不匹配 | 🔴 |
| 可选属性滥用 | 🟡 |
| 联合类型过宽（>3 分支） | 🟡 |

### C5: 不可变状态违规

| 检查项 | 严重程度 |
|--------|----------|
| 可变默认参数 | 🟠 |
| readonly 缺失于应不可变数据 | 🟡 |
| 展开运算符用于深层嵌套 | 🟠 |

### C6: 类型导入与导出

| 检查项 | 严重程度 |
|--------|----------|
| value import 替代 type import | 🟡 |
| barrel 导出未隔离类型 | 🟡 |

### C7: 判别联合与穷尽检查

| 检查项 | 严重程度 |
|--------|----------|
| switch/if-else 缺少 default | 🟠 |
| 判别属性不一致 | 🔴 |
| 类型收窄后冗余检查 | 🟡 |

## 实现约束

- DO NOT 检查代码风格（linter 职责）
- DO NOT 检查业务逻辑正确性（code-reviewer 职责）
- DO NOT 替代 TypeScript 编译器类型检查
- 审查范围限定于变更文件
- 非类型化语言降级为 🟡 Advisory
- 每条 finding 的修复方案必须具体到代码级别
