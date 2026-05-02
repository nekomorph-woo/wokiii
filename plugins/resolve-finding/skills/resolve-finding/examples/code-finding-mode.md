# 代码发现模式示例

**输入**：`src/.../DeviceSelector.java`（代码文件路径）

**预期流程**：
1. 分析代码 → 提取包路径、类结构、公共方法
2. 分类发现类型：偏差（设计文档规定返回 Optional，代码返回 null）
3. 反向搜索 → 定位 `docs/03a-core-models.md §2.3`、`docs/03b-device-proxy-workflow.md §3.1`
4. 构建对比表 → 标记差异为 🔴 阻塞
5. /grill-me 拷问 → 逼出决策（以设计文档为准，代码改用 Optional）
6. 反向修补设计文档（如有遗漏描述则补充）
7. 生成代码修改计划（控制台输出）
8. 判断非轻量 → 询问交接方式 → 用户选择 A 交接 /triage-issue

**预期输出**：
```
📄 设计文档修补: docs/03b-device-proxy-workflow.md（补充返回值说明）

# 代码修改计划
来源发现: DeviceSelector.select() 返回 null 而非 Optional
关联设计文档: docs/03b-device-proxy-workflow.md §3.1（已修补 ✅）

问题: select() 方法返回 null，与设计文档规定的 Optional 返回值不一致...
根因: 实现时遗漏了 Optional 包装...
受影响模块: DeviceSelector.java (修改方法返回类型)

→ 交接 /triage-issue
```
