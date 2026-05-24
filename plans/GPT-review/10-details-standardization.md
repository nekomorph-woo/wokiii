# 10 — `<details>` 模板规范标准化

## 背景

`document-format.md` 要求管道文档使用 `<details>` 折叠深度内容，但 19 个 SKILL 中**没有一个实际在输出模板中使用了**。当前生成的文档要么没有折叠，要么 summary 写成"点击展开详情"这种无信息量的文本。

## 决策

渐进式推进，优先改造高频 SKILL 的模板，不一次性全改。

## Summary 规范

`<summary>` **必须**携带压缩信息，格式：

```markdown
<summary>【类型】一句话结论 + 影响范围</summary>
```

类型标签：
- 【方案对比】
- 【边界条件】
- 【异常路径】
- 【替代方案】
- 【详细接口】
- 【审查证据】
- 【推理过程】
- 【实现约束】

### 展开规则

**默认展开**（不用 `<details>` 包裹）：
- 结论
- 决策（`[DECISION]`）
- 风险
- 验收标准
- 模块概览

**默认折叠**（用 `<details>` 包裹）：
- 推理过程
- 证据
- 替代方案长解释
- 复杂边界细节
- 接口详细定义
- 实现约束细节

## 优先改造 SKILL

| 优先级 | SKILL | 原因 |
|--------|-------|------|
| P0 | wok-design | 设计文档最长最密，折叠收益最大 |
| P0 | wok-design-review | check 报告 finding 详情适合折叠 |
| P1 | wok-define | 需求文档中的边界条件和用户故事细节 |
| P1 | wok-code-review | review 报告中的推理和证据 |
| P2 | wok-plan | 计划中的详细步骤说明 |
| P2 | wok-cr-insight | insight 的推理过程 |

## Dashboard 兼容性

当前 `render.js` 的 markdown-it 渲染已支持 `<details>`（浏览器原生），改造模板**不影响** dashboard 布局。

但需注意：
- `<details>` 嵌套不超过 1 层（当前规范已要求）
- `<summary>` 内的 markdown-it 内联语法（粗体、代码）正常渲染

## 修改文件

### `document-format.md`
- 强化 `<details>` 使用规范
- 新增 summary 格式要求
- 新增展开/折叠规则

### 各 SKILL 的输出模板 / reference 文档
- P0: wok-design（SKILL.md + reference/output-format.md）
- P0: wok-design-review（SKILL.md + 输出模板）
- P1: wok-define（SKILL.md + 输出模板）
- P1: wok-code-review（SKILL.md + reference/report-writer.md）

## 验证

1. wok-design 生成的 design.md 中使用 `<details>` 包裹详细接口和实现约束
2. summary 文本包含类型标签和一句话结论
3. Dashboard 正确渲染折叠内容（markdown-it + 浏览器原生）
4. 嵌套不超过 1 层
