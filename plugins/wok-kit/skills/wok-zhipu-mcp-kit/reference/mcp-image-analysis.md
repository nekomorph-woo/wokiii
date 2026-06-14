# MCP 图片识别流程

调用 zai-mcp-server 的图片识别工具（`analyze_image` / `analyze_data_visualization` / `ui_to_artifact` 等）时，**优先使用 helper 脚本**，绕开 LLM 上下文 cap 和 Claude Code 默认 CDN 压缩。

## 问题背景

两条上传路径画质差异显著：

| 上传路径 | 画质 | 触发方式 |
|----------|------|----------|
| Claude Code 默认 CDN | 差（压缩） | `Read` 工具读图片、`echo "data:image/png;base64,..."` 输出 |
| MCP 服务自身 CDN | 高清（原始） | MCP server 收到本地路径或 data URL 后自行上传 |

**附加问题**：直接把 base64 data URL 写到 MCP 工具调用的 `image_source` 参数时，LLM 必须先在上下文中持有完整 base64。但 Read/Bash 工具输出有 ~25-30k token cap，超 100KB 的图片必然截断。

## 解决方案：helper 脚本通过 stdio 直连 MCP server

`~/.claude/scripts/mcp-analyze-image.py` 启动 MCP server 子进程，用 JSON-RPC over stdio 把图片路径发给 server。base64 永远不进入 LLM 上下文：

```
LLM ─[bash 命令]─► helper.py ─[stdio JSON-RPC]─► zai-mcp-server
                   读 /tmp/x.png        自己读文件、上传高清 CDN
```

## 核心规则

调用 MCP 图片识别工具时：

- **ALWAYS** 优先用 `~/.claude/scripts/mcp-analyze-image.py` 调用
- **DO NOT** 用 `Read` 工具读图片后获得的 CDN URL（画质被压缩）
- **DO NOT** 用 `echo "data:image/png;base64,..."` 的 stdout 输出（被 Claude Code hook 拦截转成默认 CDN）
- **DO NOT** 在 MCP 工具调用的 `image_source` 直接写完整 base64 data URL（超 100KB 必被 cap 截断）

## 完整流程

### 1. 截图

```bash
bb-browser screenshot --url "<page-url>" --output /tmp/verify-<name>.png
```

如需先导航：

```bash
bb-browser open --url "<page-url>"
sleep 3
bb-browser screenshot
```

### 2. 通过 helper 调用 MCP

```bash
python3 ~/.claude/scripts/mcp-analyze-image.py \
  --file /tmp/verify-<name>.png \
  --prompt "<具体的识别提示词>"
```

识别结果输出到 stdout，进入 LLM 上下文。

### 3. 其他图片识别工具

`zai-mcp-server` 暴露多种图片工具，用 `--tool` 切换：

| 工具 | 用途 |
|------|------|
| `analyze_image` | 通用图片识别（默认） |
| `analyze_data_visualization` | 数据可视化、图表、仪表盘 |
| `extract_text_from_screenshot` | 截图 OCR |
| `diagnose_error_screenshot` | 错误截图诊断 |
| `understand_technical_diagram` | 技术架构图、流程图、UML |
| `ui_to_artifact` | UI 截图转代码 |
| `ui_diff_check` | UI 设计对比 |
| `analyze_video` | 视频分析（用 `video_source` 参数，本脚本未适配） |

例：

```bash
python3 ~/.claude/scripts/mcp-analyze-image.py \
  --file /tmp/chart.png \
  --tool analyze_data_visualization \
  --prompt "提取关键趋势和异常"
```

### 4. fallback：当 server 不支持本地路径

某些 MCP server 可能拒绝本地路径，加 `--base64` 强制转 data URL（仍在 helper 子进程内完成，不进入 LLM 上下文）：

```bash
python3 ~/.claude/scripts/mcp-analyze-image.py \
  --file /tmp/x.png \
  --base64 \
  --prompt "..."
```

### 5. 清理截图

```bash
rm /tmp/verify-<name>.png
```

bb-browser 自动生成的截图（`/var/folders/.../bb-screenshot-*.png`）也一并清理。

## helper 实现要点

- 从 `~/.claude.json` 读 `mcpServers.<server>` 配置（command/args/env），不硬编码 API key
- 启动 MCP server 子进程，stdin/stdout 用 JSON-RPC 2.0 通信
- 默认把文件**路径**作为 `image_source` 传给 server（zai-mcp-server 自己读文件、上传高清 CDN）
- `--base64` 时 helper 内部转 data URL，base64 永不进入 LLM 上下文
- 输出：识别结果到 stdout，错误到 stderr，退出码反映错误类型

## 为什么 PreToolUse hook 不能解决

PreToolUse hook 的 JSON 输出只有 `permissionDecision: allow/deny/ask`，**不支持修改工具参数**（无 `modifiedToolInput` 字段）。所以无法在 LLM 调用 MCP 工具时把 `file://` 自动替换成 base64。Helper 脚本是唯一干净的绕过方案。
