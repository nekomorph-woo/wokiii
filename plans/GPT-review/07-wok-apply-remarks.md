# 07 — wok-apply-remarks SKILL

## 背景

remark 修改文档后，缺少系统化的处理流程。用户复制 remark 给 Claude Code 修正文档后，remark 与管道状态完全断裂——下游不知道上游变了，备注处理历史也丢失。

## 决策

新建 `wok-apply-remarks` SKILL，负责：
1. 读取待处理的 remark（open 状态）
2. 修正目标文档
3. 判定 impact level（自动推断 + 用户确认）
4. 更新 remark 状态为 applied
5. 在 `_remark.jsonl` 中追加 applied 记录
6. 执行 impact propagation（标记下游 freshness）
7. 输出 Impact Report

## SKILL 定义

**名称**：`wok-apply-remarks`
**触发**：`/wok-apply-remarks` 或用户要求处理备注
**输入**：feature 目录路径 + 可选 remark ID 列表

### 执行流程

```
1. 读取 _remark.jsonl
2. 筛选 open 状态的 remark（或用户指定的 remark）
3. 对每条 remark：
   a. 分析 remark 内容和引用，理解修改意图
   b. 定位目标文档和相关章节
   c. 列出影响范围（哪些文档需要修改）
   d. 询问用户确认修改方案
   e. 执行修改
   f. 判定 impact level（自动推断）→ 询问用户确认
   g. 更新 remark 状态为 applied
   h. 追加 applied 记录到 _remark.jsonl
4. 执行 impact propagation
5. 输出 Impact Report
```

### Impact Report 格式

```markdown
# Remarks Apply Impact Report

## 已处理备注
- REM-001：修改 _define.md 的非目标边界
- REM-003：明确 review-engine agent 超时策略

## 变更文档
- _define.md
- modules/review-engine/design.md

## 影响等级
MAJOR

## 受影响下游文档（stale）
- modules/_registry.md
- modules/code-reviewer/design.md
- modules/review-engine/design.md
- _check.md
- _plan.md

## 建议下一步
1. 运行 wok-design --affected-only
2. 运行 wok-design-review
3. 运行 wok-plan --refresh
```

### Applied 记录格式

追加到 `_remark.jsonl`：

```json
{
  "type": "applied",
  "remarkId": "rem_1716xxx",
  "appliedBy": "claude-code",
  "changedFiles": ["_define.md", "modules/review-engine/design.md"],
  "impact": "major",
  "summary": "明确 wok-simplify 不产出独立报告，仅作为 review-engine 的可选修复工具。",
  "createdAt": "2026-05-24T..."
}
```

## 修改文件

### 新建：`plugins/wok-apply-remarks/`
- `SKILL.md` — SKILL 定义
- `skills/wok-apply-remarks/reference/impact-rules.md` — impact level 判定规则表
- `skills/wok-apply-remarks/reference/propagation-rules.md` — 传播规则

### `render.js`
- 备注面板新增"应用备注"按钮（调用 wok-apply-remarks 的提示文案，非直接执行）
- applied 状态备注展示 changedFiles 和 impact 信息

### `_server.py`
- `PATCH /api/notes/:id` 支持 appliedBy/changedFiles/impact 字段写入

## 前置依赖

- 01-status-foundation（双状态模型 + frontmatter schema）
- 03-remark-lifecycle（remark state 机制）
- 04-stale-detection（impact propagation 机制）

## 验证

1. `/wok-apply-remarks` 处理 2 条 open remark → 文档修改成功 → remark 状态变为 applied
2. Impact Report 正确列出变更文档和受影响下游
3. Dashboard 刷新后，受影响文档显示 freshness = stale
4. applied remark 显示 changedFiles 列表
5. _remark.jsonl 中追加正确的 applied 记录
