# 04 — Stale Detection 与 Impact Propagation

## 背景

管道文档由多阶段产出，上游变更后下游可能过期但 dashboard 仍显示绿色。需要自动检测上游变化并标记下游文档的新鲜度。

## 决策

- 追踪机制：**全文件 git blob hash** + impact level 调节传播范围
- Impact level：**自动推断 + 手动覆盖**（PATCH / MINOR / MAJOR）
- freshness 三态：`fresh` / `stale` / `impacted`
- 不新增 wok-revalidate SKILL（V2 再考虑）

## Upstream Hash 机制

### 写入时机

每个管道 SKILL 生成文档时，在 `wok.upstream_hashes` 中记录当前上游文档的 git blob hash：

```yaml
wok:
  upstream_hashes:
    _define.md: a1b2c3d4...
    modules/_registry.md: e5f6g7h8...
```

hash 计算方式：`git hash-object <file-path>`（仅内容 hash，不含文件名）。

### 检测时机

Dashboard 加载文件列表时，`render.js` 对比：
1. 读取每个文档的 `wok.upstream_hashes`
2. 计算当前上游文档的实际 hash
3. 如果 hash 不匹配 → 上游已变化

### Impact Level 判定

**自动推断**（由 wok-apply-remarks 或 dashboard 检测时触发）：

根据变更内容类型推断 impact level：

| 变更类型 | impact | 说明 |
|----------|--------|------|
| 纯文字修正（typo/措辞） | PATCH | 不改变语义 |
| 补充背景/说明 | MINOR | 可能影响下游理解 |
| 修改问题定义/目标/非目标 | MAJOR | 需求层面变更 |
| 修改验收标准 | MAJOR | 影响计划和校验 |
| 修改模块职责/接口 | MAJOR | 架构层面变更 |
| 修改依赖关系 | MAJOR | 模块间影响 |
| 解决 blocking finding | MINOR | 局部修复 |
| 新增/删除模块 | MAJOR | 结构性变更 |

**手动覆盖**：wok-apply-remarks 执行时，LLM 推断 impact level 后询问用户确认/调整。

## Impact Propagation 规则

### 传播表

| 被修改文档 | impact | 受影响文档 | 标记 freshness |
|------------|--------|------------|----------------|
| `_define.md` | PATCH | 无 | 仅自身 `updated_at` 更新 |
| `_define.md` | MINOR | registry, design, check, plan, review | `impacted` |
| `_define.md` | MAJOR | registry, design, check, plan, review | `stale` |
| `modules/_registry.md` | PATCH | 无 | 仅自身更新 |
| `modules/_registry.md` | MINOR | design modules, check, plan, review | `impacted` |
| `modules/_registry.md` | MAJOR | design modules, check, plan, review | `stale` |
| `modules/*/design.md` | PATCH | 无 | 仅自身更新 |
| `modules/*/design.md` | MINOR | check, plan | `impacted` |
| `modules/*/design.md` | MAJOR | check, plan | `stale` |
| `_check.md` | PATCH | 无 | 仅自身更新 |
| `_check.md` | MINOR | plan | `impacted` |
| `_check.md` | MAJOR | plan | `stale` |
| `_plan.md` | PATCH | 无 | 仅自身更新 |
| `_plan.md` | MINOR | review | `impacted` |
| `_plan.md` | MAJOR | review | `stale` |

### 传播算法（`propagateImpact()`）

```
function propagateImpact(changedDoc, impactLevel):
    for each doc in pipeline:
        if doc is downstream of changedDoc:
            if impactLevel == PATCH:
                skip  // 不影响下游
            elif impactLevel == MINOR:
                doc.freshness = max(doc.freshness, 'impacted')
            elif impactLevel == MAJOR:
                doc.freshness = max(doc.freshness, 'stale')
```

freshness 优先级：`fresh < impacted < stale`（只会升级，不会降级）。

降级时机：文档被对应 SKILL 重新生成时，freshness 重置为 `fresh`。

## 修改文件

### `render.js`

**新增**：
- `computeHashes()` — 对所有已加载文档计算当前 git blob hash
- `checkFreshness()` — 对比 upstream_hashes vs 当前 hash，返回 freshness 状态数组
- `propagateImpact(changedDoc, level)` — 按传播表更新下游 freshness
- 在 `fetchAndLoadFiles()` 完成后自动调用 `checkFreshness()` → 更新 UI

**修改**：
- pipeline 进度条颜色逻辑：读取 freshness 字段
- 文档 status badge：组合显示（如 "Approved · Stale"）

### `_server.py`

**新增端点**：
- `GET /api/freshness` — 返回所有文档的 freshness 状态
- `POST /api/freshness/propagate` — 手动触发传播（传入 changedDoc + impactLevel）

**修改**：
- 生成文件列表时附加 freshness 状态

### 管道 SKILL（wok-define, wok-design, wok-design-review, wok-plan, wok-code-review, wok-cr-insight）
- 生成文档时计算并写入 `wok.upstream_hashes`
- 新生成文档 freshness = `fresh`，version +1

## 验证

1. 修改 `_define.md` 一段文字 → dashboard 检测到 hash 不匹配 → 下游标 `impacted`
2. 通过 API 标记 impact = MAJOR → 下游标 `stale`，pipeline 进度条变紫
3. 重新运行 wok-design → 生成新 design.md → freshness 恢复 `fresh`
4. PATCH 级别变更 → 下游不受影响
5. 缺少 upstream_hashes 的旧文档视为 `fresh`（向后兼容）
