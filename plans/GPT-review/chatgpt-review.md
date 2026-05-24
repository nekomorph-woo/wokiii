``` ChatGPT
4.2 缺一个全局 “Next Action” 区

现在每个 tab 都有很多信息，但我从截图里看到的“下一步”还比较分散。

建议 dashboard 顶部或概要 tab 增加一个非常醒目的： Next Action
```
比如：

当前建议：执行 `wok-implement`

原因：
- define / design / check 已完成
- review Round 1 已收敛
- 剩余 advisory 不阻塞实现

需要先处理：
- 无阻塞项
```

因为用户最终最关心的不是“文档有哪些”，而是：我现在该干嘛？

Dashboard 首页顶部应该有一个非常明确的状态卡：
Feature: wok-code-review
Status: BLOCKED / READY / IN_PROGRESS / DONE
Current Stage: Design Review
Blocking Items: 0
Open Decisions: 2
Next Action: Run wok-plan / Fix check findings / Start implement

建议增加 Next Recommended Action

首屏明确显示：
下一步：处理 2 个 open decision，然后运行 wok-plan
下一步：点击 approve _define.md，然后进入 wok-design

这个可以通过规则算出来：
如果 define 未 approve → 下一步确认需求
如果 design 未生成 → 下一步运行 wok-design
如果 design 有 blocking → 下一步修复 blocking
如果 check 有 open blocking → 下一步运行 wok-design-review / apply fixes
如果 plan 未生成 → 下一步运行 wok-plan
如果 plan approved → 下一步运行 wok-implement
```

```我的看法
在dashboard的顶部栏确实可以增加一点信息，会用的人忘记了下一步该干嘛，不会用的人不知道干什么。
这个状态卡你怎么认为？

具体的next的运算规则需要我们根据各个状态和内容进行运算，可以和后面的问题整体讨论
```


---

```ChatGPT
文档状态
DRAFT：已生成但未确认
REVIEWED：已审阅
APPROVED：用户确认
STALE：上游变化后可能过期
SUPERSEDED：被新版本替代

Finding 状态
OPEN：待处理
RESOLVED：已解决
ACCEPTED：接受风险，不修
DEFERRED：延期
INVALID：误报

阶段状态
NOT_STARTED
IN_PROGRESS
BLOCKED
READY
DONE
STALE

严重度
BLOCKING
SEVERE
ADVISORY
INFO

这样 dashboard 才能稳定计算：
当前阶段是否 ready？
是否能进入下一阶段？
是否允许 implement？
是否需要 review？
```

```我的看法
现在的文档状态都是英文的，改为对应的中文，并且，我看我们现在的状态 REVIEWED和APPROVED的区别是什么？pipeline状态要不要区分？

对于GPT说的STALE和SUPERSEDED有必要吗？

后面的其他状态，当前我们的 SKILL的文档模板支持吗？必要吗？
```

---

```ChatGPT
4.4 需要 “stale detection”，否则 dashboard 会骗人
这是我认为后面必须补的能力。

你的 dashboard 是由多个阶段文档组成的：

_define.md
modules/_registry.md
modules/*/design.md
_check.md
_plan.md
_review.md

一旦上游文档改了，下游文档可能过期。

_define.md 改了目标
但 design 还是旧目标
plan 还是旧计划
dashboard 仍然显示绿色

这会很危险。

建议

每个文档 frontmatter 里记录：

wok:
  stage: design
  feature: wok-code-review
  source:
    - path: _define.md
      hash: abc123
    - path: modules/_registry.md
      hash: def456
  generated_at: 2026-05-24T...
  status: draft

dashboard 的js执行时检查：
当前 source hash 是否和生成时一致
如果不一致，标记：STALE

在 UI 上显示：
⚠ design 可能过期：上游 _define.md 已变化

这会非常有价值。

因为长文档管道最大的隐患不是没文档，而是 旧文档看起来还很权威。这玩意儿比没有文档更危险，像过期药还印着“强效”。💊
```

```我的看法
这个确实很有意义，因为文档的变更很容易导致不一致，管道中的SKILL使用上游的文档源时，确实可以读取并声称hash快照，但是也可以让用户手动修改，比如加了个空格/标点符号这样没关系的变化
但是在dashboard上有状态提醒那太牛逼了。

同时，‘备注’ 功能导致的文档修改➡️肯定会需要做提醒和修改，前面的‘概览中的全局状态卡’是否也需要提醒这个事情？进一步的，
```

---

```ChatGPT
4.5 <details> 很好，但需要规范 summary 写法

你已经用 <details><summary> 做折叠，这是对的。

但要注意：summary 不能只是：点击展开详情

summary 应该携带压缩信息，例如：
<summary>🟡 Finding 3：simplify 的 --no-fix 行为缺少设计说明，影响 review-engine 调用边界</summary>

或者 <summary>方案对比：最终选择 review-engine 控制调度，simplify 只做纯转换</summary>

summary 本身必须可读
展开内容只是证据和细节

否则 <details> 只是把长文档藏起来，不是真正减压。

建议

所有 details 统一格式：

<details>
<summary>【严重度/类型】一句话结论 + 影响范围</summary>

### 背景

### 证据

### 推理

### 建议动作

</details>

尤其设计文档中的复杂内容可以按类型折叠：
方案对比
边界条件
异常路径
替代方案
详细接口
审查证据

默认展开：
结论
决策
风险
验收标准

默认折叠：
推理过程
证据
替代方案长解释
复杂边界细节
```

```我的看法
我看了一下，确实当前的<details>使用在模板中很无语，没有实际作用，然后生成的内容就很无效，管道中会生成文档的每个SKILL都需要看一看，是否需要增加新的模板，以及：这些修改是否会影响到dashboard当前的布局和js内容识别？
```

---

```ChatGPT
4.6 缺少“决策账本”的全局聚合

你现在每个阶段都有决策，但我建议 dashboard 单独聚合一个：Decision Ledger, 也就是跨所有文档的决策账本。

决策 ID
决策内容
来源阶段
影响模块
状态
是否可变更
最后更新时间

| ID | 决策 | 来源 | 影响 | 状态 |
|---|---|---|---|---|
| DEC-001 | 不做 PR review，不替代 CI/linter | define | 全局 | Approved |
| DEC-002 | review-engine 负责编排，agents 只做分析 | registry | 所有 agent | Approved |
| DEC-003 | simplify 不触发 review-engine，只做独立命令 | check | simplify / review-engine | Open |

这个非常重要。

因为你现在的管道很完整，未来会有大量决策散落在：

define
design
check
review
plan

人类记忆这玩意儿，连昨天中午吃什么都能丢，更别说架构决策了。🧠

```

```我的看法
有一定意义，并且，是否只需要dashboard改造就可以支持？
```


```ChatGPT
6. 我对当前管道的建议微调

你现在的管道指南已经不错，我建议只做一点小调整：给每个阶段增加“是否会产出 dashboard 可消费结构”的说明。

比如：
wok-define
产出：_define.md
dashboard 消费：问题、目标、非目标、用户故事、设计锚点

wok-design
产出：modules/_registry.md + modules/*/design.md
dashboard 消费：模块概览、依赖图、持久决策、模块卡片

wok-design-review
产出：_check.md
dashboard 消费：阻塞项、建议项、通过项、修复建议

wok-plan
产出：_plan.md
dashboard 消费：执行步骤、完成度、依赖、可执行状态

wok-implement
产出：_review.md / implementation notes
dashboard 消费：执行结果、变更、发现、后续项

这样每个 SKILL 不只是“生成文档”，而是“给 dashboard 提供结构化数据”。

这能避免后面 dashboard 只能靠正则硬解析 Markdown。
正则解析文档这种事，短期很爽，长期像和章鱼搏斗。🐙
```

```我的看法
结构化有利于dashboard的展示，和人类友好的快速拆看，对于md来说，一定结构化对后续的大模型AI Coding阅读也是有益的。
**只是需要对管道中的SKILL做一次全面支持评估**
```

---

```ChatGPT
复制给 Claude Code / Codex 的文本应该有固定格式

你现在说可以“复制文本放到 Claude Code / Codex 输入框中发送给大模型”，这个非常好。

建议做成固定 prompt 模板，而不是只复制备注内容。

比如点击“复制备注”时生成：

```
请根据下面的 Wok Dashboard 备注，定位对应文档内容并执行修正。

## 备注信息

- Feature: wok-code-review
- Remark ID: REM-001
- 类型: 决策
- 状态: open
- 来源文件: _define.md
- 来源章节: 非目标

## 引用原文

> wok-simplify 不产出独立报告，优化是静默的

## 用户备注

决策：wok-simplify 的结果不进入审查报告，只作为 review-engine 可选的修复工具。

## 任务

1. 在相关文档中定位这段内容
2. 判断需要同步修改哪些文档
3. 先列出影响范围
4. 再给出 diff 或直接修改
5. 修改完成后，将该备注状态更新为 applied
```

```

```我的看法
需要且必要
```

---

```ChatGPT
备注应该参与 dashboard 状态统计

现在顶部显示：26 个文件待确认

我建议未来也显示备注状态：
备注：3 决策 / 2 疑问 / 5 建议
待处理：7
已应用：3
阻塞：2
```

```我的看法
需要且必要，是否放到全局状态卡里？
```

---

```ChatGPT
你说：

执行的前置流程文档并非一次成型

这句话非常关键。

所以我建议你定义一个备注处理生命周期：
open：已记录，未处理
applied：已被用于修改文档
resolved：修改后确认无问题
rejected：确认不采纳
deferred：暂缓

最好不要只有“清空全部”。
清空全部很爽，但它是文档治理里的核按钮。按了之后，历史消失，人类再次假装自己记得一切。☢️

建议“清空全部”保留，但旁边加：导出 / 归档 / 标记全部 resolved

```

```我的看法
我的建议是干掉‘清空全部’，根据备注的状态做筛选，默认情况只展示那些必要的状态：open/applied，并且applied在上。
并且同时干掉‘复制全部’，而是点击新按钮‘复制’，将当前展示的备注变为’可多选’状态，选择需要复制的。


**同时，特别需要的一点！！！需要新增 wok-apply-remarks！！！**
专门用于处理remark：1️⃣ 处理remark的问题；2️⃣ 管理remark的生命周期（这样dashboard的状态管理才有用）；3️⃣ 特别重要的一点：对文档的影响

当你把备注复制给 Claude Code / Codex 后，它修正文档了。
这时候最好让它同时追加一条记录到 _remark.jsonl：
{
  "type": "applied",
  "remarkId": "REM-001",
  "appliedBy": "claude-code",
  "changedFiles": ["_define.md", "modules/_registry.md"],
  "summary": "已明确 wok-simplify 不产出独立报告，仅作为 review-engine 的可选修复工具。",
  "createdAt": "..."
}

这样 dashboard 可以显示：
REM-001 已应用，影响 _define.md / _registry.md
如果你不做这个，备注处理历史就断了。

那么，_remark.jsonl 变为了只可追加的东西，根据remark的唯一ID逐条 dashboard的js解析处理？不过，肯定是某些状态的remark就不可修改了，例如已经产生影响的remark，而没有产生影响的remark，例如open状态的，那么肯定是可以修改的

```

---

```ChatGPT
这个问题非常关键，而且你抓到的是 Wok 从“文档展示系统”变成“文档管道系统”之后必然会遇到的核心问题：

备注修改不是普通编辑，它会改变上游事实；上游事实一变，下游文档的可信状态就必须重新计算。

不然就会出现最危险的情况：

需求文档已经被 remarks 改了
模块设计还是旧需求
校验报告还是旧设计
计划还是旧模块
dashboard 还显示一片绿色

这不是减压，这是把用户送进“过期文档安全感幻觉”。非常邪门，也非常像企业知识库。🪦

⸻

先给结论

你应该引入一个核心机制：

上游文档被 remarks 修改后，不要自动把所有下游文档打回 DRAFT，而是把受影响下游文档标记为 STALE / NEEDS_REVALIDATION。

也就是说，文档状态要拆成两层：

人工确认状态：draft / approved
新鲜度状态：fresh / stale / impacted

不要把这两个混在一起。

因为：

approved 表示“用户曾经确认过”
stale 表示“确认时所基于的上游上下文已经变了”

这俩不是一回事。

一个文档可以是：

status: approved
freshness: stale

意思是：

它以前被确认过，但现在可能过期了，需要重新验证。

这个设计非常重要。

⸻

1. 你现在需要的不是单一 status，而是双状态模型

现在你有：

status: draft / approved

但 remarks 引入后，这不够了。

建议改成：

status: draft | approved | rejected
freshness: fresh | stale | impacted

或者更 Wok 风一点：

wok:
  status: draft | approved
  freshness: fresh | stale | impacted

两者语义

status：人类确认状态

draft：还没被用户确认
approved：用户确认过

freshness：依赖新鲜度

fresh：基于当前上游生成，可信
impacted：上游发生变化，可能受影响，但未确认是否必须改
stale：上游变化明确影响本文档，需要重新生成/修补/复审

这样你就不会粗暴地把所有下游打红。

⸻

2. remarks 修改文档后，应该触发 Impact Propagation

wok-apply-remarks 不应该只做：

读 remark
改文档
结束

它应该做完整的 4 步：

1. 应用 remarks，修改直接目标文档
2. 计算直接修改了哪些文档
3. 根据管道依赖图找下游文档
4. 给受影响文档打 freshness 标记

也就是：

remarks → 修改 _define.md
       → 影响 modules/_registry.md
       → 影响 modules/*/design.md
       → 影响 _check.md
       → 影响 _plan.md
       → dashboard 标记这些文档需要重新验证

这一步叫：

impact propagation

虽然听起来很像核泄漏报告，但它确实就是这个意思。☢️

⸻

3. 不同阶段文档的影响规则

你可以先用一个简单依赖图。

wok-idea
  ↓
wok-define
  ↓
wok-design
  ↓
wok-design-review / wok-check
  ↓
wok-plan
  ↓
wok-implement
  ↓
wok-review

更具体一点：

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

当 _define.md 被修改

影响最大。

应该标记：

modules/_registry.md       impacted 或 stale
modules/*/design.md        impacted 或 stale
_check.md                  stale
_plan.md                   stale
_review.md                 impacted
_dashboard.html            regenerate

规则

如果 remark 改的是需求目标、非目标、验收标准、用户故事：

下游 design / check / plan 全部 stale

如果 remark 只是修正措辞、补充背景、不改变语义：

下游 impacted，不必立刻 stale

⸻

当 modules/_registry.md 被修改

影响：

modules/*/design.md
_check.md
_plan.md
_review.md

如果改的是模块列表、依赖图、持久架构决策：

模块设计和 plan stale

如果只是补充说明：

_check.md impacted
_plan.md impacted

⸻

当某个 modules/foo/design.md 被修改

影响：

_check.md       stale 或 impacted
_plan.md        stale 或 impacted

如果改的是接口、职责、依赖、决策：

_check.md stale
_plan.md stale

如果只是修正文案：

_check.md impacted

⸻

当 _check.md 被修改

影响：

_plan.md impacted

如果 check 里有 blocking finding 被 resolved：

_plan.md 可能 fresh，但 dashboard 需要重算状态

如果新增 blocking finding：

_plan.md stale 或 blocked

⸻

当 _plan.md 被修改

影响：

_implement / _review impacted

如果 plan 步骤变化：

后续 implement 结果 stale

⸻

4. 你需要一个 Impact Level，不要全都一刀切

wok-apply-remarks 应该给每次修改打影响等级。

建议三档：

PATCH：文字修正，不改变语义
MINOR：补充说明或局部调整，可能影响下游理解
MAJOR：改变需求、边界、接口、模块、验收标准、依赖关系

对应处理

PATCH
- 直接修改目标文档
- 下游不 stale
- dashboard 重新生成即可
MINOR
- 目标文档 modified
- 下游标 impacted
- 提醒用户可选择重跑 check / dashboard
MAJOR
- 目标文档 modified
- 下游标 stale
- 阻止继续执行 implement，要求重新 design/check/plan

这很重要。

否则你每修一个错别字，整个管道全部红掉。
那用户最后会学会无视红色，和人类无视安全警告一样熟练。🚨

⸻

5. 文档 frontmatter 建议

你可以给每个文档加一组 Wok 元数据。

---
wok:
  feature: wok-code-review
  stage: define
  status: approved
  freshness: fresh
  version: 3
  generated_at: 2026-05-24T10:00:00+08:00
  updated_at: 2026-05-24T11:20:00+08:00
  upstream:
    - path: _idea.md
      hash: abc123
  downstream:
    - path: modules/_registry.md
    - path: _plan.md
  last_change:
    source: remark
    remark_id: REM-008
    impact: major
---

关键字段其实只需要这些：

status: approved
freshness: stale
upstream_hashes:
  _define.md: abc123
last_change:
  source: remark
  impact: major

第一版别搞太复杂，免得 Wok 先把自己煮熟。🍲

⸻

6. Dashboard 显示方式

如果文档是：

status: approved
freshness: stale

UI 不应该显示绿色。

应该显示一种组合状态：

✅ Approved
⚠️ Stale

颜色可以是：

黄紫色 / 橙色 / 斜纹

表示：

以前确认过，但现在需要重新验证。

Pipeline 条建议

绿色：approved + fresh
黄色：draft / pending confirmation
红色：blocked
灰色：not generated
紫色：approved but stale
橙色：impacted

也就是你之前说的：

未生成用灰色

完全对，但还应该加：

stale 用紫色或橙色

因为 stale 不是未生成，也不是阻塞，但它很重要。

⸻

7. remarks 应用后的推荐动作

wok-apply-remarks 修改完文档后，应该输出一个 Impact Report。

例如：

# Remarks Apply Impact Report
## Applied Remarks
- REM-008：修改 _define.md 的非目标边界
- REM-009：补充 wok-simplify 与 review-engine 的调用关系
## Changed Documents
- _define.md
- modules/_registry.md
## Impact Level
MAJOR
## Documents Marked Stale
- modules/code-reviewer/design.md
- modules/review-engine/design.md
- _check.md
- _plan.md
## Recommended Next Action
重新运行：
1. wok-design
2. wok-design-review
3. wok-plan
或至少运行：
1. wok-design-review --affected-only
2. wok-plan --refresh

这个报告非常重要。

否则用户只知道“文档改了”，不知道“管道哪里脏了”。

⸻

8. 最理想的是增加 wok-refresh 或 wok-revalidate

我建议你不要让 wok-apply-remarks 承担所有事情。

可以拆出一个新 SKILL：

wok-revalidate

职责：

读取 feature 文档状态
检查上游 hash / freshness
识别 stale / impacted 文档
推荐需要重跑的阶段
必要时只重跑受影响部分

使用方式：

/wok-revalidate feature/wok-code-review

它输出：

哪些文档 stale
为什么 stale
需要重跑哪个 skill
能否 affected-only
是否阻塞 implement

如果你不想加新 SKILL，也可以让 wok-dashboard 生成时做这件事。

但从职责上看：

wok-dashboard：展示状态
wok-revalidate：计算状态
wok-apply-remarks：修改文档并标记影响

这样更干净。

⸻

9. 受影响下游不一定要全部重写，可以分为三种恢复策略

策略 A：重新生成

适用于：

需求目标变了
验收标准变了
模块边界变了
接口契约变了

处理：

重跑 wok-design / wok-plan

⸻

策略 B：增量修补

适用于：

局部决策变更
单个模块接口小改
某个 finding 解决方案变化

处理：

wok-design --affected-only
wok-plan --refresh

⸻

策略 C：仅重新校验

适用于：

文档措辞修正
补充解释
非结构性调整

处理：

wok-design-review
或 wok-revalidate

不要每次都全量重跑。
全量重跑看似稳，其实会产生新文档噪声。AI 很擅长“重新表达同一件事”，然后 git diff 像爆炸一样。💥

⸻

10. 你可以建立一个 Change Type → Impact 规则表

这个可以直接写进 wok-apply-remarks。

改动类型	影响等级	下游处理
typo / wording	PATCH	dashboard regenerate
补充背景说明	PATCH / MINOR	impacted
修改问题定义	MAJOR	design/check/plan stale
修改目标	MAJOR	design/check/plan stale
修改非目标	MAJOR	design/check/plan stale
修改用户故事	MAJOR	design/check/plan stale
修改验收标准	MAJOR	plan/check stale
修改模块职责	MAJOR	affected module + check + plan stale
修改接口契约	MAJOR	affected modules + check + plan stale
修改依赖关系	MAJOR	registry + check + plan stale
解决 check finding	MINOR / MAJOR	check refresh, plan impacted
修改执行步骤	MINOR	implement impacted

这张表会让系统行为稳定很多。

⸻

11. 回到你的问题：需求文档经过 remarks 改动时，应该怎么做？

我的建议是：

第一步：不要直接重置所有状态

不要把下游全部改回 DRAFT。

而是：

保留 status: approved
新增 freshness: stale / impacted

这样历史确认不会丢。

⸻

第二步：根据改动影响等级传播

如果需求文档是 MAJOR 变更：

_define.md              approved + fresh
modules/_registry.md    approved + stale
modules/*/design.md     approved + stale
_check.md               approved + stale
_plan.md                draft/stale 或 approved/stale

如果是 MINOR：

modules/*               impacted
_check.md               impacted
_plan.md                impacted

如果是 PATCH：

仅 dashboard regenerate

⸻

第三步：dashboard 首页明确提示

例如：

需求文档已通过 remarks 更新，影响等级：MAJOR
以下文档已过期：
- modules/_registry.md
- _check.md
- _plan.md
下一步建议：
运行 wok-design --affected-only，然后运行 wok-design-review。

⸻

第四步：阻止危险下游动作

如果有 stale 文档，尤其是：

_define.md → design stale
design → plan stale

那 dashboard 不应该继续显示：

可以 implement

而应该显示：

不能进入 implement：plan 基于过期设计生成

这非常关键。

⸻

12. 最终推荐架构

你现在可以把 Wok 状态体系设计成这样：

Document Content
  ↓
Document Frontmatter
  - status
  - freshness
  - upstream hashes
  - last change impact
  ↓
Remark Log
  - decision/question/suggestion
  - applied/rejected/deferred
  - impact level
  ↓
Impact Propagation
  - mark downstream impacted/stale
  ↓
Dashboard
  - display pipeline state
  - show stale warnings
  - recommend next action
  ↓
Revalidation
  - rerun affected skills
  - restore freshness

这套链路闭环后，你的 Wok 就不会被 remarks 搞乱。

⸻

最终一句话

remarks 不是普通备注，它是 会改变上游事实的人工反馈事件。

所以每次应用 remark 后，系统必须做三件事：

1. 修改目标文档
2. 计算影响范围
3. 标记下游文档 freshness，而不是粗暴改 status

最关键的设计是：

status 表示“人类是否确认过”
freshness 表示“它是否仍基于最新上游”

这个双状态模型一加，你的 remarks、dashboard、文档 approve、自动校验、执行计划之间的联动就顺了。

不然就是一堆文档互相假装自己还有效。
软件工程里最恐怖的不是没人写文档，是旧文档穿着新衣服继续指挥代码。📄🧟
```

```我的看法
需要逐步消化和设计
```
