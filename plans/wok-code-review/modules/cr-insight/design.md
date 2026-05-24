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

> **做什么**：读取 `_review.md` 中的 🟡 Advisory 问题，在每个问题下方追加原因分析、修改方案和一致性评估
> **接口数**：1 个 skill 命令
> **阻塞**：依赖 `_review.md` 存在且包含 🟡 级别问题

## 接口契约

<details>
<summary>/wok-cr-insight [--file <path>]</summary>

### 参数

| 参数 | 格式 | 默认值 | 说明 |
|------|------|--------|------|
| `--file` | 文件路径 | 自动定位 | 指定 `_review.md` 路径 |

### 调用方式

```
/wok-cr-insight                                     # 自动定位
/wok-cr-insight --file plans/feature-x/_review.md   # 指定文件
```

### 触发方式

| 场景 | 触发方 | 说明 |
|------|--------|------|
| 管道内 | review-engine Stage 5 | 每轮 review 写入报告后自动触发 |
| 独立使用 | 用户手动调用 | 分析已有 `_review.md` |

### 输出

直接修改 `_review.md`，在每个 🟡 问题下方追加 3 个区块。不产出独立报告文件。

### 异常

| 场景 | 处理 |
|------|------|
| `_review.md` 不存在 | 输出"未找到审查报告"并退出 |
| 无 🟡 问题 | 输出"无 Advisory 问题需要分析"并退出 |

</details>

## 分析输出格式规范

每个 🟡 问题追加 3 个标准区块：

```markdown
- [🟡] src/utils.py:108 — 日期解析缺少时区处理
  原因: datetime.now() 不含时区信息
  建议: 使用 datetime.now(tz=timezone.utc)
  来源: type-design-analyzer

> **🔍 原因分析**
> <根因说明：设计缺陷/编码疏忽/架构约束/上下文缺失>

> **🔧 修改方案**
> <具体修改步骤，含代码示例>

> **📐 一致性评估**
> <与 PRD/设计目标的关系评估。无管道上下文时标注"无管道上下文">
```

格式约束：
- 使用 `>` 引用块区分追加内容
- 3 个区块标题固定为 `🔍 原因分析`、`🔧 修改方案`、`📐 一致性评估`
- 无管道上下文时一致性评估输出：`> ⚠️ 无管道上下文，跳过一致性评估`

## 执行流程

### Step 1: 定位输入

1. 解析 `--file` 或自动搜索 `plans/` 目录下的 `_review.md`（与 review-engine Stage 0 检测逻辑一致）
2. 验证文件存在且包含 🟡 问题
3. 检测管道上下文：搜索 `plans/` 目录下的 `_define.md`（存在即为管道模式），与 review-engine 使用相同的检测路径，避免 feature 名称差异导致上下文丢失

### Step 2: 解析 🟡 问题

1. 提取所有 🟡 级别问题条目
2. 跳过已有 `🔍 原因分析` 区块的问题（幂等）

### Step 3: 逐个分析

1. 读取问题涉及的源代码上下文
2. 追溯根因：设计缺陷 / 编码疏忽 / 架构约束 / 上下文缺失
3. 给出具体修改方案（可直接执行的代码）
4. 管道模式下对照设计锚点评估一致性

### Step 4: 写入追加

将分析内容插入每个问题下方，写回 `_review.md`

## 实现约束

- **幂等性**：重复调用不重复追加，通过检测 `🔍 原因分析` 区块判断
- **只读源码**：仅读取源代码，DO NOT 修改源代码文件
- **只写报告**：仅修改 `_review.md`
- **管道模式优先**：有 PRD 上下文时必须执行一致性评估
- **独立模式降级**：无管道上下文时标注跳过
- **分析触及根因**：DO NOT 仅重述问题现象
- **代码示例完整**：DO NOT 给出伪代码
