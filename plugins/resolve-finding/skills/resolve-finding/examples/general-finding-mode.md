# 通用发现模式示例

**输入**：`设备选择模块的缓存策略未定义`（自由描述，无具体文件位置）

**预期流程**：
1. Grep 搜索设计文档目录 → 定位 `docs/03b-device-proxy-workflow.md §4.1`
2. 搜索关联点 → 发现 `docs/03a-core-models.md §1.2` 也涉及缓存相关描述
3. /grill-me 拷问 → 逼出决策（如：采用 LRU 策略，最大缓存 100 条，TTL 5 分钟）
4. 反向修补两个文档 → 展示 diff → 用户确认 → 写入文件
5. 连锁检查：检查其他模块是否依赖此缓存定义

**预期输出**：
```
✅ 发现已解决
- 决策: 设备选择采用 LRU 缓存，最大 100 条，TTL 5 分钟
- 修改文件: docs/03b-device-proxy-workflow.md, docs/03a-core-models.md
- 未覆盖关联点: 无
```
