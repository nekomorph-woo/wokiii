#!/usr/bin/env bash
# manage.sh - 管理 zhipu MCP 配套文件（按 bundle 分组）
#
# 每个 bundle 定义在 bundles/<id>.json 中，包含：
#   - 一组配套文件（同改同增同删）
#   - 一组依赖项（MCP server / 工具 / 可执行命令等）
#   - 安装引导
#
# Usage:
#   manage.sh list                       列出所有 bundle
#   manage.sh detect <bundle-id>         检测 bundle 的依赖是否已安装
#   manage.sh install <bundle-id>        写入 bundle 的文件（任一已存在则失败）
#   manage.sh overwrite <bundle-id>      强制覆盖 bundle 的文件
#   manage.sh uninstall <bundle-id>      删除 bundle 的文件
#   manage.sh status <bundle-id>         查看 bundle 状态

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../reference"
BUNDLES_DIR="$SCRIPT_DIR/../bundles"
CLAUDE_JSON="$HOME/.claude.json"

cmd="${1:-}"
if [[ -z "$cmd" ]]; then
    echo "Usage: manage.sh <list|detect|install|overwrite|uninstall|status> [bundle-id]" >&2
    exit 1
fi

# ── Bundle 操作（除 list 外都需要 bundle-id）───────────────────────────

if [[ "$cmd" != "list" ]]; then
    bundle_id="${2:-}"
    if [[ -z "$bundle_id" ]]; then
        echo "ERROR: 缺少 bundle-id 参数" >&2
        echo "可用 bundle:" >&2
        ls "$BUNDLES_DIR"/*.json 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.json$//' >&2
        exit 1
    fi
    bundle_file="$BUNDLES_DIR/$bundle_id.json"
    if [[ ! -f "$bundle_file" ]]; then
        echo "ERROR: bundle 不存在: $bundle_id" >&2
        exit 1
    fi
fi

# ── 依赖检测分发器 ─────────────────────────────────────────────────

# 检测单个 dependency，输出 INSTALLED / NOT_INSTALLED / UNKNOWN
detect_dependency() {
    local dep_type="$1" dep_name="$2"
    case "$dep_type" in
        mcp_server)
            if [[ -f "$CLAUDE_JSON" ]] && grep -q "\"$dep_name\"" "$CLAUDE_JSON"; then
                echo "INSTALLED"
            else
                echo "NOT_INSTALLED"
            fi
            ;;
        binary)
            if command -v "$dep_name" >/dev/null 2>&1; then
                echo "INSTALLED"
            else
                echo "NOT_INSTALLED"
            fi
            ;;
        *)
            echo "UNKNOWN_TYPE:$dep_type"
            ;;
    esac
}

# ── 子命令实现 ─────────────────────────────────────────────────────

case "$cmd" in
    list)
        echo "支持的配套组（bundles）："
        echo ""
        for f in "$BUNDLES_DIR"/*.json; do
            [[ -f "$f" ]] || continue
            python3 -c "
import json, sys
b = json.load(open('$f'))
print(f\"  [{b['id']}] {b['name']}\")
print(f\"    {b['description']}\")
print(f\"    文件 ({len(b.get('files', []))} 个):\")
for file in b.get('files', []):
    print(f\"      • {file['dest']} ({file['role']})\")
print(f\"    依赖 ({len(b.get('dependencies', []))} 项):\")
for dep in b.get('dependencies', []):
    print(f\"      • [{dep['type']}] {dep['name']}\")
print()
"
        done
        ;;

    detect)
        bundle_name=$(python3 -c "import json; print(json.load(open('$bundle_file'))['name'])")
        dep_count=$(python3 -c "import json; print(len(json.load(open('$bundle_file')).get('dependencies', [])))")
        echo "Bundle: $bundle_name [$bundle_id]（$dep_count 项依赖）"
        # 只输出 type|name 行给 while 处理，避免 header 干扰
        missing_list=""
        while IFS='|' read -r dep_type dep_name; do
            [[ -z "$dep_type" ]] && continue
            result=$(detect_dependency "$dep_type" "$dep_name")
            echo "  [$dep_type] $dep_name → $result"
            if [[ "$result" != "INSTALLED" ]]; then
                missing_list="${missing_list}${dep_type}:${dep_name}, "
            fi
        done < <(python3 -c "
import json
b = json.load(open('$bundle_file'))
for dep in b.get('dependencies', []):
    print(f\"{dep['type']}|{dep['name']}\")
")
        echo ""
        if [[ -z "$missing_list" ]]; then
            echo "RESULT: INSTALLED (全部依赖已就绪)"
        else
            echo "RESULT: NOT_INSTALLED (缺失: ${missing_list%, })"
        fi
        ;;

    install)
        # 任一目标文件已存在则失败
        existing=()
        while IFS= read -r dest; do
            dest_expanded=$(eval echo "$dest")
            if [[ -f "$dest_expanded" ]]; then
                existing+=("$dest_expanded")
            fi
        done < <(python3 -c "
import json
b = json.load(open('$bundle_file'))
for f in b.get('files', []):
    print(f['dest'])
")
        if [[ ${#existing[@]} -gt 0 ]]; then
            echo "ERROR: 配套文件已存在，请用 'overwrite' 覆盖或 'uninstall' 删除后重试" >&2
            for f in "${existing[@]}"; do
                echo "  - $f" >&2
            done
            exit 2
        fi
        # 复制所有文件
        python3 -c "
import json, os, shutil
b = json.load(open('$bundle_file'))
for f in b.get('files', []):
    src = '$TEMPLATE_DIR/' + os.path.basename(f['src'])
    if not os.path.exists(src):
        # 处理 src 是 reference/xxx 形式
        src = '$SCRIPT_DIR/../' + f['src']
    dest = os.path.expanduser(f['dest'])
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    shutil.copy2(src, dest)
    mode = int(f.get('mode', '0644'), 8)
    os.chmod(dest, mode)
    print(f'  wrote: {dest}')
"
        echo "OK: bundle [$bundle_id] 已安装"
        ;;

    overwrite)
        python3 -c "
import json, os, shutil
b = json.load(open('$bundle_file'))
for f in b.get('files', []):
    src = '$SCRIPT_DIR/../' + f['src']
    dest = os.path.expanduser(f['dest'])
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    shutil.copy2(src, dest)
    mode = int(f.get('mode', '0644'), 8)
    os.chmod(dest, mode)
    print(f'  wrote: {dest}')
"
        echo "OK: bundle [$bundle_id] 已覆盖"
        ;;

    uninstall)
        removed=0
        while IFS= read -r dest; do
            dest_expanded=$(eval echo "$dest")
            if [[ -f "$dest_expanded" ]]; then
                rm -f "$dest_expanded"
                echo "  removed: $dest_expanded"
                removed=1
            fi
        done < <(python3 -c "
import json
b = json.load(open('$bundle_file'))
for f in b.get('files', []):
    print(f['dest'])
")
        if [[ $removed -eq 0 ]]; then
            echo "OK: bundle [$bundle_id] 文件本就不存在"
        else
            echo "OK: bundle [$bundle_id] 已卸载"
        fi
        ;;

    status)
        echo "Bundle: $(python3 -c "import json; print(json.load(open('$bundle_file'))['name'])") [$bundle_id]"
        echo ""
        # 文件状态
        echo "配套文件:"
        python3 -c "
import json, os
b = json.load(open('$bundle_file'))
for f in b.get('files', []):
    dest = os.path.expanduser(f['dest'])
    if os.path.exists(dest):
        size = os.path.getsize(dest)
        with open(dest) as fh:
            lines = sum(1 for _ in fh)
        print(f\"  [存在] {dest} ({size} bytes, {lines} lines)\")
    else:
        print(f\"  [缺失] {dest}\")
"
        echo ""
        # 依赖状态
        echo "依赖:"
        while IFS='|' read -r dep_type dep_name; do
            result=$(detect_dependency "$dep_type" "$dep_name")
            echo "  [$dep_type] $dep_name → $result"
        done < <(python3 -c "
import json
b = json.load(open('$bundle_file'))
for dep in b.get('dependencies', []):
    print(f\"{dep['type']}|{dep['name']}\")
")
        ;;

    *)
        echo "Unknown command: $cmd" >&2
        echo "Usage: manage.sh <list|detect|install|overwrite|uninstall|status> [bundle-id]" >&2
        exit 1
        ;;
esac
