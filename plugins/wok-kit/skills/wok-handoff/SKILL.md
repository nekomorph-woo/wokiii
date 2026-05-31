---
name: wok-handoff
description: 将当前对话摘要为交接文档，供下一个 session 接续工作。Use when 用户要求交接、换手、移交工作、或提到 "handoff" / "交接" / "wok-handoff"。
---

# 交接文档

将当前对话摘要为结构化交接文档，供下一个 session 接续工作。

## 命令接口

```
/wok-handoff [下一轮焦点描述]
```

| 参数 | 说明 |
|------|------|
| `<焦点描述>` | 下一轮 session 的目标，用于定制文档重点 |

## 生成流程

### 1. 收集上下文

回顾当前对话，提取以下信息：

| 维度 | 内容 |
|------|------|
| 进行中的任务 | 当前正在做什么、做到哪了 |
| 已完成的步骤 | 哪些工作已结束 |
| 待处理事项 | 未完成、待测试、待修复 |
| 关键决策 | 用户选择、方案对比结论 |
| 阻塞项 | 未解决且影响后续的问题 |

**不重复已有产物**。`.wok-plans/`、`.wok-grill/` 下的文件只写路径引用，不复制内容。

### 2. 脱敏

移除以下内容：

- API key、token、密码（`sk-`、`Bearer `、`password=` 等）
- 个人身份信息（邮箱、手机号、地址）
- 私有 URL 和内部域名

替换为 `[REDACTED]`。

### 3. 生成文档

按 [reference/handoff-format.md](reference/handoff-format.md) 格式输出到 `.wok-handoff/` 目录。

文件名：`<YYYYMMDD>-<HHMM>-<概要>-handoff.md`

概要从任务主题提取 2-3 个关键词，kebab-case。示例：`20260531-1430-auth-jwt-refactor-handoff.md`

### 4. 输出确认

```
✅ 交接文档已生成

📄 .wok-handoff/20260531-1430-auth-jwt-refactor-handoff.md
📊 进行中: 1 | 待处理: 3 | 阻塞: 1
💡 下轮启动时读取此文件即可接续
```
