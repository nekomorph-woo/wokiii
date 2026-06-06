---
name: wok-setup-zzap
description: >
  扫描项目版本文件，生成定制的 zzap 技能，集成规范化提交、版本自动升级和可选的 CHANGELOG。
  Use when 用户要求初始化 zzap、创建项目提交技能、或提到 "wok-setup-zzap" / "初始化 zzap"。
pipeline:
  upstream: []
  downstream: []
  gate: false
  output: none
  adaptive: false
---

# 初始化 zzap 版本管理技能

扫描项目版本文件，生成定制的 `zzap` 项目级技能。

## 职责

| # | 职责 | 说明 |
|---|------|------|
| 1 | 初始化 | 扫描版本文件、询问配置、生成 zzap |
| 2 | 更新 | 修改 zzap 配置（版本文件、功能开关） |
| 3 | 移除 | 删除 zzap 技能 |

## 流程

### 0. 判断意图

根据上下文判断：初始化 / 更新 / 移除。意图不明确时询问用户。

### 1. 初始化

#### 1.1 扫描版本文件

按优先级检测以下文件（使用 `ls` 检查存在性 + Read 读取内容）：

| 文件 | 字段路径 | 提取方式 |
|------|----------|----------|
| `package.json` | `.version` | `jq .version` 或 Read JSON |
| `Cargo.toml` | `[package].version` | `grep '^version'` |
| `pyproject.toml` | `[project].version` | `grep 'version'` |
| `pubspec.yaml` | `version:` | `grep 'version:'` |
| `build.gradle(.kts)` | `version = "..."` | `grep 'version'` |
| `pom.xml` | `<version>` | `grep '<version>'` |
| `*.csproj` | `<Version>` | `find + grep` |
| `VERSION` | 整行 | Read |
| `version.txt` | 整行 | Read |

对每个找到的文件记录：
- `path`：相对项目根的路径
- `field_path`：版本字段路径
- `current_version`：当前版本字符串
- `format`：`bare`（`1.0.0`）或 `v-prefixed`（`v1.0.0`）

**版本号规范化**：两段式版本（如 `1.0`）自动转为三段式（`1.0.0`）。检测到两段式时提示用户并将规范化后的版本写回文件。

**未检测到任何版本文件**：询问用户提供版本文件路径和字段名。

#### 1.2 询问配置

使用两个 AskUserQuestion：

**Q1：CHANGELOG**

```json
{
  "question": "是否自动维护 CHANGELOG.html？",
  "header": "CHANGELOG",
  "options": [
    {"label": "启用", "description": "每次提交自动更新 CHANGELOG.html"},
    {"label": "不启用", "description": "不维护 CHANGELOG"}
  ],
  "multiSelect": false
}
```

**Q2：版本发布资料整理**

```json
{
  "question": "是否启用版本发布资料整理？（自动创建 PR、打 TAG、整理发布说明）",
  "header": "发布流程",
  "options": [
    {"label": "启用", "description": "版本发布时自动创建 PR、合并、打 TAG（CHANGELOG 自动启用）"},
    {"label": "不启用", "description": "不自动执行发布流程"}
  ],
  "multiSelect": false
}
```

启用版本发布资料整理时，**自动强制 CHANGELOG 启用**，覆盖 Q1 的答案。

#### 1.3 生成 zzap 技能

1. 读取 `reference/zzap-template.md`
2. 替换占位符：

| 占位符 | 替换为 |
|--------|--------|
| `{{VERSION_FILES_TABLE}}` | 版本文件表格行，格式：`\| <path> \| <field_path> \| <format> \|` |
| `{{ENABLE_CHANGELOG}}` | `启用` 或 `不启用` |
| `{{ENABLE_RELEASE}}` | `启用` 或 `不启用` |

3. 写入 `<project>/.claude/skills/zzap/SKILL.md`（如目录不存在先 `mkdir -p`）

#### 1.4 输出确认

```
✅ zzap 技能已生成

版本文件:
- <path> (<field_path>): <version> [<format>]

配置:
- CHANGELOG: ✅ 启用 / ❌ 不启用
- 版本发布资料整理: ✅ 启用 / ❌ 不启用

使用 /zzap 执行智能提交
```

### 2. 更新

触发条件：版本文件变更、功能开关调整。

1. 读取当前 `.claude/skills/zzap/SKILL.md` 的配置
2. 询问需要更新的项目
3. 重新执行扫描（版本文件）或调整开关
4. 重新生成 zzap SKILL.md
5. 输出变更对比

### 3. 移除

1. 确认 `.claude/skills/zzap/` 存在
2. 询问用户确认
3. 删除 `.claude/skills/zzap/` 目录
4. 输出移除确认

## 参考材料

- [zzap-template.md](reference/zzap-template.md) — zzap 技能模板
