# system-name 解析流程

将用户输入的 system-name（缩写、部分名称、全称）解析为 `.wok-plans/` 下的完整目录名或阶段路径。

## 命令

```bash
bash ~/.claude/wok/resolve-system-name.sh <input> [phase]
```

首次使用若脚本不存在，从插件缓存部署：

```bash
mkdir -p ~/.claude/wok && cp "$(find ~/.claude/plugins/cache/wok/wok -name resolve-system-name.sh -path '*/scripts/*' | sort -rV | head -1)" ~/.claude/wok/resolve-system-name.sh
```

## 缩写规则

管道前缀缩写（首尾字母）+ 功能词首字母：

| 全称 | 缩写 | 拆解 |
|------|------|------|
| `feat-smart-home-system` | `ft-shs` | ft + s·h·s |
| `feat-s-dark-mode` | `fts-dm` | fts + d·m |
| `fix-auth-token-expire` | `fx-ate` | fx + a·t·e |
| `exp-payment-module` | `ex-pm` | ex + p·m |
| `cr-api-refactor` | `cr-ar` | cr + a·r |

前缀映射：`feat` → `ft`，`feat-s` → `fts`，`fix` → `fx`，`exp` → `ex`，`cr` → `cr`。

## 解析优先级

1. **精确匹配** — 输入恰好是 `.wok-plans/` 下的目录名
2. **缩写匹配** — 按上表规则展开后匹配
3. **模糊匹配** — 输入是目录名的子串

## 阶段解析

当解析到包含 `_roadmap.md` 的系统时，自动进入阶段解析：

| 条件 | 行为 |
|------|------|
| 提供了 `[phase]` 参数 | 解析为 `system-name/phase-dir` |
| 系统只有一个 phase | 自动选择，输出 `system-name/phase-dir` |
| 系统有多个 phase 且未指定 | 输出 `PHASES:` + 阶段列表 |
| 使用 `--phases` 参数 | 输出阶段列表 |

### 阶段输入格式

| 输入 | 匹配规则 | 示例 |
|------|----------|------|
| `p1` | 阶段号前缀匹配 | p1 → p1-core-device |
| `1` | 纯数字匹配 | 1 → p1-core-device |
| `core` | 阶段名子串匹配 | core → p1-core-device |
| `p1-core-device` | 精确匹配 | 直接使用 |

### 跨系统阶段匹配

若 `<input>` 为裸阶段标识（`p1`、`p2-name` 等以 `p` + 数字开头），脚本在所有含 `_roadmap.md` 的系统中搜索匹配的 phase：

- 唯一匹配 → 输出 `system-name/phase-dir`
- 多个匹配 → `AMBIGUOUS:` + 列表

## 输出处理

| 输出 | 处理 |
|------|------|
| 单行名称（无斜杠） | 扁平系统，直接使用 |
| 单行路径（含斜杠） | 多阶段系统已解析，`system-name/phase-dir` |
| `PHASES:` + 多行 | 用 AskUserQuestion 让用户选择 phase，然后以选中的 phase 作为 `$2` 重新调用 |
| `AMBIGUOUS:` + 多行 | 用 AskUserQuestion 让用户选择 system |
| `AMBIGUOUS_PHASE:` + 多行 | 用 AskUserQuestion 让用户选择 phase |
| `NOT_FOUND: <input>` | 询问用户提供完整名称 |
| 无参数调用（列出全部目录） | 用 AskUserQuestion 让用户选择 |

## 调用时机

- 用户提供 system-name 或部分名称时 → 传入用户输入
- 上下文已有明确 system-name → 跳过解析，直接使用
- 无上下文无输入 → 无参数调用，列出所有目录供选择
- 多阶段系统需指定 phase → 传入 `system-name phase` 或 `--phases` 列出选项
