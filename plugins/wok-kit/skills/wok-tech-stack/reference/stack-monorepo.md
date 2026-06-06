# 技术栈 — Monorepo 结构规则

> 多端项目启用时生效，影响 wok-design 的模块划分和 wok-plan 的实现规划

## 工具链

```text
包管理：pnpm workspace
构建编排：Turborepo
```

## packages 结构

```text
packages/
  core/           # 领域对象、规则、状态机、行为（无平台依赖）
  schemas/        # Zod schema、DTO 定义
  db/             # 数据库 schema、Repository、migrations
  api/            # API Client、endpoints
  platform/       # 平台适配器接口 + 各端实现
    interfaces/   # adapter 接口定义
    desktop/      # Tauri 实现
    mobile/       # Expo 实现
    web/          # Web 实现
  ui-web/         # 桌面/Web 共享 UI 组件（按需）
  ui-mobile/      # 移动端共享 UI 组件（按需）
  config/         # 共享配置
  testing/        # 测试 fixtures 和 helpers
```

## apps 结构

```text
apps/
  desktop/        # Tauri 桌面端应用
  mobile/         # Expo 移动端应用
  web/            # React/Next.js Web 应用
```

## 依赖规则

```
apps → packages（单向）
core 不依赖任何具体端
platform 各端实现只依赖 interfaces
schemas 被 core / apps / db 共同使用
```

**DO NOT** 让 packages 之间产生循环依赖。

## 数据存储策略

各端独立适配存储实现，共享 schema 定义：

| 端 | 存储 | ORM/工具 |
|----|------|----------|
| 桌面 | SQLite | Drizzle ORM |
| 移动 | Expo SQLite | Expo SQLite API |
| Web | IndexedDB / API | 视路线而定 |

`packages/db` 定义共享 schema 和 repository 接口，各端提供具体实现。

## 测试策略

| 类型 | 工具 | 覆盖范围 |
|------|------|----------|
| 核心单元测试 | Vitest | packages/core, schemas |
| Repository 测试 | Vitest | packages/db |
| UI 组件测试 | Vitest | 各端 UI |
| Web E2E | Playwright | apps/web |
| 桌面 E2E | Playwright + Tauri | apps/desktop |
| 移动端 | Expo 测试 / Maestro | apps/mobile |
