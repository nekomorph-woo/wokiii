# 编号规范

## 原则：维度文档内全局递增

每个维度文档内的所有发现项，**不分子类别**（缺口/依赖问题/假设/违反），统一从 `#1` 开始连续编号。

**为什么**：确保 `06-action-items.md` 中的"来源"编号能唯一定位到维度文档中的具体条目，无需额外区分子序列。

## 示例

`03-completeness.md` 覆盖 D3+D4，有 10 个完整性缺口 + 4 个依赖问题：

```markdown
## 完整性缺口
### 🔴 #1  AgentContext 未定义        ← D3-#1
### 🔴 #2  ChatMemory 来源不明        ← D3-#2
...
### 🟡 #10 nativeFunction null 处理   ← D3-#10

## 依赖问题
### 🟡 #11 FunctionTranslationService  ← D4-#11
### 🟡 #12 Agent-Device-Service 不明确  ← D4-#12
### 🟡 #13 Redis 降级缺失              ← D4-#13
### 🟢 #14 user_device_base 方向风险   ← D4-#14（已修补）
```

## 跨文档引用格式

### 06-action-items.md "来源"列

格式：`D{维度}-#{编号}`

- 编号是维度文档中的实际编号（连续序列中的值）
- 维度前缀对应子类别归属（完整性缺口→D3，依赖问题→D4，假设→D5 等）
- **跨文档查找**：看到 `D3-#7` → 打开 `03-completeness.md` 搜索 `#7`

| 维度前缀 | 对应子类别 | 对应文档 |
|----------|-----------|----------|
| D1 | 全部 | 01-traceability.md |
| D2 | 全部 | 02-consistency.md |
| D3 | 完整性缺口 | 03-completeness.md |
| D4 | 依赖问题 | 03-completeness.md |
| D5 | 假设暴露 + 原则违反 | 04-assumptions.md |

### 05-decisions.md "关联发现"

决策记录中引用发现时，使用相同的 `D{维度}-#{编号}` 格式：

```markdown
**关联发现**：D2-#3, D5-#7
```
