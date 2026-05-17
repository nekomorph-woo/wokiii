#!/bin/bash

# deploy.sh - 部署 wok dashboard 到 feature 目录
# 用法: deploy.sh <feature-name>

set -e

FEATURE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../assets"
WOK_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

if [ -z "$FEATURE_NAME" ]; then
    echo "错误: 缺少 feature 名称"
    echo "用法: deploy.sh <feature-name>"
    exit 1
fi

FEATURE_DIR="$WOK_ROOT/plans/$FEATURE_NAME"

if [ ! -d "$FEATURE_DIR" ]; then
    echo "错误: feature 目录不存在: $FEATURE_DIR"
    exit 1
fi

# 防覆盖检查
for file in _dashboard.html _render.js _style.css; do
    if [ -f "$FEATURE_DIR/$file" ]; then
        echo "错误: 目标文件已存在: $FEATURE_DIR/$file"
        echo "如需重新部署，先删除现有文件"
        exit 1
    fi
done

# 复制 assets
cp "$ASSETS_DIR/dashboard.html" "$FEATURE_DIR/_dashboard.html"
cp "$ASSETS_DIR/render.js" "$FEATURE_DIR/_render.js"
cp "$ASSETS_DIR/style.css" "$FEATURE_DIR/_style.css"

# 注入 FEATURE_NAME
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" "$FEATURE_DIR/_dashboard.html"
    sed -i '' "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" "$FEATURE_DIR/_render.js"
else
    sed -i "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" "$FEATURE_DIR/_dashboard.html"
    sed -i "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" "$FEATURE_DIR/_render.js"
fi

echo "✓ Dashboard 已部署到: $FEATURE_DIR"
echo ""
echo "打开方式:"
echo "  open $FEATURE_DIR/_dashboard.html"
