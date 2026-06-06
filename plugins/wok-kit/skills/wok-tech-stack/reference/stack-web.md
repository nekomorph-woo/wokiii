# 技术栈 — Web 端规则

> 影响 wok-design、wok-plan、wok-implement 中涉及 Web 端的决策

## 路线选择

| 路线 | 技术栈 | 适用场景 |
|------|--------|----------|
| **A：纯前端** | React + Vite + shadcn/ui + Tailwind | 纯客户端渲染、不需要后端、本地或静态部署 |
| **B：全栈 Serverless** | React + Cloudflare Workers + D1 + R2 + KV | 需要后端 API、按量付费、无需管理服务器 |
| **C：全栈传统服务器** | Next.js + Node.js 服务端 + PostgreSQL | 需要长时间任务、完整 Node 生态、SSR/SEO |

## 路线对比

| | A：纯前端 | B：Serverless | C：传统服务器 |
|---|---|---|---|
| 产物 | 静态 HTML/JS/CSS | 静态前端 + Workers 函数 | 需要运行 Node 服务 |
| 后端逻辑 | 无（或调用外部 API） | Workers 处理 API | 服务端内建 |
| 数据库 | IndexedDB | D1（边缘 SQLite） | PostgreSQL / MySQL |
| 文件存储 | 无 | R2（S3 兼容） | 本地磁盘 / OSS |
| SSR/SEO | 不支持 | 不支持 | 支持 |
| 运行成本 | 静态托管费用 | 按请求量付费 | 服务器固定月费 |
| 部署 | CDN / 本地直接打开 | Cloudflare Pages + Workers | VPS / 云服务器 |

## Web 端特性

Web 端运行在浏览器沙盒中，优先支持：

- 跨设备访问
- 内容分享
- 轻量管理
- 远程配置
- 协作入口

**DO NOT** 强行在 Web 端实现：完整本地文件系统操作、复杂离线能力、深度系统集成。

## 目录结构

```text
src/
  app/            # 应用入口
  pages/          # 页面
  features/       # 功能模块
  components/     # 通用组件
  lib/            # 工具
```

## 数据存储

| 路线 | 存储 |
|------|------|
| A：纯前端 | LocalStorage / IndexedDB |
| B：Serverless | D1 + KV + R2 |
| C：传统服务器 | PostgreSQL / 云数据库 |

## 部署

| 路线 | 部署方式 |
|------|----------|
| A：纯前端 | Cloudflare Pages / Vercel / Netlify / 本地直接打开 |
| B：Serverless | Cloudflare Pages（前端）+ Workers（API） |
| C：传统服务器 | Vercel / 云服务器 / 自建服务器 |
