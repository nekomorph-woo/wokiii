---
name: wok-zhipu-mcp-kit
description: 按 bundle（配套组）管理 zhipu MCP 相关的文件和依赖，每组配套文件同改同增同删，安装前自动检测 MCP server 是否已注册。Use when 用户要求管理 zhipu MCP 配套文件、安装/卸载/更新图片识别 helper、或提到 "zhipu mcp" / "图片识别 helper" / "MCP analyze_image helper" / "wok-zhipu-mcp-kit"。
---

# zhipu MCP 配套组管理

按 **bundle**（配套组）管理 zhipu MCP 相关文件和依赖。每个 bundle 包含一组配套文件（同改同增同删）和一组依赖项。

## 支持的配套组

| Bundle ID | 名称 | 配套文件 | 依赖 | 用途 |
|---|---|---|---|---|
| `image-analysis` | 图片识别增强 | helper 脚本 + 使用规则（2 个） | MCP server `zai-mcp-server` | 绕开 LLM 上下文 cap + Claude Code 默认 CDN 压缩 |

调用本 skill 时，**首先罗列上表**让用户看到支持哪些组、每组配套什么、依赖什么。

## Bundle 详情：image-analysis（图片识别增强）

**配套文件（同改同增同删）**：

| 配套 | 角色 | 安装位置 | 模板源 | 模式 |
|:---:|---|---|---|---|
| 🔗 | helper 脚本 | `~/.claude/scripts/mcp-analyze-image.py` | `reference/mcp-analyze-image.py` | 0755 |
| 🔗 | 使用规则 | `~/.claude/rules/mcp-image-analysis.md` | `reference/mcp-image-analysis.md` | 0644 |

🔗 标记的两个文件属于同一配套组，必须同步存在/修改/删除。

**依赖（install/overwrite 前必须就绪）**：

| 类型 | 名称 | 暴露工具 | 检测方式 |
|---|---|---|---|
| `mcp_server` | `zai-mcp-server` | `analyze_image` / `analyze_data_visualization` / `ui_to_artifact` 等 | 扫描 `~/.claude.json` 的 `mcpServers` |

**说明**：检测的是 **MCP server 名**（`zai-mcp-server`），不是工具名。server 注册后所有工具自动可用；如需精细检测某个工具是否暴露，需 spawn server 子进程走 `tools/list`，开销大，本 skill 不做。

## 工作流程

### 1. 罗列 bundle

```bash
bash "$SKILL_DIR/scripts/manage.sh" list
```

### 2. 选择 bundle

使用 AskUserQuestion 让用户选择要操作的 bundle（当前仅 `image-analysis`，未来可扩展）。

### 3. 检测依赖

```bash
bash "$SKILL_DIR/scripts/manage.sh" detect <bundle-id>
```

#### Case A: NOT_INSTALLED

显示该 bundle JSON 中 `dependencies[].install` 字段提供的安装引导：

```
⚠️ 未检测到依赖 [mcp_server] zai-mcp-server

CLI:
  claude mcp add zai-mcp-server -e Z_AI_API_KEY=<your-key> -- npx -y @z_ai/mcp-server

手动编辑 ~/.claude.json 的 mcpServers:
  {
    "zai-mcp-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@z_ai/mcp-server"],
      "env": {"Z_AI_API_KEY": "<your-key>"}
    }
  }

前置: API key 申请 https://open.bigmodel.cn/usercenter/proj-mgmt/apikey
```

退出，等待用户安装。

#### Case B: INSTALLED

继续询问操作：

```json
{
  "question": "依赖已就绪，对 bundle [<bundle-id>] 执行什么操作？",
  "header": "操作",
  "options": [
    {"label": "增加", "description": "从模板写入配套文件；任一已存在则报错，提示用「覆盖」"},
    {"label": "覆盖", "description": "强制覆盖现有配套文件"},
    {"label": "删除", "description": "移除配套文件（同删）"},
    {"label": "查看状态", "description": "只查看当前状态，不修改"}
  ],
  "multiSelect": false
}
```

### 4. 执行操作

```bash
bash "$SKILL_DIR/scripts/manage.sh" <install|overwrite|uninstall|status> <bundle-id>
```

退出码：0 成功；1 用法错误/bundle 不存在；2 文件已存在阻止 install。

## 配套原则（同改同增同删）

每个 bundle 内所有 `files` 作为整体处理：

| 操作 | 行为 |
|------|------|
| `install` | 任一目标已存在 → exit 2 阻止 |
| `overwrite` | 同时覆盖所有文件 |
| `uninstall` | 同时删除所有文件 |
| `status` | 同时显示所有文件 + 依赖状态 |

修改 bundle 内任一模板时，**必须同步修改同组其他模板**并跑通 `overwrite` 流程（参考 `~/.claude/rules/frontend-verification.md`）。

## 扩展新 bundle

1. 在 `bundles/` 新建 `<id>.json`（参考 `image-analysis.json` 结构）
2. 在 `reference/` 添加配套文件模板
3. JSON 中声明 `files` / `dependencies` / `install` 引导
4. `manage.sh list` 自动识别，**无需改脚本**

支持 `dependencies[].type`：`mcp_server`（检测 `~/.claude.json`）、`binary`（检测 PATH）。

## 约束

- **DO NOT** 在 manage.sh 硬编码 bundle 信息 — 全部从 `bundles/*.json` 读取
- **DO NOT** 单独操作 bundle 内某个文件 — 必须整组同步
- **DO NOT** 在依赖 NOT_INSTALLED 时执行 `install` / `overwrite` — 用户应先安装依赖
- **DO NOT** 在模板中硬编码 API key — helper 从 `~/.claude.json` 动态读取
- **DO NOT** 把检测目标写成工具名（如 `analyze_image`）— 用 server 名（`zai-mcp-server`），server 注册后工具自动可用
