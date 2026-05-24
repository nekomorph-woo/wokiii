# 08 — Dashboard 视觉刷新（状态颜色 + Stale 提醒）

## 背景

当前 pipeline 进度条只有二色（绿色=approved, 红色=draft/approved），无法区分"未确认"、"已过期"、"受影响"等状态。双状态模型引入后需要视觉体系升级。

## 颜色体系

| 组合 | 颜色 | CSS 变量 | 含义 |
|------|------|----------|------|
| draft + fresh | 黄色 `#E5A100` | `--status-draft` | 待确认 |
| draft + stale | 橙色 `#E57300` | `--status-draft-stale` | 待确认且上游已变 |
| draft + impacted | 浅橙 `#F0A050` | `--status-draft-impacted` | 待确认且可能受影响 |
| approved + fresh | 绿色 `#2E7D32` | `--status-approved` | 已确认，最新 |
| approved + stale | 紫色 `#7B1FA2` | `--status-stale` | 已确认但上游已变 |
| approved + impacted | 蓝紫 `#5C6BC0` | `--status-impacted` | 已确认但可能受影响 |
| 文档不存在 | 灰色 `#9E9E9E` | `--status-missing` | 未生成 |

## Pipeline 进度条

每个 pipeline step 的渲染逻辑更新：

```
if doc not exists:
  color = gray, label = "未生成"
elif doc.status == 'approved' and doc.freshness == 'fresh':
  color = green, label = "Approved"
elif doc.status == 'approved' and doc.freshness == 'stale':
  color = purple, label = "Approved · Stale"
elif doc.status == 'approved' and doc.freshness == 'impacted':
  color = blue-purple, label = "Approved · Impacted"
elif doc.status == 'draft' and doc.freshness == 'fresh':
  color = yellow, label = "Draft"
elif doc.status == 'draft' and doc.freshness == 'stale':
  color = orange, label = "Draft · Stale"
else:
  color = light-orange, label = "Draft · Impacted"
```

## Stale 提醒

当任意文档 freshness != fresh 时：

### Header 区域
- approval badge 旁新增 stale 提醒：
  - `⚠ 3 stale` 红色闪烁（点击跳转到概览 tab 的 stale 详情）

### 概览 Tab
- 在 pipeline 进度条下方新增 stale 详情 section：
  ```
  ⚠ 过期文档
  - modules/review-engine/design.md: 上游 _define.md 已变更（MAJOR）
  - _check.md: 上游 2 个文档已变更（MAJOR）
  ```

### 文档详情页（设计/需求/校验/审查 tab）
- 顶部状态栏显示当前文档的 status + freshness 组合
- stale/impacted 时显示警告横幅：
  ```
  ⚠ 此文档可能已过期：上游 _define.md 已发生 MAJOR 变更
  建议运行 wok-design --affected-only 重新生成
  ```

## 修改文件

### `style.css`
- 新增 7 种状态颜色 CSS 变量
- pipeline step 样式支持新颜色
- stale 提醒横幅样式（橙色/紫色警告条）
- status badge 组合样式

### `render.js`
- `updateApprovalBadge()` 扩展：统计 stale/impacted 数量
- `renderPipelineBar()` 读取 freshness 字段决定颜色
- 新增 `renderStaleWarnings()` — 在概览 tab 渲染 stale 详情
- 各 tab 顶部状态栏读取并显示 freshness

## 前置依赖

- 01-status-foundation（freshness 字段定义）
- 04-stale-detection（freshness 计算逻辑）

## 验证

1. 所有文档 fresh + approved → pipeline 全绿 → 无 stale 提醒
2. 修改上游 → 下游标 stale → pipeline 对应步骤变紫
3. Header badge 显示 `⚠ 2 stale`
4. 点击 stale 提醒 → 跳转到概览 stale 详情
5. 设计 tab 打开 stale 文档 → 顶部显示警告横幅
6. 缺少 freshness 字段的旧文档默认为 fresh（向后兼容）
