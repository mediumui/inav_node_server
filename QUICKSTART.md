# INAV Node.js API 服务器 - 快速启动指南

## 📋 前置要求

- Node.js 14+ 或更高版本
- npm 6+ 或 yarn

## 🚀 快速开始（5分钟）

### 1️⃣ 安装依赖

```bash
cd /Users/jingsiyue/Documents/inav/node_server
npm install
```

### 2️⃣ 启动服务器

```bash
npm start
```

你应该看到:

```
========================================
INAV Node.js API Server
========================================
Server running on http://localhost:3000

API Documentation: http://localhost:3000/api/docs
Health Check: http://localhost:3000/health

Endpoints:
  POST http://localhost:3000/api/v1/transpile   - JS to INAV
  POST http://localhost:3000/api/v1/decompile   - INAV to JS
========================================
```

### 3️⃣ 测试API

在另一个终端运行:

```bash
# 方法1: Node.js 客户端
node examples/client.js

# 方法2: CLI工具
node cli.js transpile "if (inav.flight.isArmed) { inav.flight.disarm(); }"
node cli.js decompile "logic 0 1" "setflight_arm"

# 方法3: Python客户端
python3 client.py transpile "if (inav.flight.armed) { inav.flight.disarm(); }"
python3 client.py decompile "logic 0 1" "setflight_arm"

# 方法4: curl
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{"code":"if (inav.flight.armed) { inav.flight.disarm(); }"}'

# 方法5: 运行测试套件
npm test
```

## 📚 API 使用示例

### 示例1: JavaScript 转 INAV (Transpile)

**请求:**

```bash
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "if (inav.flight.armed) { inav.flight.disarm(); }"
  }'
```

**响应:**

```json
{
  "success": true,
  "commands": ["logic 0 1", "setflight_disarm"],
  "output": "...",
  "warnings": [],
  "errors": [],
  "lineCount": 2,
  "timestamp": "2026-02-23T10:00:00.000Z"
}
```

### 示例2: INAV 转 JavaScript (Decompile)

**请求:**

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1", "setflight_arm"]
  }'
```

**响应:**

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

## 🔧 开发模式

启用自动重启（文件更改时）:

```bash
npm run dev
```

## 📝 可用脚本

```bash
npm start        # 启动生产服务器
npm run dev      # 启动开发服务器（启用hot-reload）
npm test         # 运行测试套件
node cli.js      # 本地CLI工具
python3 client.py  # Python客户端
```

## 🗂️ 项目结构

```
node_server/
├── server.js              # 主服务器文件
├── routes/
│   └── api.js            # API路由和处理器
├── examples/
│   └── client.js         # JavaScript客户端示例
├── cli.js                # Node.js命令行工具
├── client.py             # Python客户端
├── test.js               # 测试套件
├── package.json          # npm配置
├── .env.example          # 环境变量示例
├── .gitignore            # Git忽略文件
├── README.md             # 主文档
└── js/transpiler/        # Transpiler核心实现
    ├── transpiler/       # 转译器和反编译器
    ├── api/              # API定义
    └── examples/         # 示例代码
```

## 🌐 环境变量

创建 `.env` 文件:

```bash
PORT=3000
LOG_LEVEL=info
CORS_ENABLED=true
```

运行:

```bash
npm start
```

或直接传递:

```bash
PORT=8080 npm start
```

## 📍 端点速参

| 方法 | 路径                | 说明     |
| ---- | ------------------- | -------- |
| GET  | `/health`           | 健康检查 |
| GET  | `/api/docs`         | API文档  |
| POST | `/api/v1/transpile` | JS转INAV |
| POST | `/api/v1/decompile` | INAV转JS |

## 🔗 集成示例

### React应用

```javascript
const response = await fetch("http://localhost:3000/api/v1/transpile", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    code: "if (inav.flight.armed) { inav.flight.disarm(); }",
  }),
});
const data = await response.json();
console.log(data.commands);
```

### Node.js应用

```javascript
import fetch from "node-fetch";

const response = await fetch("http://localhost:3000/api/v1/transpile", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    code: "if (inav.flight.armed) { inav.flight.disarm(); }",
  }),
});
const data = await response.json();
```

## ❓ 常见问题

### Q: 端口已被占用怎么办？

```bash
PORT=8080 npm start
```

### Q: 无法连接到服务器？

```bash
# 检查服务器是否运行
curl http://localhost:3000/health

# 查看是否有错误日志
# 服务器应该输出运行信息
```

### Q: 如何调试？

```bash
# 使用开发模式和查看日志
npm run dev

# 或使用Node.js debugger
node --inspect server.js
```

## 📖 更多资源

- [README.md](./README.md) - 详细文档
- [API文档](http://localhost:3000/api/docs) - 交互式API文档
- [INAV Configurator](https://github.com/iNavFlight/inav-configurator)

## 🆘 故障排除

### 模块导入错误

确保所有transpiler文件都存在:

```bash
ls -la js/transpiler/transpiler/
```

### 依赖问题

重新安装依赖:

```bash
rm -rf node_modules package-lock.json
npm install
```

### 权限问题

确保有执行权限:

```bash
chmod +x server.js cli.js
```

## 💡 下一步

1. ✅ 服务器已启动
2. ✅ API文档可用
3. ✅ 测试用例编写完成
4. 🔄 将其集成到你的应用中
5. 🚀 部署到生产环境

## 📞 支持

有问题? 查看:

- [README.md](./README.md) - 完整文档
- 运行 `node cli.js help` - CLI帮助
- 打开浏览器访问 http://localhost:3000/api/docs - API文档

---

**快乐编码! 🚀**
