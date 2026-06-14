# wok

为 Claude Code / Cursor CLI 设计的技能插件市场。

## 安装

添加 marketplace：

```
/plugin marketplace add nekomorph-woo/wokiii
```

安装插件：

```
/plugin install wok@wok
/plugin install wok-kit@wok
```

更新：

```
/plugin marketplace update wok
```

## 项目初始化

安装插件后，在新项目中按以下步骤初始化 wok 环境。每步完成后即可使用对应能力，全部完成可解锁完整管道体验。

### 初始化流程

```
wok-starter           部署 rules + .gitignore
       │
       ├── wok-ontology     蒸馏方法论为行为规则
       ├── wok-tech-stack   按平台初始化技术栈规则
       └── wok-access-hold  保护敏感文件
       │
wok-setup-zzap        生成项目级提交 + 版本管理技能
       │
wok-refine-rule       （可选）审计规则质量与冲突
```

- `wok-starter` 是所有初始化的第一步
- `wok-ontology`、`wok-tech-stack`、`wok-access-hold` 三者无顺序依赖，按需选择
- `wok-setup-zzap` 在上述规则就绪后运行，确保生成的版本管理技能与项目配置一致

### 各步骤说明

| 步骤 | 做什么 | 跳过的后果 |
|------|--------|-----------|
| **wok-starter** | 部署 .claude/rules/ 规则文件、配置 .gitignore | 管道缺乏编码规范约束，提交可能包含临时文件 |
| **wok-ontology** | 将开发方法论蒸馏为阶段性行为规则 | implement 等技能缺乏方法论指导，实现风格漂移 |
| **wok-tech-stack** | 按目标平台（桌面/移动/Web）初始化技术选型、目录结构规则 | 设计和实现阶段缺乏技术约束，产出不一致 |
| **wok-access-hold** | 配置 .env/secrets 等文件的排除规则 | 敏感文件可能被读取或提交 |
| **wok-setup-zzap** | 生成定制的提交 + 版本升级 + CHANGELOG 技能 | 使用通用 zap 代替，缺少项目特定的版本文件检测 |
| **wok-refine-rule** | 五维度评估规则质量，审计规则间冲突 | 规则可能存在冲突或低质量指令 |

### 最小初始化

快速试用 wok，执行前两步即可开始：

```
/wok-starter
/wok-ontology
```

此时管道技能已可用。后续随时补充其他初始化步骤。

### 进阶初始化

| 场景 | 补充步骤 |
|------|---------|
| 想让 AI 学习个人编码习惯 | `wok-distill-session` — 分析近 7 日会话日志，提取习惯生成 rules |
| 需要交接工作给下一个 session | `wok-handoff` — 生成结构化交接文档 |
| 想创建项目专属技能 | `write-a-skill` — 引导创建符合规范的技能 |

## 开发管道

初始化完成后，通过以下管道技能驱动开发：

```
wok-intake           非管道对话成果 → 接入 wok 管道（调度模式）
       │
       ▼
wok-idea             灵感发散 + 路线图规划
       │
wok-findings         探索代码现状基线
       │
wok-define           定义做什么
       │
wok-design           拆模块 + 设计接口
       │
wok-design-review    交叉验证一致性
       │
wok-plan             翻译为编码步骤
       │
wok-implement        TDD 驱动开发
       │
wok-code-review      多 agent 并行代码审查
       │
wok-cr-insight       审查洞察与根因分析
       │
zap                  规范化提交
```

每个技能可独立使用，不需要走完整管道。

**`wok-intake`** 是特殊入口：在普通对话或 Plan Mode 完成探索/设计后，反向接入 wok 管道，推理候选管道（feat-/feat-s-/fix-/exp-）让用户选择，调度下游 skill 生成对应文档（仅到 wok-plan 之前）。代码审查不通过 intake 接入，直接用 `/wok-code-review`。

### 多入口路径

| 前缀 | 路径 | 适用场景 |
|------|------|---------|
| `feat-` | idea → define → design → ... → cr-insight | 大型功能，完整管道 |
| `feat-s-` | define → implement → code-review → cr-insight | 小功能，跳过设计阶段 |
| `fix-` | issue → implement → code-review → cr-insight | Bug 修复 |
| `exp-` | findings → (分支到上述路径) | 代码探索 |
| `cr-` | code-review → cr-insight | 独立代码审查 |

### Autopilot 自动执行

计划审批后，启动 Goal-Driven 自动执行引擎：

```bash
# Claude Code
claude --agent wok-autopilot --model sonnet <system-name>

# Cursor CLI
agent                    # 打开 TUI
/wok-autopilot <system-name>  # slash command 启动
```

Autopilot 驱动 implement → code-review → cr-insight 循环直到收敛，遇到 🔴 无法自动修复时 handoff 通知用户介入。

## 插件结构

```
wok/
├── plugins/
│   ├── wok/                          # 管道核心
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/                   # 17 个管道 + 辅助技能
│   │   ├── agents/                   # 5 个审查 agent + 1 个 autopilot agent
│   │   └── scripts/                  # 系统级脚本
│   └── wok-kit/                      # 辅助工具集
│       ├── .claude-plugin/plugin.json
│       └── skills/                   # 12 个工具技能
├── .claude/
│   ├── rules/                        # 项目规则
│   └── skills/                       # 项目内部技能
│       ├── write-wok-skill/          # 插件编写指南
│       ├── wok-commit/               # 提交规范 + 自动版本升级
│       └── wok-manage-version/       # 版本管理
├── .claude-plugin/
│   └── marketplace.json              # 插件市场注册
├── CLAUDE.md
└── README.md
```

## 技能一览

### 管道技能（wok）

| 技能 | 做什么 |
|------|--------|
| `wok-intake` | 非管道对话成果反向接入 wok 管道（调度模式，仅到 wok-plan 之前） |
| `wok-idea` | 发散功能想法，设计版本化路线图 |
| `wok-findings` | 探索现有代码的设计约束与架构模式 |
| `wok-define` | 定义 What：问题、目标、设计锚点、验收标准 |
| `wok-design` | 拆模块、设计接口、记录设计决策 |
| `wok-design-review` | 交叉验证模块设计的一致性和完整性 |
| `wok-plan` | 将模块设计翻译为编码执行计划 |
| `wok-implement` | TDD 驱动开发（RED-GREEN-REFACTOR） |
| `wok-code-review` | 多 agent 并行代码审查，自动修复 🔴🟠 问题 |
| `wok-cr-insight` | 分析审查报告 🟡 Advisory 根因，追加修改方案 |
| `wok-issue` | 调查问题根因，创建带 TDD 修复计划的 issue |

### 辅助技能（wok）

| 技能 | 做什么 |
|------|--------|
| `wok-grill-me` | 对计划/设计进行系统性追问和压力测试 |
| `wok-make-interface` | 生成多个差异显著的模块接口设计方案 |
| `wok-simplify` | 检测并修复嵌套过深、过度防御、冗余等 7 个维度 |
| `wok-apply-remarks` | 处理 pipeline 备注，修改文档并传播影响 |
| `wok-distill-session` | 分析会话日志，提取编码习惯生成 rules |
| `wok-dashboard` | 部署交互式文档 dashboard，可视化阅读管道产出 |

### 工具技能（wok-kit）

| 技能 | 做什么 |
|------|--------|
| `zap` | 规范化 commit message，关联 issue |
| `wok-handoff` | 生成结构化交接文档，供下一个 session 接续 |
| `wok-run` | 构建 agent 启动命令，支持 Claude Code / Cursor CLI |
| `wok-refine-rule` | 管理 rules 配置：初始化、评估、改进、审计 |
| `wok-starter` | 项目初始化：部署 rules + 配置 .gitignore |
| `wok-access-hold` | 管理文件排除规则，保护敏感文件 |
| `write-a-skill` | 创建符合规范的新技能 |
| `wok-ontology` | 本体论规则管理：蒸馏方法论为可执行规则注入 .claude/rules/ |
| `wok-tech-stack` | 技术栈规则管理：按平台选型初始化技术栈规则 |
| `wok-setup-zzap` | 初始化项目级 zzap 技能：自动版本管理 + CHANGELOG + 发布流程 |
| `wok-ui-design` | 多端 UI 设计工作流：设计系统生成 → 各端原型 → MD3 合规审计 |
| `wok-zhipu-mcp-kit` | 管理 zhipu MCP 配套文件（helper + 规则），bundle 化同步增删改 |

### 审查 Agent（wok）

| Agent | 职责 |
|-------|------|
| `wok-autopilot` | Goal-Driven 管道自动执行引擎 |
| `code-reviewer` | 5 维度代码审查（正确性/可维护性/性能/安全/测试） |
| `silent-failure-hunter` | 静默失败检测（未处理错误/竞态/资源泄漏） |
| `comment-analyzer` | 注释准确性分析（代码与注释不一致） |
| `pr-test-analyzer` | 测试质量审查（覆盖/边界/mock/断言） |
| `type-design-analyzer` | 类型设计审查（类型安全/泛型/类型推导） |

## 贡献

- [write-wok-skill](/.claude/skills/write-wok-skill/) — 插件编写规范
- [CLAUDE.md](/CLAUDE.md) — 语气措辞规范

## License

MIT
