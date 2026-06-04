#!/usr/bin/env python3
"""PostToolUse hook: 追踪 Edit/Write 文件变更到变更日志。

autopilot 用此日志验证 impl subagent 是否实际修改了预期文件。
仅追踪代码文件变更，忽略 .wok-plans/ 下的管道文档。
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

    cwd = data.get("cwd", os.getcwd())
    plans_dir = os.path.join(cwd, ".wok-plans")
    if not os.path.isdir(plans_dir):
        return

    # 找到包含 _plan.md 的活跃 system 目录
    for sub in os.listdir(plans_dir):
        sub_path = os.path.join(plans_dir, sub)
        if not os.path.isdir(sub_path):
            continue
        plan_file = os.path.join(sub_path, "_plan.md")
        if os.path.exists(plan_file):
            log_dir = os.path.join(sub_path, ".hooks")
            os.makedirs(log_dir, exist_ok=True)
            log_file = os.path.join(log_dir, "changes.log")
            with open(log_file, "a") as f:
                f.write(f"{tool_name}|{file_path}\n")
            return


if __name__ == "__main__":
    main()
