---
name: resolve-finding
description: 通过 /grill-me 拷问逼出决策，反向修补设计文档歧义/冲突，生成代码修改计划。Use when 用户要求解决审阅报告待处理项、修复代码与设计文档不一致、处理待决策项、提到"resolve finding"。
---

# 待决策项解决工具

对设计文档的歧义/冲突/待决策项，或代码与设计文档的差异，通过 /grill-me 拷问逼出决策，反向修补文档，必要时生成代码修改计划。

**工作流程执行过程中，务必遵守【核心约束】和【检查清单】中的强制硬性要求，流程执行完最后步骤，遵照【检查清单】的每项内容进行仔细检查，发现问题时优先反思处理，无法解决时再使用 AskUserQuestion 工具向用户确认或求助，每项内容检查无误时将【检查清单】的检查结果追加到控制台界面。**

## 三种模式概览

| 模式 | 触发条件 | 输入源 | 输出 | 详细流程 |
|------|---------|--------|------|---------|
| **审阅报告模式** | 输入文件名匹配 `*action-item*`/`*review*`/`*finding*`/`*audit*` | 审阅报告 → 设计文档 | 修补设计文档 + 更新报告状态 | [audit-report-flow.md](reference/audit-report-flow.md) |
| **通用发现模式** | 输入为设计文档路径或设计级自由描述 | 设计文档（+ 可选代码） | 修补设计文档或输出建议 | [general-finding-flow.md](reference/general-finding-flow.md) |
| **代码发现模式** | 输入包含 `src/`/`lib/`/`pkg/` 路径或源码扩展名，或描述涉及代码级问题 | 代码文件 → 反向定位设计文档 | 修补设计文档 + 代码修改计划 → 可交接 /triage-issue | [code-finding-flow.md](reference/code-finding-flow.md) |

## 输入与模式检测

使用 AskUserQuestion 收集：

1. **待处理项位置**：审阅报告路径 + 行范围，或设计文档路径，或代码文件路径，或自由描述
2. **模式自动检测**（按优先级顺序）：
   - 输入包含 `src/`/`lib/`/`pkg/` 路径，或任意源码扩展名（`.java`/`.kt`/`.py`/`.ts`/`.go`/`.rs`/`.swift`/`.c`/`.cpp` 等），或自由描述涉及代码级问题（关键词：方法/类/接口/实现/bug/异常/NPE） → **代码发现模式**
   - 输入文件名匹配 `*action-item*`/`*review*`/`*finding*`/`*audit*` 等审阅报告模式 → **审阅报告模式**
   - 其他（设计文档路径或设计级自由描述） → **通用发现模式**
3. **附加选项**：
   - 通用发现模式：输出到设计文档（需指定目录）或输出到控制台

若模式检测有歧义（如同时包含代码路径和设计文档路径），使用 AskUserQuestion 让用户确认。

## 统一工作流程

所有模式共享同一流程骨架，差异在具体步骤的实现：

```
Step 1: 上下文收集 → Step 2: /grill-me 拷问 → Step 3: 反向修补 → [Step 3.5: 代码修改计划] → Step 4: 连锁检查 → Step 5: 状态更新 → [Step 6: 交接]
```

### Step 1：上下文收集（按模式分流）

- **审阅报告模式** → 读取报告项 → 定位设计文档 → [详见 §1-2](reference/audit-report-flow.md)
- **通用发现模式** → 读取设计文档 → 搜索关联点 → [详见 §1-2](reference/general-finding-flow.md)
- **代码发现模式** → 分析代码 → 反向搜索设计文档 → 构建对比表 → [详见 §1-3](reference/code-finding-flow.md)

### Step 2：/grill-me 拷问决策

使用 /grill-me 对该项进行系统性追问：

1. 呈现完整的冲突/歧义上下文（含所有关联位置）
2. 代码发现模式中：同时呈现代码现状、设计文档描述、差异分析 → [详见 §4](reference/code-finding-flow.md)
3. 审阅报告模式中：呈现报告项原文 + 设计文档现状 + 交叉验证结果 → [详见 §3](reference/audit-report-flow.md)
4. 通用发现模式中：呈现设计文档现状 + 关联点差异 → [详见 §3](reference/general-finding-flow.md)
5. 追问决策树，逐步逼出明确结论
6. 记录决策结论

### Step 3：反向修补

按决策结论修改设计文档（所有模式共有）：

- 展示修改 diff（涉及哪些文件、改了什么）
- 用户确认后写入文件
- 通用发现模式 + 用户选择"输出到控制台" → 仅输出修改建议，不写文件
- 代码发现模式中：**先修补设计文档，再生成代码修改计划**（设计文档优先）

多文件修补顺序：核心定义 → 模块文档 → 总览/关系文档

### Step 3.5：代码修改计划（仅代码发现模式）

根据 /grill-me 决策生成结构化代码修改计划 → [详见 code-modification-plan-template.md](reference/code-modification-plan-template.md)：

- 仅控制台输出，不持久化
- 包含：问题、根因、受影响模块、TDD 循环、验收标准、决策依据
- 使用 AskUserQuestion 询问：A) 交接 /triage-issue B) 直接创建 issue C) 仅输出 D) 调整

### Step 4：连锁检查

- 审阅报告模式：扫描报告中其他待处理项 → [详见 §5](reference/audit-report-flow.md)
- 通用发现模式：检查关联点覆盖情况 → [详见 §5](reference/general-finding-flow.md)
- 代码发现模式：**双向检查** — 设计文档→代码 + 代码计划→设计文档 → [详见 §3](reference/code-finding-flow.md)
- 连锁深度上限 2 级，超出部分报告给用户手动处理
- 如有连带影响 → 展示并询问是否一并处理

### Step 5：状态更新

- 审阅报告模式：更新报告项状态为 ✅ 已解决 → [详见 §6](reference/audit-report-flow.md)
- 通用发现模式：在待处理项位置标记已解决 → [详见 §6](reference/general-finding-flow.md)
- 代码发现模式：标记发现已处理状态

### Step 6：交接 /triage-issue（仅代码发现模式且用户选择交接）

→ [详见 §6](reference/code-finding-flow.md)

交接后 resolve-finding 不再参与后续流程。若变更较轻量，建议直接使用 /branch-unit-test 或 /tdd。

## 核心约束

- **不替用户做决定**：只呈现上下文和影响，决策由 /grill-me 逼出
- **修改前展示 diff**：任何文档修改都先让用户确认
- **连锁透明**：连带影响必须明确展示，不静默修改
- **禁止自动 commit**：等用户指令
- **设计文档优先**：代码发现模式中，先修补设计文档再生成代码修改计划
- **本 skill 不修改代码**：仅生成代码修改计划，不执行代码变更
- **双向连锁检查**：设计文档改了检查影响代码，代码计划改了检查影响设计描述

## 检查清单

工作流程最后一步完成后，逐项检查并将结果输出到控制台。详见 [reference/checklist.md](reference/checklist.md)。
