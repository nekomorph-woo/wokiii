#!/usr/bin/env python3
"""PostToolUse hook: 追踪 Edit/Write 文件变更到变更日志。

autopilot 用此日志验证 impl subagent 是否实际修改了预期文件。
仅追踪代码文件变更，忽略 .wok-plans/ 下的管道文档。

部署位置: <phase-dir>/.hooks/track-changes.py
通过 __file__ 推导日志目录，无需扫描 .wok-plans/。
"""
import json
import sys
import os


def main():
    try:
        data = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        return

    tool_name = data.get("tool_name", "")
    if tool_name not in ("Edit", "Write"):
        return

    tool_input = data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    if not file_path:
        return

    # 忽略管道文档变更
    if ".wok-plans/" in file_path:
        return

    # 脚本部署在 <phase-dir>/.hooks/ 下，日志写同目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    log_file = os.path.join(script_dir, "changes.log")
    with open(log_file, "a") as f:
        f.write(f"{tool_name}|{file_path}\n")


if __name__ == "__main__":
    main()
