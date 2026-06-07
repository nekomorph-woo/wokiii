# 设计系统目标规格

> 描述 hue skill 应产出的文件格式和内容要求。

## 产出物清单

hue skill 完整运行后，应产出以下文件：

```
design-system/
├── design-model.yaml     # 设计真相源
├── DESIGN.md             # 结构化设计规范
├── preview.html          # Bento Grid 展示页
├── component-library.html # 组件库预览
├── landing-page.html     # Landing 页面示例
└── app-screen.html       # App 界面示例
```

## design-model.yaml 结构

design-model.yaml 是设计系统的唯一真相源，必须包含以下顶级节：

| 节 | 内容 |
|----|------|
| `meta` | name, version, platforms, style, last_updated |
| `colors` | brand / semantic / surface / text / border / shadow 色值 |
| `color_ramps` | 各品牌色的 50-900 色阶（用于状态变体） |
| `typography` | families（display/body/code）+ scale（16 级字阶） |
| `spacing` | xs/sm/md/lg/xl/xxl token |
| `radius` | none/xs/sm/md/lg/xl/full token |
| `border` | thin/default/thick token + style + color |
| `shadows` | hard/pressed/colored/double/inset 定义 |
| `motion` | duration（instant/fast/normal/slow/slower/stagger）+ curves |
| `icons` | observed_style, fallback_kit, sizes |
| `platform_mapping` | 各目标平台的 token 适配规则 |

### platform_mapping 必填字段

每个平台必须声明：

| 字段 | 说明 |
|------|------|
| `framework` | 技术栈 |
| `color_format` | 颜色值格式（如 CSS variables、StyleSheet） |
| `font_loading` | 字体加载方式 |
| `component_mapping` | 组件映射策略 |
| `radius_unit` | 圆角单位（rem / px） |
| `spacing_unit` | 间距单位（rem / px） |
| `shadow_format` | 阴影格式 |
| `token_file` | token 配置文件路径 |
| `css_variables_file` | CSS 变量文件路径 |

## DESIGN.md 结构

DESIGN.md 必须包含 9 个标准段落：

| # | 段落 | 内容 |
|---|------|------|
| 1 | Visual Theme & Atmosphere | 设计语言描述、核心意象、设计哲学 |
| 2 | Color | 颜色 token（hex + 语义角色 + 使用场景）+ CSS 变量 + 反模式 |
| 3 | Typography | 字体家族 + 字阶（16 级）+ 各端加载方式 + 排版规则 |
| 4 | Spacing | 间距 token + 各端单位转换 + 布局间距规范 |
| 5 | Layout & Composition | 栅格系统 + 页面布局模式 + 各端布局适配 + 响应式断点 |
| 6 | Components | 核心组件 CSS 规范（variant / state / size）+ 各端实现指引 |
| 7 | Motion & Interaction | 动效 token + 交互状态 + prefers-reduced-motion |
| 8 | Voice & Brand | 文案风格 + 产品语言调性 + 错误提示规范 |
| 9 | Anti-patterns | 禁止的设计模式 + AI slop 检测清单 |

## Token 映射要点

### 桌面端（常见）

| design-model token | 映射方式 |
|-------------------|----------|
| colors.brand.* | CSS 变量 `--color-brand-*` |
| typography.families.* | `@fontsource` 包导入 |
| spacing/radius token | Tailwind spacing / borderRadius |
| shadows.hard | `shadow-[0_4px_0_#color]` |

### 移动端（常见）

| design-model token | 映射方式 |
|-------------------|----------|
| colors.brand.* | NativeWind CSS 变量 |
| spacing/radius token | 直接 px 值 |
| 字体 | `@expo-google-fonts/*` |

### Web 端（常见）

与桌面端映射方式基本相同。

## 验证检查

设计系统产出后，验证以下项目：

- [ ] design-model.yaml 包含所有必需顶级节
- [ ] 每个目标平台都有 platform_mapping
- [ ] color_ramps 包含每个品牌色的 50-900 色阶
- [ ] DESIGN.md 9 个段落全部存在
- [ ] CSS 变量 `:root` 块完整
- [ ] 预览 HTML 可正常打开
