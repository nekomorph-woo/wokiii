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
    modules/pr-test-analyzer/design.md: caf552d943b3d31142eed1b58fec9f2dd256f0a4
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **关键决策**：3 条
> **设计锚点覆盖**：[NECESSITY] 每个 review agent 必须可独立调用
> **未覆盖锚点**：无

## 决策

### [DECISION] 静态分析而非执行测试

**选择**：仅通过读取源文件和测试文件进行静态分析
**否决**：运行测试获取覆盖率数据——违反"DO NOT 替代 CI"约束
**理由**：测试运行是 CI 的职责，本 agent 聚焦于"测试是否存在、是否覆盖关键路径"
**影响**：分析基于文件内容和结构，不依赖测试运行环境

### [DECISION] 修复方案给出测试用例描述

**选择**：修复方案包含具体测试用例描述（输入 → 期望行为）
**否决**：仅说"添加测试"
**理由**：具体描述使自动修复可直接生成测试骨架
**影响**：agent 输出稍长但可直接执行

### [DECISION] 未找到测试文件时单条 finding

**选择**：未发现测试文件时输出单条 🟠 finding 标记
**否决**：输出大量 finding 列出所有缺失测试
**理由**：项目无测试是架构决策而非本 agent 的审查范围，单条标记足够
**影响**：降低噪音，让用户知道"没有测试"而非被淹没在缺失列表中
