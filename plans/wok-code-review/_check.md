---
status: approved

intent: action
scope: global
depends: [mod:*]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: check
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

> **检查项**：3 项
> **问题数**：5 个（🔴 0 / 🟡 5 / 🟢 2）
> **阻塞**：无阻塞项

## 检查结果

### 1. 接口一致性

🟡 **Finding 1: review-engine 的 finding 输出格式含 `优化维度` 扩展字段，但 5 个 agent 的 design.md 未声明该字段**

review-engine Stage 1 定义 finding 格式包含 `优化维度: <simplify 触发标记>（可选）`，但 code-reviewer、silent-failure-hunter 的 design.md 输出格式声明中未包含此字段。仅 comment-analyzer 提到了 `优化维度` 作为可选字段。

- **影响模块**：code-reviewer, silent-failure-hunter, type-design-analyzer, pr-test-analyzer
- **修复**：在未声明该字段的 4 个 agent 的 design.md 输出格式中追加 `(可选)优化维度: <simplify 触发标记>`

#### [OPEN] 🟡-1: 统一 agent 输出格式中的 `优化维度` 扩展字段

- [ACTION] 在 code-reviewer, silent-failure-hunter, type-design-analyzer, pr-test-analyzer 的 design.md 输出格式中追加可选字段

🟢 **Finding 2: `_shared/finding-format.md` 空结果哨兵值与 3 个 agent 不一致**

finding-format.md 定义空结果为 `[OK] 无问题`，但 code-reviewer 定义为 `无 finding`，type-design-analyzer 定义为空列表。comment-analyzer 定义为 `[OK] 无注释准确性问题`。

- **影响模块**：code-reviewer, comment-analyzer, type-design-analyzer
- **修复**：统一为 `_shared/finding-format.md` 的 `[OK] 无问题` 哨兵值

#### [OPEN] 🟡-2: 统一空结果哨兵值

- [ACTION] 将 code-reviewer 的 `无 finding`、type-design-analyzer 的空列表统一为 `[OK] 无问题`

### 2. 依赖方向

🟢 **无循环依赖**。依赖图为纯树形结构：review-engine → agents/simplify/report-writer → _review.md → cr-insight。所有依赖单向，无环。

🟢 **分层正确**。核心编排模块（review-engine）不依赖基础设施（report-writer），专业 agent 之间无互相依赖，共享产物在 `_shared/` 中无循环引用。

### 3. 跨模块遗漏

🟡 **Finding 3: US-5 "独立使用" 的验收标准 "simplify 可独立调用" 在 _registry.md 中有覆盖，但 simplify 的独立调用入口缺少 `--no-fix` 模式说明**

`/wok-simplify` 作为独立命令，`--no-fix` 模式下不应触发（因为 simplify 本身就是修复操作），但 design.md 未显式说明此场景下的行为。

- **影响模块**：simplify
- **修复**：在 simplify design.md 的异常/约束中补充：`--no-fix` 是 review-engine 的参数，simplify 无此参数；管道内 `--no-fix` 模式下 review-engine 不触发 simplify（已在 review-engine design.md 中声明）

#### [OPEN] 🟡-3: 补充 simplify 的 `--no-fix` 场景说明

- [ACTION] 在 simplify design.md 中补充：simplify 无 `--no-fix` 参数，管道内不触发由 review-engine 控制

🟡 **Finding 4: US-7 "Dashboard 集成" 无对应设计模块**

_define.md 的 US-7 要求 dashboard 识别 `_review.md` 并渲染，但当前模块设计中 `dashboard-integration` 仅在 `_registry.md` 的插件映射表中提及为"增量修改现有 dashboard"，无 design.md 和 decisions.md。

- **影响**：dashboard 集成无设计约束，实现时可能遗漏渲染规格
- **建议**：dashboard 集成可作为 `wok-plan` 阶段的增量任务，不阻塞当前设计。但建议在 plan 阶段为 dashboard 新增一个模块，定义渲染规格（轮次标题解析、问题条目解析、状态标记识别）

#### [OPEN] 🟡-5: dashboard 集成设计缺失

- [ACTION] 延迟到 plan 阶段处理，在 plan 中为 dashboard 新增渲染规格模块

🟡 **Finding 5: cr-insight 的管道上下文检测逻辑与 review-engine 不一致**

review-engine Stage 0 检测 `plans/` 下的 `_define.md`，cr-insight Step 1 检测"同目录下的 `_define.md`、`design.md`"。两者的检测路径不同——review-engine 搜索整个 `plans/` 目录，cr-insight 仅检查 `_review.md` 同目录。在 feature 名称不同时可能导致 cr-insight 找不到管道上下文。

- **影响模块**：cr-insight
- **修复**：cr-insight 应与 review-engine 使用相同的检测逻辑（搜索 `plans/` 目录而非仅同目录），或直接读取 `_review.md` 的 header 中的元数据推断管道上下文

#### [OPEN] 🟡-4: 统一 cr-insight 管道上下文检测逻辑

- [ACTION] 修改 cr-insight Step 1 的检测路径，与 review-engine Stage 0 保持一致
