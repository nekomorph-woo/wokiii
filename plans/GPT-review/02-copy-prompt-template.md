# 02 — 复制备注为固定 Prompt 模板

## 背景

当前"复制全部"按钮直接拼接所有 remark 文本，缺乏结构化上下文。复制给 Claude Code / Codex 后，LLM 缺少 feature 名、引用来源、任务指令等关键信息，导致修正效果不稳定。

## 决策

- 干掉"复制全部"按钮
- 新增"复制"按钮，点击后当前备注列表进入**多选模式**
- 勾选备注后点击"生成 Prompt"，生成固定格式 prompt 并复制到剪贴板
- 保留备注状态筛选器（配合 03-remark-lifecycle）

## Prompt 模板

```markdown
请根据下面的 Wok Pipeline 备注，定位对应文档内容并执行修正。

## Feature 信息

- Feature: {{SYSTEM_NAME}}
- 文档目录: plans/{{SYSTEM_NAME}}/

## 待处理备注

### [REM-001] 决策
- 状态: open
- 来源: _define.md > 非目标

> 引用原文: wok-simplify 不产出独立报告，优化是静默的

用户备注: wok-simplify 的结果不进入审查报告，只作为 review-engine 可选的修复工具。

---

### [REM-003] 建议
- 状态: applied
- 来源: modules/review-engine/design.md > 职责

> 引用原文: review-engine 负责编排...

用户备注: 建议明确 agent 调用的超时策略。

---

## 任务

1. 逐一处理上述备注
2. 修改前先列出影响范围
3. 修改完成后，将备注状态更新为 applied（已在 _remark.jsonl 中追加记录）
4. 如有变更影响下游文档，标注影响等级（PATCH / MINOR / MAJOR）
```

## 修改文件

### `render.js` — 备注 UI 改造

**移除**：
- `#copy-all-btn` 按钮及其事件绑定

**新增**：
- `#copy-btn` 按钮（替换"复制全部"位置）
- 多选模式状态管理（`state.multiSelectMode`）
- 备注 card 增加 checkbox
- "生成 Prompt" 确认按钮（多选模式下出现）
- `generatePrompt(selectedIds)` 函数：按模板拼接 prompt → `navigator.clipboard.writeText()`

### `style.css`
- 多选模式样式：备注 card 左侧 checkbox、半透明遮罩
- "生成 Prompt" 按钮样式
- 选中态视觉反馈（蓝色边框 + 浅蓝背景）

## 验证

1. 单击"复制"→ 进入多选模式 → 勾选 2 条备注 → "生成 Prompt" → 剪贴板内容符合模板
2. 未勾选时"生成 Prompt" 按钮禁用
3. 多选模式下点击已勾选备注可取消
4. ESC 退出多选模式
