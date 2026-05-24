# 09 — 全局状态卡 + Next Action 推荐

## 背景

Dashboard 缺少全局视角——用户最关心的问题是"我现在该干嘛？"当前信息分散在各个 tab 中，需要主动聚合。

## 决策

在 header 下方、tab bar 上方新增**全局状态卡**（非独立 tab，而是常驻条）。显示 feature 整体状态、阻塞项、remark 统计、推荐的下一步动作。

## 状态卡设计

```
┌─────────────────────────────────────────────────────────────────────┐
│ 🟢 READY  │  wok-code-review  │  📋 12 决策  │  💬 3 open / 5 applied │
│             │  Current: Design Review  │  ⚠ 0 stale  │  0 blocking     │
│                                                                   │
│  ▶ 下一步：确认需求文档 → 运行 wok-design                            │
└─────────────────────────────────────────────────────────────────────┘
```

### Feature 状态枚举

| 状态 | 条件 | 颜色 |
|------|------|------|
| `DONE` | 所有文档 approved + fresh，review 已收敛 | 绿色 |
| `READY` | 当前阶段文档 approved，无 blocking，可进入下一阶段 | 绿色 |
| `IN_PROGRESS` | 当前阶段有 draft 文档 | 黄色 |
| `BLOCKED` | 存在 blocking finding 或 stale 文档阻止推进 | 红色 |

### Next Action 推理规则

按优先级从高到低：

```
1. 如果存在 stale 文档 + impact MAJOR:
   → "上游文档已变更（MAJOR），建议重新运行 {affected_skill}"

2. 如果存在 open blocking finding:
   → "处理 {N} 个 blocking finding，然后运行 wok-design-review"

3. 如果 _define.md status == draft:
   → "确认需求文档 → 审批 _define.md"

4. 如果 modules/_registry.md 不存在:
   → "运行 wok-design 生成模块设计"

5. 如果存在 draft design 文档:
   → "审阅并审批设计文档"

6. 如果 _check.md 不存在:
   → "运行 wok-design-review 校验设计"

7. 如果存在 open blocking finding:
   → "修复 {N} 个 blocking finding"

8. 如果 _plan.md 不存在:
   → "运行 wok-plan 生成执行计划"

9. 如果 _plan.md status == draft:
   → "审阅并审批执行计划"

10. 如果 _plan.md approved + freshness fresh:
    → "运行 wok-implement 开始实现"

11. 如果 _review.md 存在且 review 已收敛:
    → "Review 已收敛，feature 开发完成"
```

### Remark 统计

从 `_remark.jsonl` 聚合：

```
💬 3 open / 5 applied / 1 resolved
```

- open > 0 时显示，否则隐藏
- 点击 → 打开备注面板

## 修改文件

### `dashboard.html`

在 `<nav class="tab-bar">` 前插入状态卡容器：

```html
<div id="global-status-card" class="global-status-card" style="display:none"></div>
```

### `render.js`

**新增**：
- `computeFeatureStatus()` — 根据所有文档状态计算 feature 整体状态（DONE/READY/IN_PROGRESS/BLOCKED）
- `computeNextAction()` — 按推理规则链返回推荐的下一步动作
- `computeRemarkStats()` — 从 notes 数据聚合 remark 统计
- `renderGlobalStatusCard()` — 渲染状态卡 HTML

**修改**：
- `fetchAndLoadFiles()` 完成后调用 `renderGlobalStatusCard()`
- remark 变更后刷新状态卡
- 文档状态变更后刷新状态卡

### `style.css`
- `.global-status-card` 布局和样式
- Feature 状态颜色（DONE/READY/IN_PROGRESS/BLOCKED）
- Next Action 高亮样式
- Remark 统计样式
- 折叠/展开支持（可收起状态卡）

## 前置依赖

- 01-status-foundation（双状态模型）
- 03-remark-lifecycle（remark state 统计）
- 04-stale-detection（stale 统计）
- 05-finding-states（blocking finding 统计）
- 06-decision-ledger（决策统计）

## 验证

1. 新 feature，所有文档 draft → 状态卡显示 `IN_PROGRESS`，Next Action 为"确认需求文档"
2. 审批 _define.md → 状态卡更新为"运行 wok-design"
3. 存在 blocking finding → 状态卡显示 `BLOCKED`
4. 所有文档 approved + fresh + review 收敛 → `DONE`
5. remark 有 3 open → 显示统计 → 点击打开备注面板
6. 状态卡可折叠收起
