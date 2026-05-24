# 03 — Remark 生命周期改造

## 背景

当前 remark 只有 type（decision/question/suggestion），无 lifecycle state。UI 只有"清空全部"和"复制全部"两个极端操作。remark 与管道完全脱节——修改文档后下游不知道上游变了。

## 决策

- remark 增加 lifecycle state：`open` → `applied` → `resolved` → `rejected` → `deferred`
- 干掉"清空全部"按钮
- 默认视图：仅显示 `open` + `applied` 状态，applied 排在上方
- 支持状态筛选器切换显示范围
- 已产生影响的 remark（applied/resolved）不可编辑内容，但可改变状态

## Remark 数据结构变更

**现状**（`_remark.jsonl`）：

```json
{"id":"rem_1716xxx","type":"decision","content":"...","refs":[{"file":"_define.md","line":42,"text":"...","textHash":"...","stale":false}],"createdAt":"..."}
```

**改后**：

```json
{
  "id": "rem_1716xxx",
  "type": "decision",
  "state": "open",
  "content": "...",
  "refs": [{"file": "_define.md", "line": 42, "text": "...", "textHash": "...", "stale": false}],
  "createdAt": "...",
  "updatedAt": "...",
  "appliedBy": null,
  "changedFiles": null,
  "impact": null
}
```

| 新增字段 | 类型 | 说明 |
|----------|------|------|
| `state` | string | `open` \| `applied` \| `resolved` \| `rejected` \| `deferred` |
| `updatedAt` | ISO 8601 | 最后状态变更时间 |
| `appliedBy` | string \| null | 应用者标识（如 `claude-code`、`manual`） |
| `changedFiles` | string[] \| null | 应用时修改的文件列表 |
| `impact` | string \| null | 影响等级 `patch` \| `minor` \| `major` |

向后兼容：缺少 `state` 字段的 remark 视为 `open`。

## 状态流转规则

```
open ──→ applied    (wok-apply-remarks 或手动标记)
open ──→ rejected   (手动)
open ──→ deferred   (手动)
applied ──→ resolved  (确认修改无问题)
applied ──→ rejected  (修改方案被推翻，需回退)
resolved ──→ open     (重新打开)
```

- `applied` / `resolved` / `rejected` 状态下**不可编辑** content 和 refs
- 所有状态都可手动流转（除了 resolved 不直接到 applied）

## 修改文件

### `render.js` — 备注 UI

**移除**：
- `#clear-all-btn` 按钮及其事件绑定
- `#copy-all-btn` 按钮及其事件绑定

**新增**：
- 筛选按钮组（替代清空/复制全部的位置）：
  - 默认: open + applied
  - 全部: 所有状态
  - 待处理: open
  - 已应用: applied + resolved
- 备注 card 状态 badge（小标签，显示当前 state）
- 已锁定备注的视觉区分（灰色文字、禁用编辑图标）
- 备注 card 的状态切换下拉菜单（仅限允许的流转方向）
- 排序：applied 在 open 之前，同状态内按 updatedAt 倒序

**修改**：
- `renderNotes()` 读取并展示 `state` 字段
- 新增 `updateRemarkState(id, newState)` 调用 `PATCH /api/notes/:id/state`

### `_server.py` — API 扩展

**新增端点**：
- `PATCH /api/notes/:id` — 更新备注（state / content / refs）
- 请求体：`{ "state": "applied", "appliedBy": "manual", "changedFiles": [], "impact": "minor" }`
- 校验状态流转合法性
- 写入 `updatedAt`

**修改**：
- `GET /api/notes` 返回增加 state 等新字段
- `DELETE /api/notes` 保留（单条删除仍需要）

### `style.css`
- 筛选按钮组样式
- 状态 badge 样式（各状态不同颜色）
- 锁定态（不可编辑）视觉样式
- 状态切换下拉菜单样式

## 验证

1. 新建备注默认 state=open，显示在列表
2. 手动将备注标记为 applied → 排序到上方 → content 不可编辑
3. 筛选器"待处理"只显示 open 备注
4. 缺少 state 字段的旧备注正确显示为 open
5. 非法状态流转（如 resolved→applied）返回 400
