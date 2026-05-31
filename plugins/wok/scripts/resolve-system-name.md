# system-name 解析流程

将用户输入的 system-name（缩写、部分名称、全称）解析为 `wok-plans/` 下的完整目录名。

## 命令

```bash
bash ~/.claude/wok/resolve-system-name.sh <input>
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

1. **精确匹配** — 输入恰好是 `wok-plans/` 下的目录名
2. **缩写匹配** — 按上表规则展开后匹配
3. **模糊匹配** — 输入是目录名的子串

## 输出处理

| 输出 | 处理 |
|------|------|
| 单行名称 | 唯一匹配，直接使用 |
| `AMBIGUOUS:` + 多行 | 用 AskUserQuestion 让用户从列表选择 |
| `NOT_FOUND: <input>` | 询问用户提供完整名称 |
| 无参数调用（列出全部目录） | 用 AskUserQuestion 让用户选择 |

## 调用时机

- 用户提供 system-name 或部分名称时 → 传入用户输入
- 上下文已有明确 system-name → 跳过解析，直接使用
- 无上下文无输入 → 无参数调用，列出所有目录供选择
