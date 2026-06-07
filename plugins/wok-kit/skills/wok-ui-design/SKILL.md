---
name: wok-ui-design
description: |
  多端 UI 设计工作流编排器。调用 hue 生成跨端统一设计系统，调用 hallmark 产出各端 UI 原型，调用 material-3-skill 执行 MD3 合规审计。设计系统完成后自动注入 design-token rule。支持从任意步骤进入和多次更换设计风格。依赖 hue / hallmark / material-3-skill。Use when 设计工作流、UI 设计流程、多端设计、设计系统生成、跨端 UI、design workflow、design-token rule。
---

# 多端 UI 设计工作流

从品牌种子数据到跨端统一设计系统，再到各端 UI 原型和 MD3 合规审计。

## 产物路径（固定）

更换设计风格时替换 `seed-input.md` 内容，路径不变，rule 定位不漂移。

```
.wok-ui-design/
├── ui-seed/                    ← 风格预览 HTML（Step 1 自动初始化）
├── seed-input.md               ← Step 1 种子数据
├── design-system/              ← Step 2 设计系统
│   ├── design-model.yaml       ← Token 真相源
│   ├── DESIGN.md               ← 设计规范
│   └── *.html                  ← 预览页
├── prototypes/                 ← Step 3 原型
│   ├── desktop/
│   ├── mobile/
│   └── web/
└── audit-report.md             ← Step 4 MD3 审计
```

## 工作流

### Step 0: 依赖检查

检查以下文件是否存在：
- `~/.claude/skills/hue/SKILL.md`
- `~/.claude/skills/hallmark/SKILL.md`
- `~/.claude/skills/material-3-skill/SKILL.md`

缺失时输出安装命令，询问用户降级继续或中止安装。

| Skill | 安装命令 | 用途 |
|-------|---------|------|
| hue | `git clone https://github.com/dominikmartn/hue ~/.claude/skills/hue` | 设计系统生成 |
| hallmark | `npx skills add nutlope/hallmark` | 反同质化原型生成 |
| material-3-skill | `git clone --depth 1 https://github.com/hamen/material-3-skill /tmp/m3s && cp -r /tmp/m3s/skills/material-3 ~/.claude/skills/material-3-skill && rm -rf /tmp/m3s` | MD3 合规审计 |

### Step 1: 风格选择与种子数据

**1.1 初始化 ui-seed**

检查 `.wok-ui-design/ui-seed/` 是否存在。不存在时将本 skill `reference/ui-seed/` 下的风格预览 HTML 复制到 `.wok-ui-design/ui-seed/`。

**1.2 了解产品定位**

向用户询问：
- 产品类型和目标用户
- 期望的情感基调（专业 / 温暖 / 科技 / 趣味 / 奢华 / 自然等）
- 目标平台

**1.3 推荐风格**

基于产品定位，从 `.wok-ui-design/ui-seed/` 中选出 5 个最适配的视觉风格。使用 AskUserQuestion 展示，每个选项包含：
- 风格名称（如 Soft Brutalism）
- 一句话描述该风格的核心视觉特征
- 预览文件路径（用户可在浏览器打开 `.wok-ui-design/ui-seed/<style>.html` 查看）

第 6 个选项固定为「自定义风格 — 自行描述设计方向」。

**1.4 确认种子数据**

用户选择风格后，基于所选风格的视觉特征填充 `.wok-ui-design/seed-input.md`。使用 [seed-input-template.md](reference/seed-input-template.md) 作为模板，将风格对应的颜色、字体、阴影、圆角、动效参数填入。

用户可在浏览器中打开预览确认后，微调 seed-input.md 中的具体 token 值。

### Step 2: 设计系统

调用 hue skill，传入种子数据。产出要求见 [design-system-spec.md](reference/design-system-spec.md)。

**Rule 注入**（自动执行）：完成后读取 `design-model.yaml`，基于 [design-token-rule-template.md](reference/design-token-rule-template.md) 生成 `.claude/rules/design-tokens.md`。后续开发将自动遵守此 rule。

展示验证门：产出文件清单 + 关键设计决策 + 品牌色/字体确认。用户确认后继续。

### Step 3: 原型

对每个核心页面，分别调用 hallmark 产出桌面端/移动端/Web 端原型。产出要求见 [prototype-guide.md](reference/prototype-guide.md)。

设备框：桌面端 macOS 1200×800px / 移动端 iPhone 15 Pro 393×852px / Web 端浏览器 1440×900px。

### Step 4: MD3 审计

调用 material-3-skill 对移动端原型执行 10 维度审计（0-10 分）。产出要求见 [md3-audit-guide.md](reference/md3-audit-guide.md)。

审计报告 MUST 标注**品牌保留偏离项** — 有意偏离 MD3 规范以保持品牌特征的设计决策。

## 进入方式

| 入口 | 前置条件 |
|------|---------|
| 完整流程 | 无（Step 1 自动初始化 ui-seed） |
| Step 2 开始 | 已有 `seed-input.md` |
| Step 3 开始 | 已有 `DESIGN.md` |
| Step 4 开始 | 已有移动端原型 |
| 重新设计 | 重新选择风格（Step 1.3）或替换 `seed-input.md` 后从 Step 2 重跑，rule 自动更新 |

## 检查清单

- [ ] 依赖检查通过（或用户选择降级）
- [ ] ui-seed/ 已初始化，用户已选择风格
- [ ] seed-input.md 已基于所选风格填写
- [ ] design-model.yaml + DESIGN.md 已生成
- [ ] `.claude/rules/design-tokens.md` 已注入
- [ ] 用户已确认设计方向（验证门）
- [ ] 各端原型已产出
- [ ] MD3 审计报告已生成，品牌保留项已标注
