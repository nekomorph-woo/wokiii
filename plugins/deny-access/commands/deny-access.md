---
name: deny-access
description: 管理 Claude Code 文件排除规则，同步维护所有工具层的 deny 配置。Use when 用户要求保护敏感文件、添加/移除 deny 规则、排除 .env/secrets 等文件、或提到 "deny access" / "文件保护" / "排除文件"。
---

执行 [deny-access 技能](../skills/deny-access/SKILL.md) 的完整流程。

**定位技能文件**：

1. 使用 Bash 执行：
   ```bash
   ls ~/.claude/plugins/cache/ddai/deny-access/*/skills/deny-access/SKILL.md
   ```

2. 使用 Read 工具读取输出的路径

3. 执行技能文件中的所有指令
