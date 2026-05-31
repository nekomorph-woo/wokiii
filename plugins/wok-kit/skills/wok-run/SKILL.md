---
name: wok-run
description: >
  构建 `claude --agent` 命令，帮助用户启动 wok-autopilot 或其他 agent。
  列出可用的 .wok-plans/ 系统，解析 system-name，输出可复制的终端命令。
  Use when 用户要求启动 autopilot、运行 agent、或提到 "wok-run" / "启动" / "跑起来"。
---

# 构建 Agent 命令

帮助用户构建并运行 `claude --agent` 命令。

## 执行流程

### 1. 确认目标

从用户消息中提取：
- **agent 名称**：默认 `wok-autopilot`，用户指定其他则使用指定值
- **system-name**：用户指定的 system-name 或部分名称

### 2. 解析 system-name

1. 列出 `.wok-plans/` 下所有目录
2. 用户已指定 → 直接匹配
3. 未指定 → 列出所有系统供用户选择

### 3. 检查计划状态

读取 `_plan.md`，报告：
- 总 step 数 vs 未完成 step 数
- 是否有 `_review.md`（之前运行过）

### 4. 构建命令

```
claude --agent <agent-name> <system-name>
```

### 5. 输出

```
🚀 Agent 启动命令

📋 系统: <system-name>
📊 计划: <N> steps, <M> 待完成
🤖 Agent: <agent-name> (model: sonnet)

复制以下命令到新终端运行:

claude --agent wok-autopilot --model sonnet <system-name>
```

如果用户当前终端可以运行，直接提供命令。如果用户在 Claude Code TUI 内，提示先退出当前会话（输入空行后 Ctrl+C）再运行。
