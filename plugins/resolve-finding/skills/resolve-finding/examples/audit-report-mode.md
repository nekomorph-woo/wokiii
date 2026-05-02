# 审阅报告模式示例

**输入**：`docs/06-action-items.md 第 15-22 行`

**预期流程**：
1. 读取报告项 → 提取严重度、问题描述、涉及文档
2. 定位设计文档 `docs/03a-core-models.md §2.3`
3. 交叉验证：报告描述的问题是否仍然存在
4. /grill-me 拷问 → 逼出决策（如：统一参数命名风格为 camelCase）
5. 反向修补 `03a-core-models.md` → 展示 diff → 用户确认
6. 连锁检查：扫描报告中其他待处理项是否被连带解决
7. 更新报告项状态为 ✅ 已解决

**预期输出**：
```
✅ 发现已解决
- 决策: 统一参数命名为 camelCase，与代码实现一致
- 修改文件: docs/03a-core-models.md, docs/03b-device-proxy-workflow.md
- 连带解决: 报告项 #5 参数命名不一致
```
