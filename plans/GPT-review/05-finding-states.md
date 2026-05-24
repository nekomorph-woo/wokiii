# 05 — Finding 状态扩展为三态

## 背景

当前 finding 只有二态（unresolved / resolved），无法区分"已修复"和"接受风险不修"。实际审查中常有合理的设计选择被标记为 finding，但不意味着需要修改。

## 决策

Finding 状态从二态扩展为三态：`open` / `resolved` / `accepted`

| 状态 | 含义 | 颜色 |
|------|------|------|
| `open` | 待处理 | 保持当前红色/橙色/黄色（按 severity） |
| `resolved` | 已修复（已解决） | 绿色 |
| `accepted` | 接受风险，不修 | 蓝色/灰色 |

不实现 GPT 提议的 `deferred` 和 `invalid`——在 wok 语境下这两者与 `accepted` 语义重叠。

## 修改文件

### `render.js`

**修改**：
- finding 解析：识别三种状态标记
- 状态循环点击：`open → resolved → accepted → open`
- finding tag 颜色：新增 `accepted` 样式（蓝灰色）
- finding 过滤按钮：新增 `accepted` 筛选选项
- 统计面板：分别统计 open/resolved/accepted 数量

### `_server.py`

- `PATCH /api/status` 扩展：支持 finding 级别的状态变更（在 `_check.md` 中替换 finding 状态标记）

### `wok-design-review` SKILL 模板

- finding 输出格式明确支持三态标记
- review round 统计中区分 open/resolved/accepted 计数

### `wok-code-review` SKILL（report-writer.md 参考）

- Resolved section 的行为更新：区分 `resolved`（有修复内容）和 `accepted`（有接受原因）

## Finding 标记格式

在 `_check.md` 中，finding 使用以下格式标记状态：

```markdown
### 🔴 Finding 1：标题（open）
...
### 🟢 Finding 1：标题（resolved）
修复说明...
### 🔵 Finding 1：标题（accepted）
接受原因...
```

状态通过行内标记 `(open|resolved|accepted)` 携带，无标记默认为 `open`。

## 验证

1. Dashboard 渲染 _check.md → finding 显示正确状态和颜色
2. 点击 finding 状态 tag → 循环切换 open→resolved→accepted→open
3. 过滤器选择"accepted" → 仅显示接受的 finding
4. Round 统计正确显示 open/resolved/accepted 各数量
5. 缺少状态标记的旧 finding 默认为 open（向后兼容）
