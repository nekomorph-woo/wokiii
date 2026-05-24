---
status: draft
intent: explanation
scope: comment-analyzer
depends: [req:wok-code-review, mod:review-engine]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    modules/comment-analyzer/design.md: 23755f1597699fa0163f0e7fdf5f4beb36b74e0f
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

### [DECISION] 仅审查准确性，不审查完整性

**选择**：finding 仅在注释内容与代码行为不一致时产生，缺少注释不构成 finding
**否决**：将"关键函数缺少注释"纳入审查范围——缺少注释是主观判断，强制统一会导致大量误报
**理由**：准确性是客观可验证的（注释说 X，代码做 Y，X != Y），完整性是主观判断。限定在可客观验证的范围内，减少误报
**影响**：🟡 问题数量预计较少，但每个 finding 的信号价值高

### [DECISION] 修复方案必须包含具体注释文本

**选择**：修复方案必须包含修改后的注释完整文本
**否决**：通用修复建议（"请根据代码行为更新注释"）——review-engine Stage 3 的自动修复需要可执行的修复指令
**理由**：comment-analyzer 的输出直接喂给 review-engine 的修复循环。模糊建议无法被自动化处理
**影响**：agent 输出稍长，但消除修复阶段的不确定性

### [DECISION] 🔴 仅限误导性注释

**选择**：🔴 Blocking 仅当注释会导致读者做出错误操作决策时触发（如 API 文档标注参数类型错误导致调用方传错类型）
**否决**：所有"注释与代码矛盾"均定为 🔴——大量矛盾注释属于维护疏忽而非功能风险
**理由**：分级核心原则是"对功能的影响程度"。注释矛盾本身不直接影响运行时行为，但公共 API 文档中的矛盾会导致下游调用方基于错误注释编写代码
**影响**：🔴 finding 预计极少，绝大多数准确性问题落在 🟠

### [DECISION] 设计意图作为独立检查项

**选择**：管道模式时增加"注释描述是否与设计锚点一致"作为独立检查项
**否决**：将设计意图检查融入"注释与代码行为一致性"——混合客观验证与主观意图判断
**理由**：独立模式下该维度自然跳过（无 phase-context），管道模式下作为额外维度生效
**影响**：agent prompt 中该项标注"phase-context 存在时"
