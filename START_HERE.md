# 🚀 INAV Node.js API 服务器 - 开始使用

> **快速导航**: 5分钟内启动并运行 INAV API 服务器

## ⚡ 超快速开始 (2分钟)

### 1️⃣ 启动服务器

```bash
cd /Users/jingsiyue/Documents/inav/node_server
npm start
```

### 2️⃣ 测试 API

在另一个终端运行:

```bash
# 方法A: 使用 CLI
node cli.js transpile "if (inav.flight.isArmed) { inav.flight.disarm(); }"

# 方法B: 使用 curl
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{"code":"if (inav.flight.armed) { inav.flight.disarm(); }"}'

# 方法C: 健康检查
curl http://localhost:3000/health
```

✅ **完成！** 你的 INAV API 服务器正在运行！

---

## 📚 文档导航

| 文档                                 | 用途         | 时间 |
| ------------------------------------ | ------------ | ---- |
| **[QUICKSTART.md](./QUICKSTART.md)** | 5分钟入门    | 5分  |
| **[USAGE.md](./USAGE.md)**           | API 使用指南 | 15分 |
| **[DEPLOYMENT.md](./DEPLOYMENT.md)** | 生产部署     | 30分 |
| **[README.md](./README.md)**         | 完整文档     | 全面 |

---

## 🎯 常见任务

### 任务 1: 启动服务器

```bash
npm start
# 或
./start.sh start
# 或指定端口
PORT=8080 npm start
```

### 任务 2: 停止服务器

```bash
# 使用 Ctrl+C (如果在前台运行)
# 或使用脚本
./start.sh stop
```

### 任务 3: 查看日志

```bash
./start.sh logs
# 或
tail -f server.log
```

### 任务 4: 运行测试

```bash
npm test
```

### 任务 5: 开发模式 (自动重启)

```bash
npm run dev
# 或
./start.sh dev
```

---

## 🔧 API 速参

### Transpile (JS → INAV)

```bash
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "if (inav.flight.armed) { inav.flight.disarm(); }"
  }'
```

**响应**:

```json
{
  "success": true,
  "commands": ["logic 0 1", "setflight_disarm"],
  "errors": [],
  "warnings": []
}
```

### Decompile (INAV → JS)

```bash
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1", "setflight_arm"]
  }'
```

**响应**:

```json
{
  "success": true,
  "code": "if (condition) {\n  inav.flight.arm();\n}",
  "errors": [],
  "warnings": []
}
```

### 健康检查

```bash
curl http://localhost:3000/health
```

**响应**:

```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2026-02-23T03:17:21.978Z"
}
```

### API 文档

```bash
curl http://localhost:3000/api/docs
```

---

## 💻 代码示例

### Node.js

```javascript
fetch("http://localhost:3000/api/v1/transpile", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    code: "if (inav.flight.armed) { inav.flight.disarm(); }",
  }),
})
  .then((r) => r.json())
  .then((data) => console.log(data.commands));
```

### Python

```python
import requests

response = requests.post('http://localhost:3000/api/v1/transpile', json={
    'code': 'if (inav.flight.armed) { inav.flight.disarm(); }'
})
print(response.json()['commands'])
```

### cURL

```bash
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{"code":"if (inav.flight.armed) { inav.flight.disarm(); }"}'
```

---

## 🛠️ 工具命令

### CLI 工具

```bash
# Transpile
node cli.js transpile "code here"

# Decompile
node cli.js decompile "command1" "command2" ...

# 帮助
node cli.js help
```

### Python 客户端

```bash
# Transpile
python3 client.py transpile "code here"

# Decompile
python3 client.py decompile "cmd1" "cmd2" ...
```

### 启动脚本

```bash
./start.sh start              # 启动
./start.sh stop               # 停止
./start.sh restart            # 重启
./start.sh dev                # 开发模式
./start.sh status             # 状态
./start.sh logs               # 日志
./start.sh help               # 帮助
```

### npm 命令

```bash
npm start                     # 启动
npm run dev                   # 开发
npm test                      # 测试
```

---

## ❓ 常见问题

### Q: 端口已被占用？

```bash
PORT=8080 npm start
```

### Q: 如何查看实时日志？

```bash
./start.sh logs
```

### Q: 服务器不启动？

```bash
# 查看是否有依赖问题
npm install

# 查看日志
cat server.log

# 检查端口
lsof -i :3000
```

### Q: API 返回错误？

检查:

1. 服务器是否运行: `curl http://localhost:3000/health`
2. 请求格式是否正确: 查看 [USAGE.md](./USAGE.md)
3. 查看错误信息: 响应中的 `errors` 字段

### Q: 如何集成到我的应用？

参考 [USAGE.md](./USAGE.md) 中的集成示例

---

## 🎓 学习路径

### 初学者

1. ✅ 阅读本文 (你在这里!)
2. 📖 [QUICKSTART.md](./QUICKSTART.md) - 5分钟入门
3. 🔗 尝试第一个 API 调用

### 开发者

1. 📖 [USAGE.md](./USAGE.md) - API 详解
2. 💻 集成到应用
3. 🧪 运行测试

### 运维

1. 📖 [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
2. 🚀 部署到生产
3. 📊 监控和维护

---

## 📊 项目信息

| 项目         | 详情                    |
| ------------ | ----------------------- |
| **名称**     | INAV Node.js API Server |
| **版本**     | 1.0.0                   |
| **状态**     | ✅ 生产就绪             |
| **服务器**   | Express.js              |
| **端口**     | 3000 (默认)             |
| **API 版本** | v1                      |
| **文档**     | 完整                    |

---

## ✅ 检查清单

启动前，确保:

- [ ] Node.js 已安装 (`node --version`)
- [ ] npm 已安装 (`npm --version`)
- [ ] 端口 3000 未被占用 (`lsof -i :3000`)
- [ ] 依赖已安装 (`npm install`)

---

## 🚀 现在就开始！

```bash
# 1. 进入目录
cd /Users/jingsiyue/Documents/inav/node_server

# 2. 启动服务器
npm start

# 3. 在另一个终端测试
curl http://localhost:3000/health
```

**就这么简单！** 🎉

---

## 📞 需要帮助？

1. **查看 API 文档**: http://localhost:3000/api/docs
2. **阅读文档**:
   - [README.md](./README.md) - 完整指南
   - [USAGE.md](./USAGE.md) - API 使用
   - [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署
3. **运行测试**: `npm test`
4. **查看日志**: `./start.sh logs`

---

## 🎯 下一步

选择一个:

- 📖 **快速学习**: [QUICKSTART.md](./QUICKSTART.md)
- 🔗 **API 集成**: [USAGE.md](./USAGE.md)
- 🚀 **生产部署**: [DEPLOYMENT.md](./DEPLOYMENT.md)
- 📚 **完整文档**: [README.md](./README.md)

---

**祝你使用愉快！🚀**
