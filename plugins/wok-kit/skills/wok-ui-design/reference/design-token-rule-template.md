# Design Token Rule 模板

> Step 2 完成后，基于此模板生成 `.claude/rules/design-tokens.md`。
> 模板中的 `{placeholder}` 从 design-model.yaml 中提取。

## 生成规则

读取 `.wok-ui-design/design-system/design-model.yaml`，提取以下信息填充模板：

| 占位符 | 来源 |
|--------|------|
| `{project-name}` | `meta.name` |
| `{version}` | `meta.version` |
| `{date}` | 当前日期 |
| `{brand-colors}` | `colors.brand` 下所有色值（name: value 列表） |
| `{font-families}` | `typography.families` 下所有字体 |
| `{shadow-blur-note}` | 如果所有 shadows 的 blur=0，添加「DO NOT 使用 blur > 0 的阴影」 |

## 模板

```markdown
# Design Tokens — {project-name}

Design tokens 定义在 `.wok-ui-design/design-system/design-model.yaml` 中，是项目 UI 的唯一真相源。

## Token 引用规则

- **颜色**: DO NOT 硬编码颜色值。使用 `design-model.yaml` 中 `colors` token 或对应的 CSS 变量（`var(--color-*)`）
- **字体**: 使用 `design-model.yaml` 中 `typography.families` 声明的字体。DO NOT 引入未声明的字体
- **间距**: 使用 `design-model.yaml` 中 `spacing` token。各端按 `platform_mapping` 转换
- **圆角**: 使用 `design-model.yaml` 中 `radius` token
- **边框**: 使用 `design-model.yaml` 中 `border` token（宽度、样式、颜色）
- **阴影**: 使用 `design-model.yaml` 中 `shadows` token。{shadow-blur-note}
- **动效**: 时长使用 `motion.duration` token，曲线使用 `motion.curves` token

## 组件规则

- 新 UI 组件 MUST 在 `DESIGN.md` Components 段中有对应定义
- 组件 variant / state / size 遵循 `DESIGN.md` 规范
- 各端实现遵循 `design-model.yaml` 中 `platform_mapping` 的适配规则

## 反模式

参见 `DESIGN.md` Anti-patterns 段落。常见违规：
- 硬编码颜色值而非使用 CSS 变量
- 使用未在 `typography.families` 中声明的字体
- 引入 `design-model.yaml` 中不存在的间距值

## 品牌色速查

{brand-colors}

## 字体速查

{font-families}

## 真相源

| 文件 | 内容 |
|------|------|
| `.wok-ui-design/design-system/design-model.yaml` | Token 真相源（颜色、字体、间距、圆角、阴影、动效） |
| `.wok-ui-design/design-system/DESIGN.md` | 设计规范（组件 CSS、布局、交互状态、反模式） |

## 变更记录

- {date}: 初始生成，基于 design-model.yaml v{version}
```

## 更新行为

更换设计风格时（替换 seed-input.md 并重跑 Step 2）：
1. `design-model.yaml` 和 `DESIGN.md` 内容更新，路径不变
2. `.claude/rules/design-tokens.md` 内容更新，路径不变
3. rule 中的 `{brand-colors}` 和 `{font-families}` 自动反映新设计
4. 追加变更记录行：`- <date>: 更新，基于 design-model.yaml v<version>`
