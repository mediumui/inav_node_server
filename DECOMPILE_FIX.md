# Decompile 端点修复说明

## 问题描述

Decompile 端点收到 INAV logic 命令后，返回"No enabled logic conditions found"的警告，没有生成任何 JavaScript 代码。

### 原始问题

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1 -1 2 2 0 0 1000 0", "logic 1 1 -1 47 4 0 0 0 0", ...]
  }'
```

**预期结果**：

```javascript
edge(
  () => inav.flight.armTimer > 1000,
  0,
  () => {
    inav.gvar[0] = inav.flight.yaw;
    inav.gvar[1] = 0;
  },
);
```

**实际结果**：

```json
{
  "success": true,
  "code": "// No logic conditions found",
  "warnings": ["No enabled logic conditions found"],
  "errors": []
}
```

## 根本原因

有两个主要问题：

### 1. **命令格式未解析**

API 路由的 `decompileHandler` 直接将原始字符串命令数组传给 `decompiler.decompile()`，但 decompiler 期望的是**已解析的逻辑条件对象**。

Decompiler 的 `decompile()` 方法签名：

```javascript
decompile(logicConditions, (variableMap = null));
// logicConditions: Array<{ index, enabled, activatorId, operation, ... }>
```

### 2. **Decompiler 实例状态污染**

API 中全局共享的 decompiler 实例可能在多个请求之间产生状态问题。

## 解决方案

### 修复 1：正确解析 INAV 命令字符串

在 `routes/api.js` 的 `decompileHandler()` 中，添加命令解析逻辑：

```javascript
// Parse logic commands to structured objects
// Format: "logic INDEX ENABLED ACTIVATOR OP OPA_TYPE OPA_VAL OPB_TYPE OPB_VAL FLAGS"
const logicConditions = [];
for (const cmd of commands) {
  if (typeof cmd !== "string") continue;

  const trimmed = cmd.trim();
  if (!trimmed.startsWith("logic ")) continue;

  const parts = trimmed.split(/\s+/);
  if (parts.length < 10) continue;

  logicConditions.push({
    index: parseInt(parts[1]),
    enabled: parseInt(parts[2]),
    activatorId: parseInt(parts[3]),
    operation: parseInt(parts[4]),
    operandAType: parseInt(parts[5]),
    operandAValue: parseInt(parts[6]),
    operandBType: parseInt(parts[7]),
    operandBValue: parseInt(parts[8]),
    flags: parseInt(parts[9]) || 0,
  });
}
```

### 修复 2：为每个请求创建新的 Decompiler 实例

```javascript
// Create fresh decompiler instance for each request
// to avoid any potential state issues
const freshDecompiler = new Decompiler();

// Decompile
const result = freshDecompiler.decompile(logicConditions);
```

### 修复 3：更新 CLI 客户端

同样的解析逻辑也需要应用到 `cli.js` 的 `decompileCommand()` 函数中。

## 受影响的文件

✅ **已修复**：

- `/Users/jingsiyue/Documents/inav/node_server/routes/api.js` - API 路由处理器
- `/Users/jingsiyue/Documents/inav/node_server/cli.js` - Node.js CLI 工具

## 命令格式参考

INAV logic 命令格式：

```
logic <index> <enabled> <activatorId> <operation> <operandAType> <operandAValue> <operandBType> <operandBValue> [flags]
```

**示例**：

```
logic 0 1 -1 2 2 0 0 1000 0
```

解析结果：

```javascript
{
  index: 0,           // Logic condition 索引
  enabled: 1,         // 是否启用（1=启用，0=禁用）
  activatorId: -1,    // 激活器LC索引（-1=无）
  operation: 2,       // 操作类型（2=GREATER_THAN）
  operandAType: 2,    // 左操作数类型（2=FLIGHT）
  operandAValue: 0,   // 左操作数值（0=ARM_TIMER）
  operandBType: 0,    // 右操作数类型（0=VALUE）
  operandBValue: 1000,// 右操作数值
  flags: 0            // 标志位（可选）
}
```

## 测试结果

### API 端点测试

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1 -1 2 2 0 0 1000 0", "logic 1 1 -1 47 4 0 0 0 0", "logic 2 1 1 18 0 0 2 40 0","logic 3 1 1 18 0 1 0 0 0"]
  }'
```

**结果** ✅

```json
{
  "success": true,
  "code": "// INAV JavaScript Programming\n// Decompiled from logic conditions\n\n// ...\n\nedge(() => inav.flight.armTimer > 1000, 0, () => {\n  inav.gvar[0] = inav.flight.yaw;\n  inav.gvar[1] = 0;\n});",
  "warnings": [],
  "errors": [],
  "commandCount": 4,
  "timestamp": "2026-02-23T04:00:00.395Z"
}
```

### CLI 工具测试

```bash
node cli.js decompile "logic 0 1 -1 2 2 0 0 1000 0" "logic 1 1 -1 47 4 0 0 0 0" "logic 2 1 1 18 0 0 2 40 0" "logic 3 1 1 18 0 1 0 0 0"
```

**结果** ✅ 成功生成代码

## 相关文档更新

文档已更新以澄清 decompile 的工作方式：

- `DEPLOYMENT.md` - 更新了示例和说明
- `USAGE.md` - 新增 Transpile vs Decompile 对比表

---

**修复日期**：2026-02-23
**状态**：✅ 已解决并测试
