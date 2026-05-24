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

> **做什么**：静默失败与错误处理审查 agent，检测吞没异常、空 catch 块、缺失错误传播、资源泄漏、不当 fallback
> **接口数**：1 个 agent prompt
> **模型**：Sonnet
> **阻塞**：无

## 接口契约

<details>
<summary>agent: silent-failure-hunter</summary>

### 输入

| 字段 | 类型 | 说明 |
|------|------|------|
| `files` | `string[]` | 待审查文件路径列表 |
| `context` | `string?` | 管道模式下注入的设计锚点摘要 |
| `language` | `string` | 主语言标识，用于选择语言特定规则 |

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

### 1. 空 catch 块

| 模式 | 检测目标 | 严重度基准 |
|------|----------|------------|
| `catch {}` / `except: pass` | 完全忽略异常 | 🟠 |
| `catch (e) {}` 后无操作 | 捕获但丢弃 | 🟠 |
| finally 为空 | 缺少清理逻辑 | 🟡 |

升级条件：catch 块涉及资源获取（文件句柄、网络连接、数据库连接、锁）→ 🔴

### 2. 吞没异常

| 模式 | 检测目标 | 严重度基准 |
|------|----------|------------|
| catch 内仅 console.log | 记录但不传播 | 🟡 |
| catch 内返回默认值未记录 | 调用方无法感知失败 | 🟠 |
| catch 内注释"ignore" | 显式抑制错误信号 | 🟡 |

升级条件：安全敏感操作（认证、授权、加密、输入校验）→ 🔴

### 3. 缺失错误传播

| 模式 | 检测目标 | 严重度基准 |
|------|----------|------------|
| 函数签名声明返回错误但内部 catch 后不 re-throw | 调用方误以为成功 | 🟠 |
| Promise/async 吞没 rejection | 链式调用方无法捕获 | 🟠 |
| callback 未传递 error 参数 | 错误丢失 | 🟠 |

升级条件：后续逻辑基于错误状态继续执行 → 🔴

### 4. 资源泄漏

| 模式 | 检测目标 | 严重度基准 |
|------|----------|------------|
| 文件/流未在 finally 或 using/with 中关闭 | 句柄泄漏 | 🟠 |
| HTTP 连接未显式关闭或使用连接池 | 连接耗尽风险 | 🟠 |
| 数据库连接/事务未在异常路径中回滚 | 连接池耗尽 | 🔴 |
| 临时文件创建后未清理 | 磁盘空间泄漏 | 🟡 |

升级条件：循环内发生 → 🔴

### 5. 不当 fallback

| 模式 | 检测目标 | 严重度基准 |
|------|----------|------------|
| 解析失败 fallback 到硬编码值 | 掩盖配置/数据问题 | 🟠 |
| API 调用失败返回缓存未标记陈旧 | 调用方误以为数据新鲜 | 🟠 |
| 类型转换失败 fallback 到零值/null | 静默数据丢失 | 🟡 |
| 主路径失败 fallback 未记录失败原因 | 排查困难 | 🟡 |

### 6. 静默 continue/break

| 模式 | 检测目标 | 严重度基准 |
|------|----------|------------|
| 循环内 try-catch 包含 continue | 批量操作部分静默失败 | 🟠 |
| early return 后未释放已获取资源 | 部分资源泄漏 | 🟠 |

升级条件：导致数据不一致 → 🔴

## 实现约束

- 仅审查 `--scope` 指定的文件范围
- 每条 finding 必须包含具体 `file:line`
- 修复方案必须可执行
- DO NOT 检测 linter 覆盖的问题
- DO NOT 对合理的错误边界处理报 finding
