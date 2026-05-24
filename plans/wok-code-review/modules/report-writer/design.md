---
status: approved

intent: reference
scope: affected-modules
depends: [req:wok-code-review]
changed: 初始版本
freshness: fresh
wok:
  feature: wok-code-review
  stage: design
  upstream_hashes:
    _define.md: 2d3e67c5f43dd564091816351e3fc0af2486515b
    modules/_registry.md: b95b3afc3c469d1acc56b53593b99eef065ccd7d
  last_change:
    source: skill
    impact: major
  version: 1
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T10:00:00+08:00
---

> **做什么**：`_review.md` 单文件管理，按迭代轮次分区写入审计报告，管理 Open/Resolved 状态转移
> **接口数**：0 个 skill 命令（内部模块，由 review-engine Stage 4 调用）
> **阻塞**：无

## 接口契约

<details>
<summary>report-writer 调用协议（review-engine Stage 4 → report-writer）</summary>

### 输入数据结构

```yaml
# 必填
phase_dir: <string>           # _review.md 写入目标
round: <positive-int>         # 当前轮次号（从 1 开始）
scope: <string>               # 审查范围描述
findings_open:                # 本轮未修复问题列表
  - severity: <"🔴"|"🟠"|"🟡">
    file: <string>
    line: <positive-int>
    title: <string>
    reason: <string>
    fix: <string>
    source: <string>
findings_resolved:            # 本轮已修复的 🔴🟠
  - severity: <"🔴"|"🟠">
    file: <string>
    line: <positive-int>
    title: <string>
    fix_applied: <string>
    simplified: <boolean>
findings_advisory_new:        # 本轮新增的 🟡（仅首次出现）
  - file: <string>
    line: <positive-int>
    title: <string>
    reason: <string>
    suggestion: <string>
    source: <string>

# 可选
converged: <boolean>
max_rounds_reached: <boolean>
simplify_count: <positive-int>
```

### 输出文件格式

产出 `<phase-dir>/_review.md`：

```markdown
# Code Review Report

> scope: <审查范围>
> generated: <首次生成时间 ISO 8601>
> last_updated: <最近更新时间 ISO 8601>

---

## Round <N> — <状态标记>

> reviewed_at: <时间 ISO 8601>
> files: <审查文件数>
> findings: <发现问题数> | resolved: <修复数> | advisory: <🟡数>
> simplify: <本轮 simplify 次数>
<max_rounds_reached 时追加: ⚠️ 达到迭代上限，剩余问题降级为 Advisory>

### Open

- [🔴] src/auth.py:42 — JWT 过期未校验
  原因: token 过期后仍接受请求
  修复方案: 添加 exp 字段校验
  来源: code-reviewer

### Resolved

- [🟠→✅] src/api/handler.go:85 — 错误响应未包装
  修复: 使用 fmt.Errorf 包装原始错误
  简化: 已优化 ✅

---

## Round <N-1> — ✅ Converged

> 已解决。🔴 <N> 个修复，🟠 <N> 个修复。

---
```

### 状态管理协议

| 操作 | 行为 |
|------|------|
| 首次生成 | 创建文件，写入 header + Round 1 |
| 当前轮次覆写 | 定位 `## Round <N>`，替换该分区全部内容 |
| 历史轮次追加 | 旧 Round 下移，追加新 Round |
| 🔴🟠 修复 | 从 Open 移除，写入当前轮次 Resolved |
| 🟡 首次发现 | 写入当前轮次 Open |
| 🟡 重复出现 | 不写入 Open，仅在元数据中计数 |
| 🟡 不再出现 | 自然消失 |
| 收敛 | 标题追加 `✅ Converged` |
| 迭代上限 | 标题追加 `⚠️ Max rounds` |

### 异常

| 场景 | 处理 |
|------|------|
| 文件不存在 | 首次调用时创建 |
| 文件已有内容 | 解析现有轮次，新 Round 追加到顶部 |
| 轮次号不连续 | 按传入值写入 |
| 无问题 | 写入空轮次，标记 `✅ Converged` |

</details>

## 实现约束

- 无独立入口，调用方为 review-engine Stage 4
- 单文件操作，不创建辅助文件
- Markdown 可读性：GitHub-flavored Markdown 兼容
- Dashboard 消费：轮次标题和问题条目格式为 dashboard 解析锚点
- DO NOT 记录代码 diff 或文件内容
- DO NOT 修改已写入的历史轮次内容
