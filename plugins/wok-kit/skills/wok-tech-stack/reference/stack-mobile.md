# 技术栈 — 移动端规则

> 影响 wok-design、wok-plan、wok-implement 中涉及移动端的决策

## 技术栈

```text
框架：Expo + React Native
语言：TypeScript
路由：Expo Router
数据库：Expo SQLite
状态：Zustand / Jotai
样式：NativeWind（MVP 推荐）
构建：EAS Build / EAS Update
```

## 移动端特性

移动端交互以触控、手势、小屏为主，优先支持：

- 查看和浏览
- 快速输入和确认
- 简单状态变更
- 拍照/上传
- 提醒通知

**DO NOT** 强行在移动端实现：复杂编排、大量数据管理、高级批量操作、大型编辑器、复杂多步骤表单。

## 目录结构

```text
app/
  _layout.tsx     # 根布局
  index.tsx       # 首页
src/
  features/       # 功能模块
  components/     # 通用组件
  lib/            # 工具
```

## 数据存储

- 结构化数据 → Expo SQLite
- 配置 → AsyncStorage
- 缓存 → SQLite 表

MVP 阶段存储：用户配置、核心数据、离线草稿、必要状态。

## 开发流程

```text
Expo Go 预览（早期）→ Dev Build（需要原生模块时）→ EAS Build（正式构建）
```

- Expo Go：快速预览 UI、基础调试
- Dev Build：需要原生模块、真实环境调试
- EAS Update：JS/资源热更新（原生代码变更仍需重新构建）

## MVP 范围

包含：基础导航、核心数据查看/编辑、本地存储、通知入口。

**不包含**：复杂表单、批量操作、原生推送、离线同步。

## 打包

使用 EAS Build 构建 iOS / Android，EAS Submit 提交应用商店，EAS Update 热更新。
