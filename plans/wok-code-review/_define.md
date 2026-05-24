---
status: approved












intent: decision
scope: global
depends: []
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: define
  upstream_hashes: {}
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---
> 当前 wok 管线在 `wok-implement` 之后缺少代码审查闭环。引入 3 个新插件（`wok-code-review`、`wok-simplify`、`wok-cr-insight`），建立「审查-修复-验证」迭代循环，使每轮实现产出都经过多维度审查、分级自动修复和可追溯的审计报告。

## 问题

`wok-implement` 完成后无审查机制，代码质量完全依赖实现时的即时判断。缺少以下能力：

* 多维度代码审查（逻辑 bug、错误处理、类型设计、注释准确性、测试覆盖）

* 基于严重程度的分级处理（阻塞问题自动修复 vs 建议问题留待决策）

* 代码简化优化（臃肿代码、过度防御、嵌套过深）

* 可追溯的审计报告与持续质量跟踪

* 管道内的闭环修复验证 

## 目标

* 在 `wok-implement` 之后建立自动化的代码审查闭环

* 🔴 Blocking 和 🟠 Severe 问题自动修复并追加验证，不阻塞开发者注意力

* 🟡 Advisory 问题生成分析报告和修改方案，由用户决定是否处理

* 审查可嵌入管道自动运行，也可独立使用

* 审计报告融入 dashboard，提供可视化的质量追踪

## 非目标

* 不做 PR 级别的 code review（那是官方 `code-review` 插件的职责，基于 `gh` CLI 操作 GitHub PR）

* 不做 CI/CD 集成（构建信号、类型检查、测试运行由 CI 负责）

* 不做代码风格 lint（linter/typechecker/compiler 覆盖的范畴不纳入）

* 不引入第三方代码分析工具或服务

* `wok-simplify` 不产出独立报告，优化是静默的

## 用户故事

### US-1: 管道内自动审查

作为开发者，我希望每轮 `wok-implement` 完成后自动触发代码审查，以便实时捕获问题而非积累到后期。

**验收标准**：

* [ ] `wok-implement` 完成后自动触发 `wok-code-review`

* [ ] 审查范围默认为未提交变更（`git diff`）

* [ ] 审查结果产出 `_review.md` 写入 feature plans 目录

### US-2: 分级自动修复

作为开发者，我希望 🔴 Blocking 和 🟠 Severe 问题被自动修复，以便我专注于业务逻辑。

**验收标准**：

* [ ] 🔴 问题（功能中断/数据丢失）自动修复，修复后追加一轮 review 验证正确性

* [ ] 🟠 问题（影响功能但有降级路径）自动修复，修复失败时升级为用户确认

* [ ] 自动修复直接修改代码文件，不产出 patch

* [ ] 每次自动修复后追加一轮 review，确认修复未引入新问题且与 PRD/设计目标一致

### US-3: Advisory 问题分析与方案

作为开发者，我希望 🟡 Advisory 问题附带原因分析和修改方案，以便我做出知情决策。

**验收标准**：

* [ ] 🟡 问题写入 `_review.md`，不自动修复

* [ ] 每轮 review 结束后自动触发 `wok-cr-insight`

* [ ] `wok-cr-insight` 在每个 🟡 问题下方追加原因分析和具体修改方案

* [ ] 🟡 问题仅首次发现时报告，后续轮次不再重复

### US-4: 代码简化优化

作为开发者，我希望审查过程中检测到可优化代码时自动简化，以便代码质量随实现自然提升。

**验收标准**：

* [ ] review agent 检测到臃肿/过度防御/嵌套过深等优化维度时，per-file 触发 `wok-simplify`

* [ ] simplify 直接修改代码，不产出独立报告

* [ ] simplify 不作为独立管道节点运行

### US-5: 独立使用

作为开发者，我希望审查工具可脱离管道独立使用，以便在任何场景下审查代码。

**验收标准**：

* [ ] `wok-code-review` 支持用户指定审查范围（文件、目录、git diff、整个 feature 分支）

* [ ] `wok-simplify` 可独立调用，指定优化目标

* [ ] `wok-cr-insight` 可独立调用，分析已有 `_review.md`

### US-6: 审计报告可追溯

作为开发者，我希望审计报告按迭代轮次组织，以便追踪质量变化趋势。

**验收标准**：

* [ ] 一个 feature 维护一个 `_review.md`

* [ ] 每轮 review 覆写当前轮次区，历史轮次向下追加

* [ ] 🔴🟠 修复后从 Open 移入已解决轮次的记录

* [ ] 🟡 始终停留在 Open，直到用户处理或不再出现

### US-7: Dashboard 集成

作为开发者，我希望审计报告在 dashboard 中可视化展示，以便快速了解 feature 的代码质量状态。

**验收标准**：

* [ ] dashboard 识别 `_review.md` 并渲染

* [ ] 展示当前轮次状态：auto-fixed 数量、open issues 数量、各问题级别分布

* [ ] 管道终点时触发全分支 review，结果同样写入 `_review.md`

## 设计锚点

### \[EFFECT] 审查必须嵌入实现循环，每轮实现后自动触发

### \[EFFECT] 🔴🟠 必须自动修复，修复后必须追加验证

### \[EFFECT] 审计报告必须单文件按轮次分区

### \[SECURITY] 自动修复不得偏离 PRD 和设计目标

### \[NECESSITY] 每个 review agent 必须可独立调用

### \[NECESSITY] 管道终点必须执行全分支审查

### \[EXCLUSION] 不做 PR review，不替代 CI，不替代 linter
