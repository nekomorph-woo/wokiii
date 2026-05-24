---
status: draft
intent: explanation
scope: module
depends: [req:wok-code-review, mod:review-engine]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    modules/code-reviewer/design.md: a3f75435bf25a3a328e2f47b683b6af05b8d0084
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：4 条
> **设计锚点覆盖**：[NECESSITY] 每个 review agent 必须可独立调用
> **未覆盖锚点**：无

## 决策

### [DECISION] 5 维审查标准清单，而非模糊的"检查代码质量"

**选择**：5 个明确维度（逻辑错误、边界条件、空值处理、数据一致性、CLAUDE.md 合规），每个维度下设具体检查项和示例
**否决**：自由文本式审查指令（"仔细检查代码中可能存在的问题"）——不同执行次输出质量波动大，审查覆盖不可预测
**理由**：清单式审查保证每次执行的覆盖一致性。检查项+示例让 agent 的判断标准可预期，也方便后续扩展新检查项。5 个维度的划分遵循"从语义正确到规范合规"的层次：前 4 维是代码语义正确性（bug 检测），第 5 维是项目规范合规（CLAUDE.md）
**影响**：SKILL.md 体量增加约 80 行，但换来可预期的审查质量。维度扩展时只需追加检查项，不影响已有逻辑

### [DECISION] CLAUDE.md 合规作为独立维度

**选择**：第 5 维单独设为"CLAUDE.md 合规"，与 bug 检测维度并列
**否决**：将合规检查嵌入逻辑错误/边界条件维度——合规问题（如命名规范）与 bug（如空指针）性质不同，混在一起导致分级混乱
**理由**：合规问题通常是 🟡 级别，而 bug 检测覆盖全级别。独立维度让 agent 对不同类型问题使用各自的分级标尺，降低误判率
**影响**：合规维度的检查项需要与当前项目的 CLAUDE.md 和 rules 文件保持同步。规则变更时需更新检查项表

### [DECISION] 输入格式采用结构化 XML

**选择**：`<files>`, `<rules>`, `<design-anchors>` 三段式 XML 结构作为输入契约
**否决**：自然语言输入——解析不稳定，review-engine 拼接时容易出现格式错位
**理由**：XML 结构对 LLM 的指令遵循更可靠，标签明确划分了文件内容、规则文本和设计锚点的边界。review-engine 可以程序化生成此格式
**影响**：review-engine 的 Stage 0 预检需要增加一步：将 CLAUDE.md 和 `.claude/rules/*.md` 的内容提取并包装为 `<rules>` 块

### [DECISION] finding 输出使用纯文本 3 行格式

**选择**：`[severity] file:line — title` + `原因:` + `修复方案:` 的纯文本格式
**否决**：JSON 数组输出——JSON 解析在 LLM 输出中容易出现截断、转义错误等问题
**理由**：review-engine Stage 2 需要聚合 5 个 agent 的输出并去重。纯文本格式通过简单正则提取即可完成聚合，容错性更强。3 行格式的紧凑性也减少了 token 消耗
**影响**：review-engine 的聚合逻辑依赖正则解析，需在 design 中明确解析容错策略
