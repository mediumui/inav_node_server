# INAV Node.js API 服务器 - 使用说明

## 🎯 功能概述

这个Node.js服务器提供了两个主要功能：

1. **JavaScript 转 INAV指令 (Transpile)** - 将JavaScript代码转换为INAV CLI命令
2. **INAV指令 转 JavaScript (Decompile)** - 将INAV CLI命令反编译为JavaScript代码

## 📚 Transpile vs Decompile

### Transpile（编译）

- **输入**：JavaScript代码
- **输出**：INAV CLI命令
- **用途**：你写JavaScript代码，需要转成INAV能理解的命令

```bash
输入：if (inav.flight.isArmed) { inav.flight.disarm(); }
输出：setflight_disarm
```

### Decompile（反编译）

- **输入**：INAV CLI命令
- **输出**：JavaScript代码
- **用途**：你有现成的INAV命令，想看看对应的JavaScript是什么样的

```bash
输入：setflight_disarm
输出：// Generated JavaScript that would produce the same INAV command
```

**重点**：Decompile 不会凭空生成命令。你提供什么命令，它就反编译什么。如果你只有 `logic 0 1`，就只会反编译逻辑条件；如果你同时有 `logic 0 1` 和 `setflight_arm`，就会反编译两者。

## 🏗️ 系统架构

```
┌─────────────────┐
│  客户端应用      │
│ (Web/移动/CLI)  │
└────────┬────────┘
         │ HTTP REST API
         ↓
┌─────────────────────────────┐
│  Express.js REST API 服务器  │
├─────────────────────────────┤
│  /api/v1/transpile          │ (JS → INAV)
│  /api/v1/decompile          │ (INAV → JS)
│  /api/docs                  │ API文档
│  /health                    │ 健康检查
└────────┬────────────────────┘
         │ 核心实现
         ↓
┌─────────────────────────────┐
│  INAV Transpiler核心         │
├─────────────────────────────┤
│  Parser (JavaScript → AST)   │
│  CodeGen (AST → INAV命令)    │
│  Decompiler (INAV → JS)      │
│  Optimizer (代码优化)        │
│  Analyzer (语义分析)         │
└─────────────────────────────┘
```

## 📝 API 使用指南

### 1. JavaScript 转 INAV (Transpile)

**端点：** `POST /api/v1/transpile`

**请求示例：**

```bash
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "if (inav.flight.isArmed) { inav.flight.disarm(); }"
  }'
```

**请求字段：**

- `code` (string, 必需) - JavaScript 源代码

**响应示例：**

```json
{
  "success": true,
  "commands": ["logic 0 1", "setflight_disarm"],
  "output": "formatted output string",
  "warnings": [],
  "errors": [],
  "lineCount": 2,
  "timestamp": "2026-02-23T03:15:19.895Z"
}
```

**响应字段：**

- `success` (boolean) - 转译是否成功
- `commands` (array) - 生成的INAV CLI命令列表
- `output` (string) - 格式化的输出字符串
- `warnings` (array) - 警告信息列表
- `errors` (array) - 错误信息列表
- `lineCount` (number) - 生成的命令行数
- `timestamp` (string) - 处理时间戳

**支持的JavaScript特性：**

- ✅ if/else 条件语句
- ✅ 逻辑运算符 (`&&`, `||`, `!`)
- ✅ 比较运算符 (`==`, `!=`, `<`, `>`, `<=`, `>=`)
- ✅ INAV API 访问 (`inav.flight.*`, `inav.navigation.*` 等)
- ✅ 函数调用
- ✅ 变量声明和赋值

### 2. INAV 转 JavaScript (Decompile)

**端点：** `POST /api/v1/decompile`

**说明：** Decompile 是 Transpile 的反向操作。你提供已有的 INAV CLI 命令，API 会反编译为对应的 JavaScript 代码。

**请求示例1 (仅逻辑条件)：**

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1"]
  }'
```

**请求示例2 (逻辑条件 + 动作命令)：**

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1", "setflight_arm"]
  }'
```

**请求示例3 (字符串格式)：**

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": "logic 0 1\nsetflight_arm"
  }'
```

**请求字段：**

- `commands` (array | string, 必需) - INAV CLI命令列表或换行符分隔的字符串
  - 你拥有哪些 INAV 命令就传哪些
  - 可以是任何类型的命令：logic, setflight_arm, setflight_disarm, 等等

**响应示例：**

```json
{
  "success": true,
  "code": "if (condition) {\n  inav.flight.arm();\n}",
  "warnings": [],
  "errors": [],
  "commandCount": 2,
  "timestamp": "2026-02-23T03:15:19.895Z"
}
```

**响应字段：**

- `success` (boolean) - 反编译是否成功
- `code` (string) - 生成的JavaScript源代码
- `warnings` (array) - 警告信息列表
- `errors` (array) - 错误信息列表
- `commandCount` (number) - 处理的命令数量
- `timestamp` (string) - 处理时间戳

### 3. 健康检查

**端点：** `GET /health`

**请求示例：**

```bash
curl http://localhost:3000/health
```

**响应示例：**

```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2026-02-23T03:15:19.895Z"
}
```

### 4. API 文档

**端点：** `GET /api/docs`

**请求示例：**

```bash
curl http://localhost:3000/api/docs
```

**响应示例：**

```json
{
  "name": "INAV Transpiler API",
  "version": "1.0.0",
  "endpoints": [...]
}
```

## 🛠️ 工具和客户端

### Node.js CLI 工具

```bash
# Transpile：JavaScript 转 INAV 命令
node cli.js transpile "if (inav.flight.isArmed) { inav.flight.disarm(); }"

# Decompile：INAV 命令转 JavaScript
# 只有逻辑条件
node cli.js decompile "logic 0 1"

# 同时有逻辑和动作命令
node cli.js decompile "logic 0 1" "setflight_arm"

# 显示帮助
node cli.js help
```

### Python 客户端

```bash
# Transpile：JavaScript 转 INAV 命令
python3 client.py transpile "if (inav.flight.isArmed) { inav.flight.disarm(); }"

# Decompile：INAV 命令转 JavaScript
# 只有逻辑条件
python3 client.py decompile "logic 0 1"

# 同时有逻辑和动作命令
python3 client.py decompile "logic 0 1" "setflight_arm"
```

### Node.js 客户端示例

```bash
node examples/client.js
```

## 💻 代码集成示例

### JavaScript/Node.js

```javascript
// Transpile
const response = await fetch("http://localhost:3000/api/v1/transpile", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    code: "if (inav.flight.armed) { inav.flight.disarm(); }",
  }),
});

const data = await response.json();
console.log("Commands:", data.commands);
console.log("Warnings:", data.warnings);
console.log("Errors:", data.errors);

// Decompile
const decompileResponse = await fetch(
  "http://localhost:3000/api/v1/decompile",
  {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      commands: ["logic 0 1", "setflight_arm"],
    }),
  },
);

const decompileData = await decompileResponse.json();
console.log("Generated Code:", decompileData.code);
```

### Python

```python
import requests
import json

API_URL = 'http://localhost:3000'

# Transpile
response = requests.post(f'{API_URL}/api/v1/transpile', json={
    'code': 'if (inav.flight.armed) { inav.flight.disarm(); }'
})
data = response.json()
print('Commands:', data['commands'])

# Decompile
response = requests.post(f'{API_URL}/api/v1/decompile', json={
    'commands': ['logic 0 1', 'setflight_arm']
})
data = response.json()
print('Generated Code:', data['code'])
```

### cURL

```bash
# Transpile
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{"code":"if (inav.flight.armed) { inav.flight.disarm(); }"}'

# Decompile
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{"commands":["logic 0 1","setflight_arm"]}'
```

## 🔄 常见工作流程

### 工作流程 1: 开发和测试

```bash
# 1. 启动服务器（开发模式）
npm run dev

# 2. 在另一个终端测试
node cli.js transpile "your javascript code"

# 3. 查看结果和错误信息
```

### 工作流程 2: 批量处理

```bash
# 1. 创建 JavaScript 文件列表
# 2. 使用 Python 脚本批量转译
python3 << 'EOF'
import requests
import json

files = ['code1.js', 'code2.js', 'code3.js']
api = 'http://localhost:3000/api/v1/transpile'

for file in files:
    with open(file, 'r') as f:
        code = f.read()

    response = requests.post(api, json={'code': code})
    data = response.json()

    print(f"{file}:")
    for cmd in data['commands']:
        print(f"  {cmd}")
EOF
```

### 工作流程 3: 集成到 Web 应用

```html
<!DOCTYPE html>
<html>
  <head>
    <title>INAV Transpiler</title>
  </head>
  <body>
    <textarea id="code" placeholder="输入JavaScript代码"></textarea>
    <button onclick="transpile()">转译</button>
    <pre id="output"></pre>

    <script>
      async function transpile() {
        const code = document.getElementById("code").value;

        const response = await fetch("http://localhost:3000/api/v1/transpile", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ code }),
        });

        const data = await response.json();
        document.getElementById("output").textContent = JSON.stringify(
          data,
          null,
          2,
        );
      }
    </script>
  </body>
</html>
```

## 📊 错误处理

### 常见错误响应

**错误 1: 空代码**

```json
{
  "success": false,
  "error": "Invalid request: code must be a non-empty string",
  "example": { "code": "if (inav.flight.armed) { inav.flight.disarm(); }" }
}
```

**错误 2: 缺少字段**

```json
{
  "success": false,
  "error": "Invalid request: commands must be provided",
  "example": { "commands": ["logic 0 1", "setflight_arm"] }
}
```

**错误 3: 语法错误**

```json
{
  "success": false,
  "error": "Parse errors:\n  - Unexpected token at line 5",
  "details": null
}
```

## 📈 性能优化

### 1. 启用缓存

```javascript
const cache = new Map();

function transpileWithCache(code) {
  const key = JSON.stringify({ code });
  if (cache.has(key)) {
    return cache.get(key);
  }

  const result = transpiler.transpile(code);
  cache.set(key, result);
  return result;
}
```

### 2. 批量处理

对于大量代码转译，建议分批处理以避免超时。

### 3. 连接池

在高并发场景下使用连接池。

## 🔐 安全建议

1. **验证输入** - 检查代码大小和格式
2. **速率限制** - 防止滥用
3. **CORS 配置** - 只允许受信任的来源
4. **错误隐藏** - 不要泄露内部错误信息
5. **日志记录** - 记录所有API调用便于审计

## 📚 更多资源

- [README.md](./README.md) - 完整文档
- [QUICKSTART.md](./QUICKSTART.md) - 快速开始
- [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
- [API文档](http://localhost:3000/api/docs) - 交互式文档

## 💡 提示和技巧

1. **使用 CLI 快速测试**: `node cli.js transpile "code"`
2. **启用日志**: 在服务器日志中查看详细信息
3. **批量操作**: 使用脚本进行批量转译/反编译
4. **错误调试**: 查看 `errors` 和 `warnings` 字段获取详细信息
5. **性能监控**: 使用 Node.js profiler 监控性能

---

**准备好开始了吗? 🚀**

```bash
npm start
node cli.js transpile "if (inav.flight.armed) { inav.flight.disarm(); }"
```
