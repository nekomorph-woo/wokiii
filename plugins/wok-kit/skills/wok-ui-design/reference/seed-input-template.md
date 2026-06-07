# Brand Seed Input Template

> 填写以下各节，定义项目的设计方向。完成后保存为 `.wok-ui-design/seed-input.md`。

## 项目信息

- **产品名**:
- **定位**: （一句话产品描述）
- **目标平台**: （桌面端 / 移动端 / Web 端，标注具体技术栈）
- **用户画像**: （目标用户和使用场景）

## 设计方向关键词

### 核心风格

填写 2-3 个风格关键词（如 Soft Brutalism、Minimalist、Glassmorphism 等），描述期望的视觉语言。

### 情感基调

描述产品应该传递的情感（如「专业但不生硬」「有趣味性」「高效不紧张」）。

### 反模式

列出设计中应避免的模式（如「不用纯黑底+霓虹紫」「不用 Inter/Roboto 做唯一字体」）。

## 品牌色种子

### 主色

| 名称 | 色值 | 用途 |
|------|------|------|
| Primary | `#` | 主品牌色 |
| Secondary | `#` | 辅助品牌色 |
| Tertiary | `#` | 第三品牌色 |
| Accent | `#` | 强调色 |

### 语义色

| 名称 | 色值 | 用途 |
|------|------|------|
| Success | `#` | 成功状态 |
| Warning | `#` | 警告状态 |
| Error | `#` | 错误状态 |
| Info | `#` | 信息提示 |

### 表面色

| 名称 | 色值 | 用途 |
|------|------|------|
| Background | `#` | 页面底色 |
| Surface | `#` | 卡片/面板底色 |
| Surface High | `#` | 高亮表面 |

### 文字色

| 名称 | 色值 | 用途 |
|------|------|------|
| Primary | `#` | 主文字 |
| Secondary | `#` | 辅助文字 |
| Tertiary | `#` | 次要文字 |

### 边框与阴影

| 名称 | 色值 | 用途 |
|------|------|------|
| Border | `#` | 边框色 |
| Shadow | `#` | 阴影色 |
| Divider | `#` | 分割线 |

## 字体体系

| 角色 | 字体 | 理由 |
|------|------|------|
| 展示/标题 | | |
| 正文/标签 | | |
| 代码/值 | | |

## 字阶参考

| 级别 | 字号 | 字重 | 字体 |
|------|------|------|------|
| Display Large | 40px | w800 | |
| Display Medium | 32px | w700 | |
| Display Small | 28px | w700 | |
| Headline Large | 24px | w700 | |
| Headline Medium | 20px | w700 | |
| Headline Small | 18px | w600 | |
| Title Large | 18px | w700 | |
| Title Medium | 16px | w600 | |
| Title Small | 14px | w600 | |
| Body Large | 16px | w400 | |
| Body Medium | 14px | w400 | |
| Body Small | 12px | w400 | |
| Label Large | 14px | w700 | |
| Label Medium | 12px | w600 | |
| Label Small | 11px | w600 | |
| Code | 13px | w400 | |

## 间距 Token

| Token | 值 | 用途 |
|-------|-----|------|
| xs | 4px | 紧凑间距 |
| sm | 8px | 小间距 |
| md | 12px | 中间距 |
| lg | 16px | 大间距 |
| xl | 24px | 超大间距 |
| xxl | 48px | 最大间距 |

## 圆角 Token

| Token | 值 | 用途 |
|-------|-----|------|
| none | 0px | 硬强调 |
| sm | 8px | 小元素 |
| md | 12px | 按钮、输入框 |
| lg | 16px | 卡片、FAB |
| xl | 24px | 弹窗、对话框 |

## 边框 Token

| Token | 值 | 用途 |
|-------|-----|------|
| thin | 1.5px | 轻边框 |
| default | 2px | 标准边框 |
| thick | 3px | 聚焦/强调 |

## 阴影 Token

| Token | 偏移量 | 用途 |
|-------|--------|------|
| hard | 4px | 标准阴影 |
| pressed | 1px | 按下状态 |
| colored | 4px | 品牌色阴影 |
| double | 4px+8px | 双层阴影 |

## 动效 Token

### 时长

| Token | 值 | 用途 |
|-------|-----|------|
| fast | 120ms | 快速反馈 |
| normal | 200ms | 标准过渡 |
| slow | 300ms | 复杂过渡 |
| stagger | 50ms | 列表交错 |

### 曲线

| Token | 曲线 | 用途 |
|-------|------|------|
| standard | easeOut | 通用 |
| decelerate | decelerate | 入场 |
| accelerate | easeIn | 出场 |
| spring | elasticOut | 弹性 |
| gentle | easeInOut | 柔和 |

## 核心组件清单

| 组件 | 说明 | 跨端要点 |
|------|------|---------|
| | | |

## hue 输入 Prompt

基于以上信息，组装 hue skill 调用 prompt：

```
品牌名称：<产品名>
产品描述：<定位>
目标平台：<目标平台>

设计方向：<核心风格关键词>
核心情感：<情感基调>

已有设计参考：
- 主色：<品牌色>
- 字体：<字体体系>
- 底色：<表面色>
- 特征：<设计特征>

请为所有目标平台生成统一设计系统，包含平台映射（各端 token 适配规则）。
```
