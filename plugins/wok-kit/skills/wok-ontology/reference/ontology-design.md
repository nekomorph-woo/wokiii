# 本体论 — 模块设计阶段指令

> 影响 wok-design 管道技能

## 模块划分原则

- 模块边界遵循 Entity 边界，不遵循页面边界
- 每个模块对应一个或一组高内聚的 Entity
- 跨 Entity 逻辑通过 Relation 连接，不通过共享字段
- **DO NOT** 因页面存在而创建领域对象（DashboardEntity、ListEntity 是界面对象）

## Entity 设计

### 边界检查

Entity 边界不清的信号 — 出现以下任意一条时拆分：

- 拥有多个不同生命周期
- 被不同模块以不同方式修改
- 承载互不相关的规则
- 频繁因不同原因变化

### Attribute 分层

| 层级 | 示例 | 包含条件 |
|------|------|----------|
| **身份属性** | id, type, name, createdAt | 默认包含 |
| **运行属性** | status, priority, owner, stage | 被状态机/权限/规则/多个闭环稳定依赖 |
| **扩展属性** | tags, notes, metadata | 不直接驱动核心流程 |

**晋升规则**：只有被查询、过滤、排序、权限判断、状态机、规则引擎或多个闭环稳定依赖的字段才晋升为正式字段。不满足条件的字段留在 metadata/metadata 中。

**DO NOT** 因"以后可能有用"而晋升字段。

## Relation 设计

- 关系必须显式建模：`A --type--> B`
- 关系必须有类型：`owns / creates / dependsOn / blocks / produces / approves / references`
- 关系可以有属性：`User --assignedTo--> Task` 可含 assignedAt, assignedBy, role
- **DO NOT** 把关键关系藏在 Entity 的 id 字段里（如 `task.artifactId`）
- 关系本身可以承载语义，不把所有信息塞进 Entity

## Action 设计

每个 Action 必须定义：

```
Action: [name]
Target Entity: [entity]
Preconditions: [状态/权限/完整性约束]
Effects: [状态变化 + 产生的新 Entity/Relation]
Failure: [失败情况 + 解释文本]
```

- Action 必须属于领域语义：`approveApplication` 而非 `POST /api/updateStatus`
- Action 优先于页面设计：先定义行为，再设计按钮
- 没有 Preconditions 的 Action 容易造成非法状态
- 没有结果定义的 Action 容易造成副作用失控

## State 设计

有生命周期的 Entity 必须定义状态机：

```
初始状态 → [Action] → 中间状态 → [Action] → 终态
```

状态机必须包含：初始状态、中间状态、终态、合法迁移、非法迁移、异常恢复规则。
状态迁移只通过 Action 触发，不通过直接赋值。

## Constraint 设计

- 约束集中定义在 Entity/Action 规格中
- 约束必须能解释失败原因
- 强返回格式：失败原因 + 缺少什么条件 + 允许的下一步操作
- **DO NOT** 将约束散落在前端按钮禁用、后端接口判断、数据库校验中各自实现

## 交叉分析

跨模块交叉分析时额外关注：
- 跨 Entity 的 Relation 是否被显式建模（而非仅存在 id 引用）
- 共享的 Constraint 在不同模块中是否有冲突定义
- 状态机之间的依赖是否合理（Entity A 的终态是否依赖 Entity B 的状态）
