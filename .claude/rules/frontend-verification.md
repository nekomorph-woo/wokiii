# 前端自验证

前端代码（HTML / CSS / JS / 渲染逻辑）编写完成后，使用 `bb-browser` CLI 截图并通过 MCP analyze_image 执行视觉验证，通过后再通知用户验收。

## 触发条件

以下任一条件满足时执行自验证流程：

- 修改了 `.html`、`.css`、`.js` 文件且影响页面渲染
- 修改了 dashboard / UI 组件的布局、样式、交互逻辑
- 新增或修改了前端模板、资源文件

以下场景**跳过**自验证：

- 纯后端逻辑、CLI 脚本、Markdown 文档
- 前端文件仅修改注释、变量命名，不影响渲染
- 无法通过 HTTP server 访问的静态页面（无本地 server）

## 自验证流程

### 1. 确认页面可访问

确保 dev server 或 HTTP server 已启动且页面可访问。

### 2. 截图与视觉验证

按 `mcp-image-analysis` 规则中的流程执行截图和 MCP 图片识别：

```bash
# 截取页面
bb-browser screenshot --url "<page-url>" --output /tmp/verify-<name>.png
```

验证要点：
- Tab 导航标签是否正确渲染
- 侧边栏导航项是否完整
- 内容区域标题和结构是否正确
- 布局是否与预期一致

### 3. DOM 结构验证（补充）

如需精确验证元素存在性和属性，使用 `bb-browser snapshot`：

```bash
# 获取整页 DOM 结构
bb-browser snapshot --url "<page-url>"

# 获取特定区域 DOM 结构
bb-browser snapshot --selector '.target-component'
```

### 4. 交互验证（如适用）

对有交互行为的组件，使用 `bb-browser click` / `bb-browser fill` 触发操作后截图确认：

```bash
bb-browser click <ref>
bb-browser screenshot
```

### 5. 修复与重测

发现问题立即修复代码，重新部署/刷新后再次验证，直到无可见缺陷。

### 6. 清理截图

验证完成后删除所有临时截图文件：

```bash
rm /tmp/verify-<name>.png
# 同时清理 bb-browser 自动生成的截图
rm /var/folders/*/T/bb-screenshot-*.png
```

### 7. 输出验证结论

通过后向用户报告验证结果：

```
✅ 前端自验证通过
- 页面: <URL>
- 验证项: <视觉/DOM 验证确认了哪些布局/交互>
- 修复记录: <过程中发现并修复的问题，无则省略>
```

验证未通过时，向用户说明具体问题和当前状态，不标记任务为 completed。
