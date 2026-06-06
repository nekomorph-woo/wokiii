# AI Coding 跨端应用技术栈迭代方法论

## 0. 摘要

本文档用于指导一个以 AI Coding 为主要开发方式的跨端应用，从桌面端、移动端、Web 端的技术栈选型，到项目结构、版本迭代、代码复用、数据持久化、测试验证、打包发布和长期演进策略。

核心结论：

> 推荐采用 TypeScript 统一核心逻辑，桌面端使用 Tauri 2 + React，移动端使用 Expo + React Native，Web 端使用 React + Vite 或 Next.js。

推荐主技术栈：

```text
语言：TypeScript
Monorepo：pnpm workspace / Turborepo
核心逻辑：packages/core
桌面端：Tauri 2 + React + Vite
移动端：Expo + React Native
Web 端：React + Vite 或 Next.js
桌面/Web UI：shadcn/ui + Tailwind CSS
移动 UI：React Native + NativeWind 或 Tamagui
本地数据库：
- 桌面端：SQLite + Drizzle ORM
- 移动端：Expo SQLite
- Web 端：IndexedDB / LocalStorage / 后端 API
状态管理：Zustand / Jotai
测试：Vitest + Playwright + Expo 相关测试工具
```

本文档的重点不是追求“一套 UI 代码到处跑”，而是追求：

> 核心逻辑共享，端侧体验分离，数据结构统一，迭代节奏可控。

跨端项目最危险的幻想是：

```text
一套代码完美覆盖桌面、移动、网页
```

现实通常是：

```text
一套代码把三个端一起拖进泥潭
```

所以本文档采用更稳健的策略：

```text
共享核心逻辑
共享类型
共享领域模型
共享状态机
共享规则
共享协议
分端实现 UI
分端适配存储和系统能力
```

这是一条不像自杀的路线。已经很珍贵了。

---

## 1. 技术栈选择的基本立场

### 1.1 跨端不是“一套代码跑三端”

真正可维护的跨端应用，不应该强行追求所有代码完全共用。

桌面端、移动端和 Web 端天然有差异：

| 维度 | 桌面端 | 移动端 | Web 端 |
|---|---|---|---|
| 输入方式 | 鼠标、键盘、快捷键 | 触控、手势 | 鼠标、键盘、触控 |
| 屏幕尺寸 | 大屏 | 小屏 | 可变 |
| 系统能力 | 文件系统、窗口、菜单、托盘 | 相机、通知、定位、推送 | 浏览器沙盒 |
| 数据存储 | 本地数据库、文件 | 本地数据库、沙盒存储 | IndexedDB、远程 API |
| 使用场景 | 长时间复杂操作 | 快速查看和轻量操作 | 分享、访问、跨设备 |
| 打包发布 | 安装包 | App Store / Google Play | Web 部署 |

因此，跨端应用的正确策略是：

```text
核心共享，体验分端。
```

也就是：

```text
共享：
- 类型定义
- 领域对象
- 状态机
- 规则
- 校验逻辑
- API Client
- 数据协议
- 部分业务流程

分端：
- UI 组件
- 页面布局
- 存储适配
- 系统能力
- 导航方式
- 打包发布
```

### 1.2 AI Coding 友好度是核心指标

如果项目主要依赖 AI Coding 推进，技术栈必须满足：

```text
资料丰富
社区成熟
类型清晰
目录结构明确
组件生态稳定
错误信息可理解
测试方式明确
代码生成模式稳定
```

因此推荐使用 TypeScript 作为主语言。

TypeScript 的优势：

```text
AI 对 TypeScript 熟悉
类型定义能约束 AI 输出
跨桌面、移动、Web 都能使用
适合抽象共享核心逻辑
生态覆盖前端、移动端、Node 工具链
```

相比之下，如果桌面端用 Rust，移动端用 Swift/Kotlin，Web 用 TypeScript，AI Coding 的上下文切换成本会迅速上升。不是不能做，是容易变成多语言工程动物园。动物园挺可爱，维护起来像喂一群会写 bug 的猩猩。

### 1.3 技术选型优先级

本方法论的技术选型优先级如下：

```text
稳定性
可维护性
AI Coding 友好度
跨端复用能力
开发速度
生态成熟度
性能
技术先进性
```

不建议以“最炫”“最新”“最底层”“最原生”作为首要依据。

工程不是选妃，别看谁衣服亮就冲上去。

---

## 2. 推荐整体技术栈

### 2.1 总体架构

推荐采用 Monorepo：

```text
my-app/
  apps/
    desktop/
    mobile/
    web/

  packages/
    core/
    schemas/
    db/
    api/
    platform/
    ui-web/
    ui-mobile/
    config/
    testing/

  docs/
```

核心思想：

```text
apps 负责端侧应用
packages 负责跨端共享能力
```

### 2.2 推荐技术栈表

| 层级 | 推荐技术 | 用途 |
|---|---|---|
| 主语言 | TypeScript | 统一核心逻辑和类型 |
| Monorepo | pnpm workspace / Turborepo | 管理多端应用和共享包 |
| 桌面端 | Tauri 2 + React + Vite | 轻量桌面应用 |
| 移动端 | Expo + React Native | iOS / Android 应用 |
| Web 端 | React + Vite / Next.js | 浏览器端应用 |
| 桌面/Web UI | shadcn/ui + Tailwind CSS | 快速构建现代 UI |
| 移动 UI | React Native + NativeWind / Tamagui | 移动端 UI |
| 状态管理 | Zustand / Jotai | 简洁状态管理 |
| 本地数据库 | SQLite | 桌面和移动端本地存储 |
| 桌面 ORM | Drizzle ORM | 类型安全 SQLite 访问 |
| 移动 SQLite | Expo SQLite | 移动端本地数据库 |
| Web 存储 | IndexedDB / API | 浏览器端数据 |
| 表单 | React Hook Form + Zod | 表单和校验 |
| 校验 | Zod | 共享 schema 和运行时校验 |
| 测试 | Vitest + Playwright | 单测和端到端测试 |
| 移动调试 | Expo Go / Dev Build | 快速预览和原生能力测试 |
| 打包发布 | Tauri Bundler / EAS / Web Hosting | 桌面、移动、Web 发布 |

---

## 3. 桌面端技术栈

### 3.1 推荐方案

```text
Tauri 2
React
TypeScript
Vite
shadcn/ui
Tailwind CSS
SQLite
Drizzle ORM
Zustand / Jotai
```

### 3.2 为什么选择 Tauri 2

Tauri 是使用 Web UI 构建桌面应用的框架。

基本结构：

```text
前端：React / TypeScript
桌面后端：Rust
系统能力：通过 Tauri API 和 commands 暴露
打包：生成原生桌面应用
```

Tauri 相比 Electron 的主要优势：

```text
安装包更小
资源占用更低
安全模型更严格
系统能力边界更清晰
适合本地工具型应用
```

适合场景：

```text
本地工具
效率软件
知识管理
任务管理
开发者工具
轻量数据管理
需要本地文件系统和数据库
```

### 3.3 桌面端 Rust 层设计原则

不要把 Rust 层写成业务后端。

推荐分工：

```text
React：页面、组件、交互
TypeScript core：领域逻辑、规则、状态机
SQLite：本地数据
Rust commands：系统能力、安全边界、文件操作、窗口能力
```

Rust 层适合：

```text
读取/写入本地文件
选择文件夹
系统路径获取
调用本地命令
窗口管理
系统托盘
菜单栏
性能敏感的小功能
```

不建议早期把以下内容放进 Rust：

```text
核心业务流程
领域规则
状态机
大量 CRUD 逻辑
UI 状态逻辑
```

否则 AI Coding 会从“写应用”变成“在 TS 和 Rust 两个脑袋之间走钢丝”。非常艺术，也非常容易摔。

### 3.4 桌面端 MVP 能力范围

桌面端 MVP 应该优先支持：

```text
应用启动
基础布局
本地数据库初始化
核心对象 CRUD
核心闭环流程
本地配置
基础日志
错误边界
数据导入导出
```

暂缓：

```text
自动更新
复杂插件系统
多窗口复杂同步
云同步
团队协作
复杂权限
主题市场
多账号体系
```

---

## 4. 移动端技术栈

### 4.1 推荐方案

```text
Expo
React Native
TypeScript
Expo Router
Expo SQLite
Zustand / Jotai
NativeWind 或 Tamagui
EAS Build / EAS Update
```

### 4.2 Expo 是什么

Expo 是 React Native 的上层开发框架和工具链。

可以理解为：

```text
React Native 提供移动端能力
Expo 提供开发、调试、构建、发布、更新的一整套工具
```

Expo 能帮助处理：

```text
项目初始化
手机扫码预览
路由
相机
定位
通知
文件系统
SQLite
构建 iOS / Android
提交应用商店
热更新
```

### 4.3 为什么移动端推荐 Expo

Expo 对 AI Coding 和 MVP 迭代非常友好：

```text
初始化简单
文档集中
生态清晰
调试方便
手机扫码预览
减少原生环境折腾
支持 EAS 云构建
支持 Dev Build 扩展原生能力
```

相比 React Native CLI，Expo 更适合个人开发和快速迭代。

React Native CLI 的自由度更高，但代价是：

```text
Xcode 配置
Android Gradle 配置
原生依赖管理
证书配置
构建问题
环境问题
```

移动端工程环境会非常热情地教育人类“什么叫平台差异”。Expo 至少能把这种教育延后一点。

### 4.4 Expo Go、Dev Build 和 EAS

#### Expo Go

Expo Go 是手机上的预览应用。

适合：

```text
快速预览 UI
基础能力调试
早期开发
```

限制：

```text
不能使用所有自定义原生模块
不适合最终生产包验证
```

#### Dev Build

Dev Build 是为你的应用生成一个自定义开发客户端。

适合：

```text
需要原生模块
需要真实应用环境
需要调试生产接近环境
```

#### EAS Build

EAS Build 用于云端构建 iOS / Android 应用。

适合：

```text
减少本地构建环境负担
生成正式安装包
构建测试包
构建商店包
```

#### EAS Update

EAS Update 用于更新 JS 和资源。

适合：

```text
快速修复 UI 和逻辑问题
不需要重新走完整商店审核的轻量更新
```

注意：

```text
涉及原生代码变化时，仍然需要重新构建应用。
```

### 4.5 移动端定位

移动端不应一开始承担完整桌面端能力。

推荐移动端定位：

```text
查看
轻量编辑
提醒
通知
快速确认
简单状态变更
拍照/上传
移动场景输入
```

不推荐 MVP 移动端承担：

```text
复杂编排
大量数据管理
复杂设置
高级批量操作
大型编辑器
复杂多窗口工作流
```

移动端是伴侣，不是把桌面端塞进裤兜里。裤兜已经承受太多了。

---

## 5. Web 端技术栈

### 5.1 推荐方案

Web 端有两种推荐路线。

#### 路线 A：React + Vite

适合：

```text
本地优先应用
纯前端应用
桌面端 UI 高复用
管理后台
轻量 Web 端
不需要复杂服务端渲染
```

推荐栈：

```text
React
TypeScript
Vite
shadcn/ui
Tailwind CSS
Zustand / Jotai
IndexedDB
```

#### 路线 B：Next.js

适合：

```text
需要登录
需要服务端渲染
需要 SEO
需要 API Routes
需要云端服务
需要部署为正式 Web 产品
```

推荐栈：

```text
Next.js
TypeScript
Tailwind CSS
shadcn/ui
Zod
Server Actions / API Routes
PostgreSQL / SQLite / Cloud DB
```

### 5.2 Web 端定位

Web 端适合承担：

```text
跨设备访问
分享
轻量管理
公开页面
远程配置
团队协作入口
云端控制台
```

不适合早期承担：

```text
完整本地文件系统能力
复杂离线能力
大量本地自动化任务
深度桌面系统集成
```

### 5.3 Web 端与桌面端的关系

如果桌面端使用 React + Vite，Web 端可以高度复用：

```text
页面结构
组件
领域逻辑
类型
状态管理
表单校验
API Client
```

但 Web 端不能直接复用：

```text
Tauri commands
本地文件系统 API
桌面窗口管理
系统托盘
原生菜单
本地路径逻辑
```

因此，应将系统能力封装为 adapter：

```text
packages/platform/
  desktop/
  web/
  mobile/
```

统一暴露接口：

```ts
interface FileSystemAdapter {
  readFile(path: string): Promise<string>
  writeFile(path: string, content: string): Promise<void>
}
```

不同端实现不同 adapter。

---

## 6. 跨端代码复用策略

### 6.1 共享什么

推荐共享：

```text
类型定义
领域对象
状态机
规则
校验 schema
API Client
数据转换逻辑
业务流程编排
常量
工具函数
测试用例的一部分
```

不推荐强行共享：

```text
桌面 UI
移动 UI
导航结构
系统能力实现
平台特定存储
复杂页面布局
```

### 6.2 推荐 packages 结构

```text
my-app/
  apps/
    desktop/
      src/
      src-tauri/

    mobile/
      app/
      src/

    web/
      src/

  packages/
    core/
      src/
        entities/
        actions/
        state-machines/
        rules/
        services/

    schemas/
      src/
        zod/
        dto/

    api/
      src/
        client/
        endpoints/

    db/
      src/
        schema/
        repositories/
        migrations/

    platform/
      src/
        interfaces/
        desktop/
        mobile/
        web/

    ui-web/
      src/

    ui-mobile/
      src/

    config/
      src/

    testing/
      src/
```

### 6.3 分层原则

推荐分层：

```text
UI Layer
Application Layer
Domain/Core Layer
Data Layer
Platform Layer
```

含义：

| 层级 | 职责 |
|---|---|
| UI Layer | 页面、组件、交互 |
| Application Layer | 用例编排、页面动作 |
| Domain/Core Layer | 实体、规则、状态机、领域行为 |
| Data Layer | 数据库、Repository、API |
| Platform Layer | 文件系统、通知、窗口、设备能力 |

### 6.4 依赖方向

推荐依赖方向：

```text
apps -> packages
ui -> core
application -> core
data -> core
platform -> interfaces
core 不依赖具体端
```

禁止：

```text
core 依赖 React
core 依赖 Tauri
core 依赖 Expo
core 依赖浏览器 DOM
core 依赖平台 API
```

核心逻辑必须保持平台无关。

---

## 7. 数据存储策略

### 7.1 桌面端

推荐：

```text
SQLite + Drizzle ORM
```

适合：

```text
结构化数据
本地优先
离线可用
查询稳定
迁移可控
```

桌面端数据可以存储：

```text
核心对象
关系
操作记录
配置
本地缓存
任务历史
审计日志
```

### 7.2 移动端

推荐：

```text
Expo SQLite
```

移动端也可以使用 SQLite，但要注意：

```text
存储容量
同步策略
离线冲突
迁移兼容
移动端性能
```

移动端初期建议只存：

```text
用户配置
轻量缓存
最近数据
离线草稿
必要状态
```

不要第一版就把移动端做成完整数据库副本。

### 7.3 Web 端

Web 端可选：

```text
IndexedDB
LocalStorage
远程 API
云数据库
```

选择原则：

| 场景 | 推荐 |
|---|---|
| 临时设置 | LocalStorage |
| 本地缓存 | IndexedDB |
| 正式云端数据 | 后端 API |
| 多端同步 | 云数据库 / API |
| 离线优先 Web App | IndexedDB + 同步机制 |

### 7.4 多端同步策略

不要 MVP 阶段就做复杂同步。

推荐阶段：

```text
v0.1：单端本地数据
v0.2：导入导出
v0.3：手动备份
v0.4：云端账号
v0.5：基础同步
v0.6：冲突处理
v0.7：多端实时协作
```

同步是复杂系统，不是“加个接口”这么天真的童话。软件工程里最贵的童话通常叫“很快就能同步”。

---

## 8. UI 策略

### 8.1 桌面端 / Web 端 UI

推荐：

```text
React
shadcn/ui
Tailwind CSS
Radix UI
Lucide Icons
```

优势：

```text
组件源码可控
AI 容易生成
样式调整快
适合管理类和工具类应用
桌面/Web 高复用
```

### 8.2 移动端 UI

推荐：

```text
React Native 原生组件
NativeWind
Tamagui
React Native Reusables
```

选择建议：

| 方案 | 适合 |
|---|---|
| NativeWind | 想用 Tailwind 风格写 RN 样式 |
| Tamagui | 追求跨 Web/RN 的 UI 体系 |
| React Native Reusables | 想获得类似 shadcn 的 RN 组件体验 |
| 原生 RN 组件 | 想保持简单直接 |

MVP 阶段推荐：

```text
React Native 原生组件 + NativeWind
```

如果强烈追求 Web 和移动 UI 共享，可以考虑 Tamagui，但复杂度会增加。

### 8.3 不建议一开始追求完全统一 UI

桌面端和移动端的交互差异很大。

强行统一 UI 会导致：

```text
桌面端不像桌面端
移动端不像移动端
代码到处写平台判断
样式越来越难维护
```

推荐：

```text
共享设计语言
共享颜色、间距、字体、图标风格
分端实现组件
```

而不是：

```text
共享所有组件代码
```

---

## 9. 状态管理策略

### 9.1 推荐 Zustand

Zustand 适合 MVP：

```text
简单
轻量
样板代码少
AI 容易生成
适合跨 React / React Native
```

适合管理：

```text
UI 状态
当前选择
过滤条件
用户偏好
临时编辑状态
```

### 9.2 什么时候用 Jotai

Jotai 适合：

```text
状态颗粒度更细
局部状态多
需要原子化组合
```

### 9.3 什么时候引入 XState

XState 适合明确状态机：

```text
复杂流程
多步骤任务
状态迁移严格
需要可视化和可验证状态机
```

不建议 MVP 一开始就全系统使用 XState。

推荐策略：

```text
普通 UI 状态：Zustand
复杂流程状态：XState
领域规则状态：packages/core 中定义
```

---

## 10. 表单和校验策略

推荐：

```text
React Hook Form
Zod
```

Zod 适合作为跨端 schema：

```text
表单校验
DTO 校验
API 输入输出校验
本地数据校验
配置文件校验
```

推荐结构：

```text
packages/schemas/
  user.schema.ts
  task.schema.ts
  config.schema.ts
```

这样桌面端、移动端、Web 端都可以共享校验逻辑。

---

## 11. API 和后端策略

### 11.1 MVP 阶段可以无后端

如果应用是本地优先，MVP 可以先不做后端。

优先实现：

```text
本地数据库
本地配置
导入导出
手动备份
```

### 11.2 什么时候需要后端

出现以下需求时再引入后端：

```text
账号登录
多设备同步
团队协作
云端备份
远程任务
通知推送
权限管理
支付订阅
公开分享
```

### 11.3 后端技术选择

如果后续需要后端，推荐：

```text
Node.js / TypeScript
Hono / Fastify / NestJS
PostgreSQL
Drizzle ORM / Prisma
Redis
```

原因：

```text
继续使用 TypeScript
共享 schema
AI Coding 友好
减少语言栈复杂度
```

---

## 12. 测试策略

### 12.1 测试分层

推荐测试分层：

```text
core 单元测试
schema 校验测试
repository 测试
UI 组件测试
端到端测试
移动端手动回归
```

### 12.2 推荐工具

| 类型 | 工具 |
|---|---|
| 单元测试 | Vitest |
| Web E2E | Playwright |
| 桌面端 E2E | Playwright + Tauri 测试策略 |
| 移动端测试 | Expo 测试工具 / Maestro |
| Schema 测试 | Vitest + Zod |
| API 测试 | Vitest / Supertest |

### 12.3 AI Coding 下的测试原则

AI Coding 必须配测试，否则它会非常自信地给你生成一堆能跑但不对的代码。那种自信很像人类开会。

推荐每个核心功能都配：

```text
输入
预期输出
异常情况
状态变化
数据落库
UI 验收路径
```

---

## 13. 打包与发布策略

### 13.1 桌面端

使用：

```text
Tauri Bundler
```

发布目标：

```text
macOS
Windows
Linux
```

逐步加入：

```text
签名
自动更新
崩溃日志
安装包渠道
```

MVP 阶段可以先只支持一个系统，例如 macOS。

### 13.2 移动端

使用：

```text
EAS Build
EAS Submit
EAS Update
```

阶段：

```text
Expo Go 预览
Dev Build 测试
Internal Distribution
TestFlight / Android Internal Testing
正式上架
```

### 13.3 Web 端

可选部署：

```text
Vercel
Cloudflare Pages
Netlify
自建服务器
```

如果是 React + Vite，部署为静态站点即可。

如果是 Next.js，根据是否使用服务端能力选择部署方案。

---

## 14. 版本迭代路线

### 14.1 v0.1：桌面端核心闭环

目标：

```text
桌面端可安装、可打开、可创建数据、可本地保存、可完成核心流程。
```

包含：

```text
Tauri 桌面壳
React 主界面
SQLite 初始化
核心对象 CRUD
基础设置
基础错误处理
基础导入导出
```

不包含：

```text
移动端
Web 端
云同步
账号系统
自动更新
复杂插件
多端同步
```

### 14.2 v0.2：共享核心包

目标：

```text
将核心类型、规则、schema、状态机从桌面端中抽离出来。
```

包含：

```text
packages/core
packages/schemas
packages/db
packages/config
核心逻辑单元测试
```

收益：

```text
为移动端和 Web 端铺路
减少桌面端逻辑膨胀
提高 AI Coding 稳定性
```

### 14.3 v0.3：Web 端轻量版本

目标：

```text
提供轻量 Web 端，用于查看、分享或简单管理。
```

包含：

```text
React + Vite 或 Next.js
复用 packages/core
复用 packages/schemas
复用部分 UI 设计
IndexedDB 或 API
```

Web 端优先做：

```text
查看
轻量编辑
配置
分享
演示
```

### 14.4 v0.4：移动端伴侣 App

目标：

```text
使用 Expo 构建移动端轻量伴侣应用。
```

包含：

```text
Expo
React Native
Expo Router
复用 packages/core
复用 packages/schemas
基础移动 UI
本地缓存
轻量编辑
通知入口
```

移动端优先做：

```text
查看
快速确认
轻量编辑
提醒通知
移动输入
```

### 14.5 v0.5：数据备份与手动同步

目标：

```text
提供跨端数据迁移基础能力。
```

包含：

```text
导出 JSON
导入 JSON
本地备份
版本迁移
数据校验
冲突检测雏形
```

### 14.6 v0.6：账号与云同步

目标：

```text
引入后端服务，支持账号和基础同步。
```

包含：

```text
账号登录
云端数据库
API Client
同步状态
基础冲突处理
多端数据拉取
```

### 14.7 v0.7：多端体验完善

目标：

```text
让桌面端、移动端、Web 端形成稳定分工。
```

包含：

```text
桌面端复杂操作
移动端轻量操作
Web 端分享和远程访问
同步状态可视化
跨端一致的 schema 和规则
```

---

## 15. 推荐目录结构

```text
my-app/
  apps/
    desktop/
      src/
        app/
        pages/
        features/
        components/
        lib/
      src-tauri/
        src/
        tauri.conf.json
      package.json

    mobile/
      app/
        _layout.tsx
        index.tsx
      src/
        features/
        components/
        lib/
      app.json
      package.json

    web/
      src/
        app/
        pages/
        features/
        components/
        lib/
      package.json

  packages/
    core/
      src/
        entities/
        actions/
        state-machines/
        rules/
        services/
        index.ts

    schemas/
      src/
        index.ts

    db/
      src/
        schema/
        migrations/
        repositories/
        index.ts

    api/
      src/
        client/
        index.ts

    platform/
      src/
        interfaces/
        desktop/
        mobile/
        web/
        index.ts

    ui-web/
      src/
        components/
        index.ts

    ui-mobile/
      src/
        components/
        index.ts

    config/
      src/
        index.ts

    testing/
      src/
        fixtures/
        helpers/
        index.ts

  docs/
    prd/
    architecture/
    decisions/
    iteration/

  package.json
  pnpm-workspace.yaml
  turbo.json
  tsconfig.base.json
```

---

## 16. 平台适配器设计

### 16.1 为什么需要平台适配器

不同平台能力不同。

例如文件系统：

| 平台 | 文件系统能力 |
|---|---|
| 桌面端 | 强，本地路径、读写文件 |
| 移动端 | 沙盒文件、媒体库、分享面板 |
| Web 端 | 浏览器沙盒、File API、IndexedDB |

如果核心逻辑直接依赖具体平台 API，就无法复用。

因此应定义接口：

```ts
export interface StorageAdapter {
  getItem(key: string): Promise<string | null>
  setItem(key: string, value: string): Promise<void>
  removeItem(key: string): Promise<void>
}
```

不同端实现：

```text
desktopStorageAdapter
mobileStorageAdapter
webStorageAdapter
```

### 16.2 常见 Adapter

推荐抽象：

```text
StorageAdapter
FileSystemAdapter
NotificationAdapter
ClipboardAdapter
DialogAdapter
LoggerAdapter
DatabaseAdapter
AuthAdapter
SyncAdapter
```

---

## 17. AI Coding 工作流建议

### 17.1 每次任务都限定范围

不要让 AI 一次性改三端。

推荐任务粒度：

```text
只改 packages/core 的状态机
只改 desktop 的某个页面
只改 mobile 的某个 screen
只改 web 的某个 route
只添加一个 schema
只添加一个 repository
```

AI 很擅长在范围明确时干活，也很擅长在范围不明确时把项目改成现代艺术装置。

### 17.2 每次变更必须说明影响范围

模板：

```text
本次变更目标：
影响应用：
- desktop
- mobile
- web

影响 packages：
- core
- schemas
- db

不允许修改：
- ...

验收方式：
- ...
```

### 17.3 每个共享包必须配测试

尤其是：

```text
packages/core
packages/schemas
packages/db
```

这些包是跨端稳定性的地基。

UI 可以晚点测，核心逻辑不能裸奔。虽然裸奔很自由，但通常会被现实逮捕。

---

## 18. 选型决策表

### 18.1 桌面端

| 方案 | 适合 | 不适合 |
|---|---|---|
| Tauri 2 | 轻量工具、本地应用、长期维护 | 极依赖 Node 生态 |
| Electron | 快速开发、Node 能力强、生态成熟 | 追求轻量和低资源占用 |
| Wails | Go 技术栈团队 | 非 Go 团队、追求成熟生态 |
| Flutter Desktop | 强自绘 UI、同时押 Flutter 全端 | Web/React 生态复用 |
| 原生 Swift/Kotlin | 极致平台体验 | 跨平台和快速 AI Coding |

### 18.2 移动端

| 方案 | 适合 | 不适合 |
|---|---|---|
| Expo | MVP、个人项目、快速迭代、跨端 TS | 极深原生能力 |
| React Native CLI | 原生自由度高 | 初期开发成本高 |
| Flutter | 高一致性自绘 UI | TS/React 栈复用 |
| 原生 Swift/Kotlin | 极致平台能力 | 跨端复用和快速迭代 |

### 18.3 Web 端

| 方案 | 适合 | 不适合 |
|---|---|---|
| React + Vite | 纯前端、轻量管理端、桌面 UI 复用 | SEO/SSR 强需求 |
| Next.js | Web 产品、登录、SSR、API Routes | 纯本地轻量应用 |
| Remix | Web 表单和服务端交互 | 团队不熟悉时 |
| Astro | 内容站、文档站 | 强交互应用 |

---

## 19. 最终推荐路线

### 19.1 MVP 路线

```text
第一阶段：
Tauri 2 + React + TypeScript + SQLite

第二阶段：
抽离 packages/core / schemas / db

第三阶段：
React + Vite Web 端轻量版本

第四阶段：
Expo 移动端伴侣 App

第五阶段：
导入导出和手动备份

第六阶段：
后端、账号和云同步
```

### 19.2 最终形态

```text
apps/desktop：
复杂操作、本地能力、长时间工作流

apps/mobile：
查看、提醒、轻量编辑、快速确认

apps/web：
分享、远程访问、轻量管理、公开入口

packages/core：
领域对象、规则、状态机、行为

packages/schemas：
数据校验和 DTO

packages/db：
数据库 schema 和 repository

packages/platform：
平台能力抽象

packages/api：
云端 API Client
```

---

## 20. 最高指导原则

```text
1. 不追求一套 UI 跑所有端，而追求核心逻辑跨端共享。

2. 不让桌面端、移动端、Web 端各自长成孤岛，而通过 TypeScript packages 共享领域模型。

3. 不在 MVP 阶段做复杂同步，先做单端闭环，再做导入导出，再做云同步。

4. 不把核心逻辑写进 UI 组件，而沉淀到 packages/core。

5. 不把平台 API 写进核心逻辑，而通过 adapter 抽象。

6. 不让移动端复制桌面端全部能力，而让移动端承担轻量伴侣职责。

7. 不让 Web 端承担本地系统能力，而让 Web 端承担分享、远程访问和轻量管理。

8. 不让 AI 一次性改三端，而按包、按端、按能力闭环拆分任务。

9. 不盲目追求技术统一，而追求数据结构、领域规则和用户体验的一致性。

10. 不把技术栈当成信仰。技术栈只是工具，能持续交付才是目的。
```

---

## 21. 一句话定义

> 本技术栈方法论主张：用 TypeScript 统一核心逻辑，用 Tauri 承载桌面端，用 Expo 承载移动端，用 React/Vite 或 Next.js 承载 Web 端，通过 Monorepo 和共享 packages 实现跨端一致的领域模型，同时允许各端根据自身交互特性独立优化体验。

最终目标不是制造一个“看起来跨端”的项目，而是制造一个：

```text
桌面端能深度工作
移动端能轻量参与
Web 端能随时访问
核心逻辑能稳定复用
AI Coding 能持续推进
```

的可演进应用体系。
