# 技术栈 — 桌面端规则

> 影响 wok-design、wok-plan、wok-implement 中涉及桌面端的决策

## 技术栈

```text
框架：Tauri 2
前端：React + TypeScript + Vite
UI：shadcn/ui + Tailwind CSS
状态：Zustand / Jotai
数据库：SQLite + Drizzle ORM
表单：React Hook Form + Zod
```

## Rust 层职责

Rust commands **仅负责**：文件读写、文件夹选择、系统路径、本地命令、窗口管理、托盘、菜单、性能敏感操作。

**DO NOT** 在 Rust 层实现：核心业务流程、领域规则、状态机、CRUD 逻辑、UI 状态。

Rust 是系统边界守卫，不是业务后端。

## 本地服务模式

桌面端可选开启 HTTP 监听服务，将本地数据和 API 能力暴露给网络：

```text
桌面应用内嵌 HTTP Server（Rust / Node sidecar）
  → 提供 REST API
  → 局域网内其他设备可访问
  → 可作为本地 Web 端的后端
```

**适用场景**：

| 场景 | 说明 |
|------|------|
| 局域网访问 | 手机/平板通过浏览器访问桌面端数据 |
| 本地 Web 端 | 同一设备上浏览器访问 localhost API |
| 远程访问 | 通过 Cloudflare Tunnel 暴露到公网 |
| 多设备协作 | 局域网内多设备通过 API 共享数据 |

**Cloudflare Tunnel**：将本地服务通过加密隧道暴露到公网，无需公网 IP、无需端口映射、无需域名解析。桌面端运行 `cloudflared tunnel` 即可让外部通过域名安全访问本地 API。

**实现原则**：

- 本地服务是**可选增强**，不是桌面端运行的必要条件
- API 层复用 `packages/core` 的领域逻辑，不在 Rust 层重写业务
- 桌面端 UI 和本地服务 API 共享同一 SQLite 数据源
- 注意局域网访问的安全边界（鉴权、CORS、速率限制）

## 目录结构

```text
src/
  app/            # 应用入口
  pages/          # 页面
  features/       # 功能模块（按领域对象组织）
  components/     # 通用组件
  lib/            # 工具
src-tauri/
  src/
    commands/     # Tauri commands
    server/       # 本地 HTTP 服务（可选）
  tauri.conf.json
```

## 数据存储

- 结构化数据 → SQLite + Drizzle ORM
- 配置 → 本地配置文件
- 缓存 → SQLite 表

存储范围：核心对象、关系、操作记录、配置、缓存、审计日志。

## MVP 范围

包含：应用启动、基础布局、SQLite 初始化、核心对象 CRUD、核心闭环、本地配置、错误边界。

**不包含**：自动更新、插件系统、多窗口同步、复杂权限、主题市场。

## 打包

使用 Tauri Bundler，MVP 先支持单一系统（如 macOS），逐步扩展签名和自动更新。
