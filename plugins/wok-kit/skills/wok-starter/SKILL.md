---
name: wok-starter
description: 初始化项目的 wok 环境：部署 rules 规则文件、配置 .gitignore 忽略项。Use when 用户要求初始化 wok、首次使用 wok、或提到 "wok-starter" / "初始化" / "wok 初始化"。
---

# wok 初始化

初始化项目的 wok 环境，确保 rules 和 gitignore 就绪。

## 执行流程

### 1. 初始化 Rules

调用 `/wok-refine-rule` 初始化流程，将 reference 模板拷贝到 `.claude/rules/`。

若 `.claude/rules/` 下已有同名文件，跳过该文件（保留用户自定义内容）。

### 2. 配置 .gitignore

检测当前是否为 git 仓库（`git rev-parse --git-dir`）。

**是 git 仓库**：检查 `.gitignore` 中是否已包含以下条目，缺失则追加：

```
.wok-plans/
.wok-grill/
```

追加后按原格式保持 `.gitignore` 结构（若文件存在 `\n` 结尾则保持，无则不加多余空行）。

**非 git 仓库**：跳过此步骤。

### 3. 输出结果

```
✅ wok 初始化完成

Rules:
- ✅ 已创建 .claude/rules/coding-philosophy.md
- ✅ 已创建 .claude/rules/dialogue-style.md
- ⏭️ 已存在 .claude/rules/security.md（跳过）
- ...

.gitignore:
- ✅ 已添加 .wok-plans/
- ✅ 已添加 .wok-grill/
```

## 检查清单

- [ ] `.claude/rules/` 下至少创建了 1 个规则文件
- [ ] `.gitignore` 已包含 `.wok-plans/` 和 `.wok-grill/`（git 仓库时）
