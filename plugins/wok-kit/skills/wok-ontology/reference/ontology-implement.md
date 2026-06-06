# 本体论 — 实现阶段指令

> 影响 wok-plan、wok-implement 管道技能

## 测试优先级

TDD 测试覆盖优先级排序：

| 优先级 | 测试类型 | 示例 |
|--------|----------|------|
| **P0** | Entity 行为测试 | "申请提交后 status 变为 pending_review" |
| **P0** | State 迁移测试 | "draft→submit→pending 合法；draft→approve 非法" |
| **P1** | Constraint 验证测试 | "信息不完整时提交返回失败并说明缺少的字段" |
| **P1** | Relation 完整性测试 | "订单删除时级联清理订单项" |
| **P2** | Attribute 边界测试 | "status 只允许枚举值" |

## 行为测试原则

- 测试描述对象行为，不描述实现细节
- 测试使用 Entity 的公共接口，不测试内部私有方法
- 测试命名格式：`"[Entity] [条件] [Action] 时 [期望结果]"`

```
✅ "申请 在 draft 状态 提交后 变为 pending_review"
✅ "申请 信息不完整时 提交 返回失败并说明缺少的字段"
✅ "订单 删除时 清理所有关联的订单项"
❌ "handleSubmit 调用后 state.changed"
❌ "validateForm 返回 false"
```

## 实现顺序

按 Entity 行为闭环实现，不按页面/模块水平切片：

```
Entity A 的行为闭环:
  RED→GREEN: create
  RED→GREEN: submit
  RED→GREEN: approve
  REFACTOR

Entity B 的行为闭环:
  RED→GREEN: create
  RED→GREEN: relate
  REFACTOR
```

## 约束验证

每个 Constraint 至少一个独立测试：
- **正向**：满足条件时 Action 成功
- **反向**：不满足条件时 Action 失败，返回解释文本

示例：
```
✅ "申请 必填字段完整时 提交成功"
✅ "申请 owner 缺失时 提交失败，返回 '缺少必填字段: owner'"
```

## 闭环验证清单

实现完成后，验证能力闭环完整性：

- [ ] 核心 Entity 已创建并可识别（有 id, type, status）
- [ ] Entity 间 Relation 已建立并可查询
- [ ] 关键 Action 已实现，每个 Action 有前置条件和结果
- [ ] State 迁移路径完整（初始→中间→终态）
- [ ] Constraint 能拦截非法操作并返回解释
- [ ] 端到端流程可从起点走到终点
