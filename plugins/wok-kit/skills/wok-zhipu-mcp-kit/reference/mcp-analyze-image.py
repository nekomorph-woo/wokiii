#!/usr/bin/env python3
"""Bridge script: call MCP server image-analysis tools via stdio JSON-RPC.

Bypasses two limitations of calling MCP image tools directly from Claude Code:
1. LLM context-window cap on tool-call arguments (base64 too large to embed)
2. Default Read/Bash CDN compression degrading image quality

The script spawns the MCP server as a child process and sends tools/call with
the file path (the zai-mcp-server reads the file itself and uploads to its own
high-fidelity CDN). The LLM only sees a short bash command in its context.

Usage:
    mcp-analyze-image.py --file /tmp/x.png --prompt "describe layout"
    mcp-analyze-image.py --file /tmp/x.png --prompt "..." --tool analyze_data_visualization
    mcp-analyze-image.py --file /tmp/x.png --prompt "..." --base64
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import time
from pathlib import Path

MIME_BY_EXT = {
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".bmp": "image/bmp",
}

DEFAULT_SERVER = "zai-mcp-server"
DEFAULT_TOOL = "analyze_image"
INIT_TIMEOUT = 30
CALL_TIMEOUT = 180


def load_mcp_server_config(server_name: str) -> dict:
    config_path = Path.home() / ".claude.json"
    if not config_path.is_file():
        sys.stderr.write(f"error: {config_path} not found\n")
        sys.exit(2)
    with config_path.open() as f:
        cfg = json.load(f)
    servers = cfg.get("mcpServers", {}) or {}
    if server_name not in servers:
        sys.stderr.write(
            f"error: server '{server_name}' not in mcpServers. "
            f"available: {list(servers)}\n"
        )
        sys.exit(2)
    server_cfg = servers[server_name]
    if server_cfg.get("type", "stdio") != "stdio":
        sys.stderr.write(
            f"error: server '{server_name}' is not stdio type "
            f"(got: {server_cfg.get('type')})\n"
        )
        sys.exit(2)
    return server_cfg


def resolve_image_source(file_path: Path, force_base64: bool) -> str:
    if not file_path.is_file():
        sys.stderr.write(f"error: file not found: {file_path}\n")
        sys.exit(1)
    if force_base64:
        mime = MIME_BY_EXT.get(file_path.suffix.lower(), "image/png")
        data = file_path.read_bytes()
        b64 = base64.b64encode(data).decode("ascii")
        return f"data:{mime};base64,{b64}"
    return str(file_path)


class McpStdioClient:
    """Minimal JSON-RPC 2.0 over stdio client for MCP servers."""

    def __init__(self, command: str, args: list, env: dict):
        self.proc = subprocess.Popen(
            [command, *args],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env={**os.environ, **env},
            bufsize=0,
        )
        self._next_id = 1

    def _send(self, payload: dict) -> None:
        line = (json.dumps(payload) + "\n").encode("utf-8")
        assert self.proc.stdin is not None
        self.proc.stdin.write(line)
        self.proc.stdin.flush()

    def _recv(self, timeout: float):
        import select

        end = time.time() + timeout
        while True:
            remaining = end - time.time()
            if remaining <= 0:
                return None
            assert self.proc.stdout is not None
            fd = self.proc.stdout.fileno()
            ready, _, _ = select.select([fd], [], [], remaining)
            if not ready:
                return None
            line = self.proc.stdout.readline()
            if not line:
                return None
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
            except json.JSONDecodeError:
                continue
            if "id" in msg:
                return msg

    def call(self, method: str, params: dict | None = None, timeout: float = 30.0) -> dict:
        req_id = self._next_id
        self._next_id += 1
        payload = {"jsonrpc": "2.0", "id": req_id, "method": method}
        if params is not None:
            payload["params"] = params
        self._send(payload)
        while True:
            resp = self._recv(timeout)
            if resp is None:
                raise TimeoutError(
                    f"no response for {method} (id={req_id}) within {timeout}s"
                )
            if resp.get("id") == req_id:
                if "error" in resp:
                    raise RuntimeError(f"MCP error: {json.dumps(resp['error'])}")
                return resp.get("result", {})

    def notify(self, method: str, params: dict | None = None) -> None:
        payload: dict = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            payload["params"] = params
        self._send(payload)

    def close(self) -> None:
        try:
            if self.proc.stdin is not None:
                self.proc.stdin.close()
        except Exception:
            pass
        try:
            self.proc.wait(timeout=5)
        except Exception:
            self.proc.kill()


def extract_text_from_result(result: dict) -> str:
    content = result.get("content") or []
    parts = []
    for item in content:
        if isinstance(item, dict) and item.get("type") == "text":
            parts.append(item.get("text", ""))
        elif isinstance(item, str):
            parts.append(item)
    return "\n".join(p for p in parts if p)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Call MCP analyze_image via stdio, bypassing LLM context cap"
    )
    parser.add_argument("--file", required=True, help="path to the image file")
    parser.add_argument("--prompt", required=True, help="recognition prompt")
    parser.add_argument(
        "--tool", default=DEFAULT_TOOL, help=f"MCP tool name (default: {DEFAULT_TOOL})"
    )
    parser.add_argument(
        "--server",
        default=DEFAULT_SERVER,
        help=f"MCP server name in ~/.claude.json (default: {DEFAULT_SERVER})",
    )
    parser.add_argument(
        "--base64",
        action="store_true",
        help="force base64 data URL instead of passing the file path "
        "(use only when the server rejects local paths)",
    )
    parser.add_argument(
        "--server-arg",
        action="append",
        default=[],
        help="extra args appended to the MCP server command (rarely needed)",
    )
    args = parser.parse_args()

    file_path = Path(args.file).expanduser().resolve()
    image_source = resolve_image_source(file_path, args.base64)

    server_cfg = load_mcp_server_config(args.server)
    command = server_cfg.get("command")
    if not command:
        sys.stderr.write(f"error: server '{args.server}' missing 'command'\n")
        return 2
    base_args = server_cfg.get("args", []) or []
    full_args = base_args + (args.server_arg or [])
    env = server_cfg.get("env", {}) or {}

    client = McpStdioClient(command, full_args, env)
    try:
        try:
            client.call(
                "initialize",
                {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {"name": "mcp-analyze-image", "version": "0.1.0"},
                },
                timeout=INIT_TIMEOUT,
            )
        except (TimeoutError, RuntimeError, subprocess.SubprocessError) as e:
            sys.stderr.write(f"error: initialize failed: {e}\n")
            stderr_data = b""
            if client.proc.stderr is not None:
                try:
                    stderr_data = client.proc.stderr.read()
                except Exception:
                    pass
            if stderr_data:
                sys.stderr.write(
                    f"--- server stderr ---\n{stderr_data.decode('utf-8', 'replace')}\n"
                )
            return 3

        client.notify("notifications/initialized", {})

        try:
            result = client.call(
                "tools/call",
                {
                    "name": args.tool,
                    "arguments": {"image_source": image_source, "prompt": args.prompt},
                },
                timeout=CALL_TIMEOUT,
            )
        except (TimeoutError, RuntimeError) as e:
            sys.stderr.write(f"error: tools/call failed: {e}\n")
            return 4

        text = extract_text_from_result(result)
        if not text:
            sys.stderr.write(f"warning: empty result, raw: {json.dumps(result)}\n")
            return 5

        sys.stdout.write(text)
        if not text.endswith("\n"):
            sys.stdout.write("\n")
        return 0
    finally:
        client.close()


if __name__ == "__main__":
    sys.exit(main())
