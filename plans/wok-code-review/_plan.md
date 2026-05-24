---
status: approved

intent: action
scope: global
depends: [chk:wok-code-review]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: plan
  upstream_hashes:
    _define.md: 2d3e67c5f43dd564091816351e3fc0af2486515b
    modules/_registry.md: b95b3afc3c469d1acc56b53593b99eef065ccd7d
    _check.md: 6ec31e4a045c5f2017ab6f9749ebca8334b8024c
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **模块数**：9 个（跨 2 个插件 + 1 个已有插件修改）
> **执行步骤**：9 步
> **集成点**：3 个
> **阻塞**：无

## 执行顺序

### Step 1: [x] [ACTION] 插件脚手架 — 创建 wok-code-review 和 wok-cr-insight 插件目录结构和元数据

- **文件**：
  - 创建 `plugins/wok-code-review/.claude-plugin/plugin.json`
  - 创建 `plugins/wok-code-review/commands/wok-code-review.md`
  - 创建 `plugins/wok-code-review/commands/wok-simplify.md`
  - 创建 `plugins/wok-code-review/skills/wok-code-review/reference/` 目录
  - 创建 `plugins/wok-code-review/skills/wok-code-review/agents/` 目录
  - 创建 `plugins/wok-code-review/skills/wok-simplify/` 目录
  - 创建 `plugins/wok-cr-insight/.claude-plugin/plugin.json`
  - 创建 `plugins/wok-cr-insight/commands/wok-cr-insight.md`
  - 创建 `plugins/wok-cr-insight/skills/wok-cr-insight/` 目录
  - 更新 `.claude-plugin/marketplace.json` 注册 2 个新插件
- **接口**：
  - `plugin.json`：`{"name": "wok-code-review", "version": "0.1.0"}` / `{"name": "wok-cr-insight", "version": "0.1.0"}`
  - `commands/*.md`：标准跳板模板（Bash 定位 → Read → 执行）
- **验证**：`ls -R plugins/wok-code-review/` 和 `ls -R plugins/wok-cr-insight/` 目录结构完整；marketplace.json 包含 2 个新条目
- **集成**：后续所有步骤的前置
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 2: [x] [ACTION] 共享参考文档 — 编写 4 个 _shared 参考文件

- **文件**：
  - `plugins/wok-code-review/skills/wok-code-review/reference/finding-format.md`
  - `plugins/wok-code-review/skills/wok-code-review/reference/severity-guide.md`
  - `plugins/wok-code-review/skills/wok-code-review/reference/agent-constraints.md`
  - `plugins/wok-code-review/skills/wok-code-review/reference/pipeline-context.md`
- **接口**：
  - finding-format.md：3 行 finding 格式 + 空结果哨兵值 `[OK] 无问题` + 扩展字段（优化维度、来源）
  - severity-guide.md：三级定义（🔴 Blocking / 🟠 Severe / 🟡 Advisory）+ 模块级升降级规则
  - agent-constraints.md：排除约束（不替代 linter/typechecker/CI/PR review）
  - pipeline-context.md：Stage 0 上下文包结构 + 双态行为协议（管道模式 vs 独立模式）+ 检测逻辑
- **验证**：4 个文件内容与 `plans/wok-code-review/modules/_shared/` 下的设计文档一致
- **集成**：所有 agent 和 review-engine 的前置依赖
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 3: [x] [ACTION] 5 个专业 agent 定义 — 编写 agent prompt 文件

- **文件**：
  - `plugins/wok-code-review/skills/wok-code-review/agents/code-reviewer.md`
  - `plugins/wok-code-review/skills/wok-code-review/agents/comment-analyzer.md`
  - `plugins/wok-code-review/skills/wok-code-review/agents/silent-failure-hunter.md`
  - `plugins/wok-code-review/skills/wok-code-review/agents/type-design-analyzer.md`
  - `plugins/wok-code-review/skills/wok-code-review/agents/pr-test-analyzer.md`
- **接口**：每个 agent 包含：
  - Frontmatter：`name`, `description`（含 Use when 触发条件）, `model: sonnet`
  - 输入格式声明（files/rules/design-anchors 等）
  - 审查标准清单（各 agent 的检查维度表格）
  - 输出格式：3 行 finding + `优化维度` 可选字段 + `[OK] 无问题` 哨兵值
  - 实现约束（DO NOT / ALWAYS 规则）
- **验证**：每个 agent 文件包含完整的输入/输出/清单/约束；输出格式与 `reference/finding-format.md` 一致
- **集成**：review-engine Stage 1 并行调用的目标（集成点 #1）
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 4: [x] [ACTION] report-writer 规格文档 — 编写 _review.md 格式规范

- **文件**：
  - `plugins/wok-code-review/skills/wok-code-review/reference/report-writer.md`
- **接口**：
  - 输入数据结构（phase_dir, round, findings_open/resolved/advisory_new）
  - 输出文件格式（header → Round N → Open → Resolved → 历史追加）
  - 状态管理协议（覆写+追加、🟡 去重、收敛/迭代上限标记）
  - 异常处理（文件不存在/已有内容/轮次不连续/无问题）
- **验证**：格式规范可直接用于指导 review-engine Stage 4 的写入逻辑；`来源`、`优化维度`、`简化` 等扩展字段在 Open/Resolved 条目中正确定义
- **集成**：review-engine Stage 4 写入报告的格式依据；cr-insight 和 dashboard 的消费端（集成点 #2）
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 5: [x] [ACTION] review-engine SKILL.md — 编写审查编排引擎主技能

- **文件**：
  - `plugins/wok-code-review/skills/wok-code-review/SKILL.md`
- **接口**：1 个 skill 命令 `/wok-code-review [--scope <范围>] [--focus <维度>] [--max-rounds <N>] [--no-fix]`
- **内容**：
  - Stage 0 预检：管道上下文检测（`plans/` 下 `_define.md`）、已有 `_review.md` 解析、scope 解析
  - Stage 1 并行审查：调度 5 个 agent（读取 `agents/*.md` 文件作为 Agent prompt）
  - Stage 2 聚合分级：findings 去重 + 严重度校准（参考 severity-guide.md）
  - Stage 3 修复-验证循环：逐个修复 🔴🟠 → per-file 触发 simplify → 追加 Stage 1 验证 → 收敛判断 → max-rounds 降级
  - Stage 4 报告写入：调用 report-writer 格式写入 `_review.md`（参考 report-writer.md）
  - Stage 5 洞见生成：触发 `wok-cr-insight`
  - 🟡 去重机制：提取已报告 🟡 的 `file:line + title`，后续轮次过滤
  - 双态行为：管道模式注入设计锚点，独立模式跳过
- **验证**：
  - 独立模式（无 `_define.md`）下仅执行代码语义审查，不注入设计锚点
  - `--no-fix` 模式下跳过 Stage 3 和 simplify
  - `--focus` 参数正确筛选 agent 子集
  - 所有 agent 通过 `reference/` 文件获取共享规范
- **集成**：本步骤是集成点 #1（Stage 1 调用 5 个 agent）和集成点 #2（Stage 4 写入报告）的实现方
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 6: [x] [ACTION] simplify SKILL.md — 编写代码简化优化技能

- **文件**：
  - `plugins/wok-code-review/skills/wok-simplify/SKILL.md`
- **接口**：1 个 skill 命令 `/wok-simplify [--target <目标>] [--dimensions <维度>]`
- **内容**：
  - Frontmatter：`model: opus`
  - 双接口：独立调用（用户命令）+ 管道内调用（review-engine Stage 3）
  - 7 个简化维度（D1 nesting ~ D7 complexity）：检测规则 + 修复策略 + 边界约束
  - 管道内调用协议：接收文件+维度 → 静默修复 → 不输出摘要
  - 约束：无 `--no-fix` 参数，语义保持，DO NOT 替代 linter/typechecker
- **验证**：
  - 独立调用时输出变更摘要
  - 管道内调用时静默返回
  - 每个维度的约束边界清晰（如 D3 "DO NOT 跨模块提取"）
- **集成**：review-engine Stage 3 按需调用（集成点 #3）
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 7: [x] [ACTION] cr-insight SKILL.md — 编写 🟡 问题分析技能

- **文件**：
  - `plugins/wok-cr-insight/skills/wok-cr-insight/SKILL.md`
- **接口**：1 个 skill 命令 `/wok-cr-insight [--file <path>]`
- **内容**：
  - Step 1 定位输入：搜索 `plans/` 下 `_review.md`（与 review-engine Stage 0 检测路径一致）→ 检测管道上下文
  - Step 2 解析 🟡：提取所有 🟡 级别问题，跳过已有 `🔍 原因分析` 的（幂等）
  - Step 3 逐个分析：根因追溯 + 修改方案（完整代码）+ 一致性评估
  - Step 4 写入追加：3 个引用块（🔍 原因分析 / 🔧 修改方案 / 📐 一致性评估）
  - 约束：幂等性、只读源码、只写报告、无管道上下文时降级
- **验证**：
  - 重复调用不重复追加（幂等）
  - 管道上下文检测路径与 review-engine 一致
  - 无 `_review.md` 时输出提示并退出
  - 无 🟡 问题时输出提示并退出
- **集成**：依赖 report-writer 输出格式（集成点 #2 消费方）
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 8: [x] [ACTION] Dashboard 集成 — 为 dashboard 新增 _review.md 渲染规格

- **文件**：
  - `plugins/wok-code-review/skills/wok-code-review/reference/dashboard-render-spec.md`（渲染规格定义）
  - 修改 `plugins/wok-dashboard/` 中相关渲染逻辑（增量修改）
- **接口**：
  - 轮次标题解析规则：`## Round <N> — <状态标记>`
  - 问题条目解析规则：`- [<severity>] <file>:<line> — <title>` + 子行（原因/修复方案/来源）
  - 状态标记识别：`✅ Converged` / `⚠️ Max rounds`
  - 🟡 问题追加区块识别：`🔍 原因分析` / `🔧 修改方案` / `📐 一致性评估` 引用块
- **验证**：dashboard 能正确解析 `_review.md` 示例内容；渲染结果包含当前轮次状态、问题分布、历史轮次折叠
- **集成**：消费 report-writer 输出格式（集成点 #2 消费方）
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

### Step 9: [x] [ACTION] 端到端集成验证 — 验证完整管道和独立调用两种模式

- **文件**：无新文件创建（验证步骤）
- **验证项**：
  - [ ] 独立模式：`/wok-code-review --scope src/auth/` 能正常触发 5 个 agent 并产出 `_review.md`
  - [ ] 独立模式：`/wok-simplify --target src/auth/handler.ts` 能正常执行简化
  - [ ] 独立模式：`/wok-cr-insight` 能正常分析已有 `_review.md`
  - [ ] 管道模式：在 `plans/<feature>/` 下触发时正确注入设计锚点
  - [ ] `--no-fix` 模式：跳过 Stage 3 和 simplify
  - [ ] `--focus` 参数：正确筛选 agent 子集
  - [ ] 🟡 去重：第二轮 review 不重复报告已报告的 🟡
  - [ ] 修复-验证循环：第二轮 review 验证修复未引入新问题
  - [ ] `_review.md` 格式：轮次分区、Open/Resolved、收敛标记正确
  - [ ] cr-insight 幂等：重复调用不重复追加
  - [ ] dashboard 渲染：`_review.md` 正确展示
  - [ ] 每个 agent 可独立调用（通过 `/wok-code-review --focus <agent名>` 验证）
- **集成**：本步骤验证所有 3 个集成点
- **完成标记**：更新本 step 的 `[ ]` → `[x]`（wok-implement 自动回填）

## 补充检查维度

| Step | 跨模块集成点 | 测试覆盖 | 遗漏风险 |
|------|-------------|----------|----------|
| Step 1 | 无 | 目录结构检查 | marketplace.json 字段完整性 |
| Step 2 | 无 | 内容一致性 | severity-guide 升降级规则是否覆盖所有 agent 的特殊情况 |
| Step 3 | 集成点 #1 前置 | 输出格式一致性 | agent 输入格式差异（code-reviewer 用 XML，其他用表格）需要 review-engine 适配 |
| Step 4 | 集成点 #2 前置 | 格式可解析性 | report-writer 作为内部模块，其格式规范需同时满足 review-engine 写入和 cr-insight/dashboard 读取 |
| Step 5 | 集成点 #1 + #2 | 端到端逻辑 | review-engine 是最复杂的模块，5 阶段管道逻辑 + 修复-验证循环 + 🟡 去重，prompt 篇幅可能超出 SKILL.md 合理长度 |
| Step 6 | 集成点 #3 | 双接口行为 | simplify 的管道内调用协议（静默模式）需与 review-engine Stage 3 的调用方式匹配 |
| Step 7 | 集成点 #2 消费方 | 幂等性 | cr-insight 管道上下文检测路径需与 review-engine 保持一致（🟡-4 已修复） |
| Step 8 | 集成点 #2 消费方 | 渲染正确性 | dashboard 修改涉及现有代码变更，需确保不破坏现有渲染 |
| Step 9 | 全部集成点 | 端到端验证 | 需要真实代码库作为测试输入 |

## 遗漏风险

1. **review-engine SKILL.md 篇幅**：5 阶段管道 + 修复循环 + 🟡 去重 + 双态行为的 prompt 可能过长。缓解：将 Stage 0 预检和 Stage 2 聚合逻辑拆分到 `reference/` 中，SKILL.md 仅保留编排骨架
2. **agent 输入格式差异**：code-reviewer 使用结构化 XML 输入，其他 4 个 agent 使用简化表格输入。review-engine Stage 1 需要为不同 agent 构建不同格式的上下文包
3. **dashboard 集成涉及现有代码修改**：非纯新增，需要确保不破坏现有 dashboard 渲染

## ✅ 执行计划完成

**步骤数**：9 步
**集成点**：3 个（Stage 1 → 5 agents、Stage 4 → report-writer、Stage 3 → simplify）
**遗漏风险**：review-engine SKILL.md 篇幅控制、agent 输入格式差异适配、dashboard 增量修改安全性
**阻塞**：无
**下一步**：开始 TDD 编码
