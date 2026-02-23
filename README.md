# INAV Node.js API Server

基于INAV JavaScript Transpiler的Node.js REST API服务。

## 功能特性

✅ **JavaScript 转 INAV指令** - 将JavaScript代码转换为INAV CLI命令
✅ **INAV指令 转 JavaScript** - 将INAV CLI命令反编译为JavaScript代码
✅ **REST API** - 标准的HTTP JSON接口
✅ **错误处理** - 完整的错误报告和诊断
✅ **CORS支持** - 支持跨域请求
✅ **API文档** - 自动生成的API文档

## 快速开始

### 1. 安装依赖

```bash
cd /Users/jingsiyue/Documents/inav/node_server
npm install
```

### 2. 启动服务器

```bash
npm start
```

服务器将在 `http://localhost:3000` 启动

### 3. 测试API

在另一个终端中运行客户端示例：

```bash
node examples/client.js
```

## API 端点

### 1. 健康检查

```
GET /health
```

**响应示例：**

```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2026-02-23T10:00:00.000Z"
}
```

### 2. API文档

```
GET /api/docs
```

获取所有可用API端点的文档

### 3. JavaScript 转 INAV (Transpile)

```
POST /api/v1/transpile
```

**请求体：**

```json
{
  "code": "if (inav.flight.armed) { inav.flight.disarm(); }"
}
```

**响应示例：**

```json
{
  "success": true,
  "commands": ["logic 0 1", "setflight_disarm"],
  "output": "formatted output...",
  "warnings": [],
  "errors": [],
  "lineCount": 2,
  "timestamp": "2026-02-23T10:00:00.000Z"
}
```

### 4. INAV 转 JavaScript (Decompile)

```
POST /api/v1/decompile
```

**请求体（方式1 - 数组）：**

```json
{
  "commands": ["logic 0 1", "setflight_arm"]
}
```

**请求体（方式2 - 字符串）：**

```json
{
  "commands": "logic 0 1\nsetflight_arm"
}
```

**响应示例：**

```json
{
  "success": true,
  "code": "if (condition) {\n  inav.flight.arm();\n}",
  "warnings": [],
  "errors": [],
  "commandCount": 2,
  "timestamp": "2026-02-23T10:00:00.000Z"
}
```

## 使用示例

### 使用 curl

**Transpile:**

```bash
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{"code":"if (inav.flight.armed) { inav.flight.disarm(); }"}'
```

**Decompile:**

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{"commands":["logic 0 1","setflight_arm"]}'
```

### 使用 JavaScript Fetch API

```javascript
// Transpile
const transpileResponse = await fetch(
  "http://localhost:3000/api/v1/transpile",
  {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      code: "if (inav.flight.armed) { inav.flight.disarm(); }",
    }),
  },
);
const transpileData = await transpileResponse.json();
console.log(transpileData);

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
console.log(decompileData);
```

### 使用 Python

```python
import requests
import json

API_URL = 'http://localhost:3000'

# Transpile
response = requests.post(f'{API_URL}/api/v1/transpile', json={
    'code': 'if (inav.flight.armed) { inav.flight.disarm(); }'
})
print(response.json())

# Decompile
response = requests.post(f'{API_URL}/api/v1/decompile', json={
    'commands': ['logic 0 1', 'setflight_arm']
})
print(response.json())
```

## 开发

### 启用实时重载

```bash
npm run dev
```

这将使用 `--watch` 标志运行Node.js，在文件更改时自动重启服务器。

### 项目结构

```
node_server/
├── server.js                 # 主服务器文件
├── package.json              # 依赖配置
├── routes/
│   └── api.js               # API路由处理器
├── examples/
│   └── client.js            # 客户端示例
├── js/
│   └── transpiler/          # 核心transpiler实现
│       ├── transpiler/      # 转译器和反编译器
│       ├── api/             # API定义
│       └── examples/        # 示例代码
└── README.md                # 本文件
```

## 环境变量

- `PORT` - 服务器端口（默认：3000）

示例：

```bash
PORT=8080 npm start
```

## 故障排除

### 端口已被占用

如果看到 "Port 3000 is already in use" 错误，可以：

1. 使用不同的端口：

   ```bash
   PORT=3001 npm start
   ```

2. 或者杀死占用该端口的进程：
   ```bash
   # macOS/Linux
   lsof -i :3000
   kill -9 <PID>
   ```

### 模块未找到

确保已安装所有依赖：

```bash
npm install
```

### INAV导入错误

确保js/transpiler目录结构完整，所有必需的模块都已存在。

## 支持的JavaScript特性

- `if/else` 条件语句
- 逻辑运算符 (`&&`, `||`, `!`)
- 比较运算符 (`==`, `!=`, `<`, `>`, `<=`, `>=`)
- INAV API访问 (`inav.flight.*`, `inav.navigation.*` 等)
- 函数调用
- 变量声明和赋值

## API响应格式

所有API响应都遵循统一的JSON格式：

**成功响应：**

```json
{
  "success": true,
  "commands": [],
  "output": "",
  "warnings": [],
  "errors": [],
  "timestamp": "2026-02-23T10:00:00.000Z"
}
```

**错误响应：**

```json
{
  "success": false,
  "error": "错误消息",
  "details": null
}
```

## 许可证

ISC

## 贡献

欢迎提交问题和拉取请求！

## 更多信息

- [INAV Configurator](https://github.com/iNavFlight/inav-configurator)
- [JavaScript Programming Documentation](./js/transpiler/CLAUDE.md)
