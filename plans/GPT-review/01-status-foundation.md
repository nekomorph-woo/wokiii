# 01 — 双状态模型基础

## 背景

当前文档只有单维度 `status: draft | reviewed | approved`，无法区分"人类是否确认过"和"文档是否仍基于最新上游"。这导致 remark 修改上游后无法精确标记下游影响。

## 决策

| 项目 | 决策 |
|------|------|
| status 值 | 简化为 `draft` \| `approved`（去掉 `reviewed`） |
| 新增维度 | `freshness: fresh` \| `stale` \| `impacted` |
| 追踪机制 | 全文件 hash + impact level 调节传播范围 |
| impact level | 自动推断 + 手动覆盖（PATCH / MINOR / MAJOR） |

## Frontmatter Schema 变更

**现状**（`document-format.md`）：

```yaml
---
status: draft
intent: decision
scope: global
depends: [mod:*]
changed: one-line summary
---
```

**改后**：

```yaml
---
status: draft
freshness: fresh
intent: decision
scope: global
depends: [mod:*]
changed: one-line summary
wok:
  feature: <feature-name>
  stage: define
  upstream_hashes:
    <parent-doc-path>: <git-blob-hash>
  last_change:
    source: skill | remark | manual
    impact: patch | minor | major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---
```

### 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `status` | 是 | `draft` \| `approved` |
| `freshness` | 是 | `fresh` \| `stale` \| `impacted` |
| `wok.upstream_hashes` | 否 | 父文档路径 → git blob hash 映射 |
| `wok.last_change.source` | 否 | 变更来源：skill 生成 / remark 应用 / 手动编辑 |
| `wok.last_change.impact` | 否 | PATCH / MINOR / MAJOR |
| `wok.version` | 否 | 文档版本号（每次 skill 重新生成 +1） |

## 管道依赖图（形式化）

```
_define.md
  ↓
modules/_registry.md
  ↓
modules/*/design.md
  ↓
_check.md
  ↓
_plan.md
  ↓
_review.md
```

| 文档 | stage | upstream |
|------|-------|----------|
| `_define.md` | define | `[]` |
| `modules/_registry.md` | design | `[_define.md]` |
| `modules/*/design.md` | design | `[_define.md, modules/_registry.md]` |
| `_check.md` | check | `[_define.md, modules/_registry.md, modules/*/design.md]` |
| `_plan.md` | plan | `[_define.md, modules/_registry.md, _check.md]` |
| `_review.md` | review | `[_define.md, _plan.md]` |

## 修改文件

### `document-format.md`
- status 取值改为 `draft` \| `approved`
- 新增 `freshness` 字段定义
- 新增 `wok` 嵌套对象说明
- 移除 `reviewed` 相关描述

### `render.js`
- `VALID_STATUSES` 改为 `['draft', 'approved']`
- 新增 `VALID_FRESHNESS` = `['fresh', 'stale', 'impacted']`
- status 循环改为 `draft → approved → draft`
- 解析 frontmatter 时提取 `wok` 对象存入 `state.parsed[i].wok`
- pipeline 进度条读取 freshness 字段决定颜色

### `_server.py`
- `VALID_STATUSES` 改为 `{'draft', 'approved'}`
- `PATCH /api/status` 支持同时更新 freshness（或新增 `PATCH /api/freshness`）
- 校验 freshness 值合法

### 所有管道 SKILL 的输出模板
- frontmatter 模板更新：加入 `status: draft`、`freshness: fresh`、`wok` 嵌套对象
- 生成文档时计算并写入 `upstream_hashes`
- 涉及 SKILL：wok-define, wok-design, wok-design-review, wok-plan, wok-code-review, wok-cr-insight

## 验证

1. 现有文档 frontmatter 兼容：缺少 freshness 字段时默认为 `fresh`
2. status 只允许 draft/approved，设置 reviewed 返回 400
3. freshness 只允许 fresh/stale/impacted
4. wok 字段缺失时 dashboard 不报错（向后兼容）
5. pipeline 进度条：approved+fresh = 绿，approved+stale = 紫，draft = 黄
