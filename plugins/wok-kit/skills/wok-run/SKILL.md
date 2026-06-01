---
name: wok-run
description: >
  构建启动命令，帮助用户启动 wok-autopilot 或其他 agent。
  列出可用的 .wok-plans/ 系统，解析 system-name，根据运行环境输出对应的启动方式。
  Use when 用户要求启动 autopilot、运行 agent、或提到 "wok-run" / "启动" / "跑起来"。
---
# 构建 Agent 启动指令

帮助用户构建并运行 agent 启动命令，自动检测 Claude Code 或 Cursor CLI 环境。

## 执行流程

### 1. 确认目标

从用户消息中提取：

* **agent 名称**：默认 `wok-autopilot`，用户指定其他则使用指定值

* **system-name**：用户指定的 system-name 或部分名称

### 2. 解析 system-name

1. 检查 `.wok-plans/` 是否存在且非空，为空或不存在 → 提示用户先使用 wok 管道创建计划
2. 列出 `.wok-plans/` 下所有目录
3. 用户已指定 → 直接匹配
4. 未指定 → 列出所有系统供用户选择

### 3. 检查计划状态

读取 `_plan.md`，报告：

* 总 step 数 vs 未完成 step 数

* 是否有 `_review.md`（之前运行过）

### 4. 检测运行环境

通过以下方式判断当前环境：

1. 检查环境变量 `CLAUDE_CODE_SESSION` 或进程名是否包含为 `claude` → **Claude Code**
2. 检查环境变量 `CURSOR_AGENT_SESSION` 或进程名是否包含为 `agent` → **Cursor CLI**
3. 均无法判断 → **询问用户**

### 5. 输出启动指令

#### Claude Code 环境

```
🚀 Agent 启动命令

📋 系统: <system-name>
📊 计划: <N> steps, <M> 待完成
🤖 Agent: <agent-name>

在新终端运行:
claude --agent <agent-name> --model sonnet <system-name>
```

提示：agent 使用 `model: inherit`，`--model sonnet` 可替换为其他模型。

#### Cursor CLI 环境

```
🚀 Agent 启动指令

📋 系统: <system-name>
📊 计划: <N> steps, <M> 待完成
🤖 Agent: <agent-name>

在新终端运行:
1. agent
2. 在 TUI 中选择模型
3. 输入: /<agent-name> <system-name>
```

提示：agent 使用 `model: inherit`，继承 TUI 当前选择的模型。

#### 用户在 TUI 内执行

如果用户当前在 Claude Code TUI 或 Cursor TUI 内（非新终端），提示先退出当前会话再操作。
