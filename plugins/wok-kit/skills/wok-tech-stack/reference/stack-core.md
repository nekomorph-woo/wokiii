# 技术栈 — 核心原则

## 多端策略

> 核心共享，体验分端。

**共享**：类型定义、领域对象、状态机、规则、校验逻辑、API Client、数据协议、业务流程
**分端**：UI 组件、页面布局、存储适配、系统能力、导航方式、打包发布

**DO NOT** 追求一套 UI 代码跑所有端。

## 语言与类型

- 主语言：TypeScript
- 校验：Zod（跨端共享 schema 和运行时校验）
- 核心包必须平台无关（**DO NOT** 在 core 中依赖 React / Tauri / Expo / DOM）

## 分层架构

| 层级 | 职责 |
|------|------|
| UI Layer | 页面、组件、交互 |
| Application Layer | 用例编排、页面动作 |
| Domain/Core Layer | 实体、规则、状态机、领域行为 |
| Data Layer | 数据库、Repository、API |
| Platform Layer | 文件系统、通知、窗口、设备能力 |

## 依赖方向

```
apps → packages
ui → core
application → core
data → core
platform → interfaces
```

**禁止**：core 依赖任何具体平台 API。

## 平台适配器

系统能力通过 adapter 接口抽象：

```ts
interface FileSystemAdapter { readFile(path: string): Promise<string> }
interface StorageAdapter { getItem(key: string): Promise<string | null> }
```

不同端实现不同 adapter，core 只依赖接口。

## AI Coding 工作流

- 每次任务限定范围：只改一个包或一个端
- 每次变更说明影响范围（影响 apps + packages）
- 共享包（core / schemas / db）必须配测试
- UI 可以晚测，核心逻辑不能裸奔

## 迭代节奏

- MVP 先做单端闭环，不一开始就铺三端
- 第一端闭环后抽离共享包，再铺其他端
- 同步最后做：单端闭环 → 导入导出 → 手动备份 → 云同步
