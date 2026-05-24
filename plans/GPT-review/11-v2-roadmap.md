# 11 — V2 Roadmap

## 范围

本轮 V1 计划中明确排除、但未来有价值的功能方向。

## V2.1 — wok-revalidate 独立 SKILL

当前 stale detection 分散在 dashboard（检测）和 wok-apply-remarks（传播）。V2 拆出独立 SKILL 专注"重新验证"：

- 读取 feature 所有文档的 freshness 状态
- 检查 upstream hash 一致性
- 识别 stale / impacted 文档及原因
- 推荐需要重跑的阶段（含 `--affected-only` 选项）
- 是否阻塞 implement

**前置**：V1 的 01（双状态模型）+ 04（stale detection）稳定运行后。

## V2.2 — Finding 状态扩展至五态

V1 三态 (open/resolved/accepted) 满足核心场景。V2 增加：

| 状态 | 含义 |
|------|------|
| `deferred` | 已确认需要处理，但推迟到后续版本 |
| `invalid` | 误报，审查结论不成立 |

**前置**：V1 三态在实际使用中暴露出需要区分"暂时不修"和"根本不用修"的需求。

## V2.3 — SKILL 结构化输出

当前 dashboard 依赖正则解析 Markdown，脆弱且难维护。每个 SKILL 声明产出的结构化数据，dashboard 消费结构而非文本。

**方向**：
- 管道 SKILL 输出增加结构化 section（如 JSON block、约定格式的 table）
- Dashboard 解析从正则 → 结构化数据消费
- 每个 SKILL 声明 `dashboard.consumes` 清单

**范围**：跨 19 个 SKILL + dashboard render.js 全面改造。

**前置**：V1 全部完成后评估 ROI，可能分阶段推进（优先高频 SKILL：wok-design, wok-design-review, wok-code-review）。

## V2.4 — SUPERSEDED 文档状态

当前文档重生成时旧版本直接覆盖。如果未来需要保留版本历史或对比，可引入 `superseded` 状态标记旧版本。

**前置**：实际使用中出现"需要回溯旧版设计"的需求时再评估。
