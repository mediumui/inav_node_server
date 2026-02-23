# INAV Node.js API 服务器 - 部署指南

## 📦 完整部署流程

### 第一步：安装依赖

```bash
cd /Users/jingsiyue/Documents/inav/node_server
npm install
```

**验证安装：**

```bash
npm list
```

### 第二步：启动服务器

#### 选项 1: 使用启动脚本 (推荐)

```bash
# 启动服务器
./start.sh start

# 或指定端口
./start.sh start 8080

# 停止服务器
./start.sh stop

# 重启服务器
./start.sh restart

# 开发模式（启用hot-reload）
./start.sh dev

# 查看日志
./start.sh logs

# 查看状态
./start.sh status
```

#### 选项 2: 直接使用npm

```bash
# 启动
npm start

# 开发模式
npm run dev

# 指定端口
PORT=8080 npm start
```

#### 选项 3: 使用Node.js直接运行

```bash
node server.js

# 指定端口
PORT=8080 node server.js
```

### 第三步：验证服务器

```bash
# 健康检查
curl http://localhost:3000/health

# 查看API文档
curl http://localhost:3000/api/docs
```

**预期响应：**

```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2026-02-23T03:15:19.895Z"
}
```

## 🧪 测试API

### 方法 1: Node.js 客户端

```bash
node examples/client.js
```

### 方法 2: CLI 工具

```bash
# Transpile
node cli.js transpile "if (inav.flight.isArmed) { inav.flight.disarm(); }"

# Decompile（反编译：从INAV命令重构JavaScript）
# 提供你已经有的INAV命令，decompile会生成对应的JavaScript代码
node cli.js decompile "logic 0 1"

# 如果你同时有条件逻辑和动作命令
node cli.js decompile "logic 0 1" "setflight_arm"

# 查看帮助
node cli.js help
```

### 方法 3: Python 客户端

```bash
# Transpile
python3 client.py transpile "if (inav.flight.isArmed) { inav.flight.disarm(); }"

# Decompile（反编译：从INAV命令重构JavaScript）
python3 client.py decompile "logic 0 1"

# 如果你同时有条件逻辑和动作命令
python3 client.py decompile "logic 0 1" "setflight_arm"
```

### 方法 4: curl

```bash
# Transpile（JavaScript转INAV命令）
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "if (inav.flight.isArmed) { inav.flight.disarm(); }"
  }'

# Decompile（INAV命令转JavaScript）
# 示例1：只有逻辑条件
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1"]
  }'

# 示例2：同时有逻辑条件和动作命令
curl -X POST http://localhost:3000/api/v1/decompile \
  -H "Content-Type: application/json" \
  -d '{
    "commands": ["logic 0 1", "setflight_arm"]
  }'
```

### 方法 5: 运行完整测试套件

```bash
npm test
```

## 🐳 Docker 部署

### 创建 Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# 复制 package.json
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 3000

# 启动服务器
CMD ["npm", "start"]
```

### 构建和运行 Docker 镜像

```bash
# 构建镜像
docker build -t inav-node-server .

# 运行容器
docker run -d -p 3000:3000 --name inav-server inav-node-server

# 查看日志
docker logs -f inav-server

# 停止容器
docker stop inav-server
```

## 🚀 生产环境部署

### 使用 PM2 管理进程

```bash
# 安装 PM2
npm install -g pm2

# 启动应用
pm2 start server.js --name "inav-api"

# 设为开机启动
pm2 startup

# 查看日志
pm2 logs inav-api

# 查看状态
pm2 status

# 停止应用
pm2 stop inav-api

# 重启应用
pm2 restart inav-api
```

### 使用 systemd (Linux)

**创建 /etc/systemd/system/inav-api.service：**

```ini
[Unit]
Description=INAV Node.js API Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/node_server
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment="PORT=3000"

[Install]
WantedBy=multi-user.target
```

**启动服务：**

```bash
sudo systemctl start inav-api
sudo systemctl enable inav-api
sudo systemctl status inav-api
```

## 🔧 环境配置

### 使用 .env 文件

创建 `.env` 文件：

```bash
PORT=3000
LOG_LEVEL=info
CORS_ENABLED=true
CORS_ORIGINS=*
BODY_SIZE_LIMIT=10mb
NODE_ENV=production
```

加载环境变量：

```bash
source .env
npm start
```

## 📊 监控和日志

### 查看实时日志

```bash
# 使用启动脚本
./start.sh logs

# 或直接使用tail
tail -f server.log
```

### 日志级别

- `DEBUG` - 详细的调试信息
- `INFO` - 一般信息
- `WARN` - 警告信息
- `ERROR` - 错误信息

### 性能监控

```bash
# 使用 Node.js 内置工具
node --prof server.js

# 处理性能数据
node --prof-process isolate-*.log > processed.txt
```

## 🔐 安全建议

### 1. CORS 配置

只允许受信任的来源：

```javascript
// 修改 server.js 中的 CORS 配置
app.use(
  cors({
    origin: "https://your-domain.com",
    credentials: true,
  }),
);
```

### 2. 请求大小限制

```javascript
app.use(bodyParser.json({ limit: "1mb" }));
app.use(bodyParser.urlencoded({ limit: "1mb", extended: true }));
```

### 3. 速率限制

```bash
npm install express-rate-limit
```

```javascript
import rateLimit from "express-rate-limit";

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟
  max: 100, // 每个 IP 限制 100 个请求
});

app.use("/api/", limiter);
```

### 4. 健康检查和错误处理

确保所有错误都被正确捕获和记录。

## 📈 扩展性

### 负载均衡

使用 Nginx 进行负载均衡：

```nginx
upstream inav_api {
  server localhost:3000;
  server localhost:3001;
  server localhost:3002;
}

server {
  listen 80;
  server_name api.example.com;

  location / {
    proxy_pass http://inav_api;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }
}
```

### 启动多个进程

```bash
# 使用 cluster 模式
npm install -g pm2
pm2 start server.js -i max  # 使用所有 CPU 核心
```

## 🐛 故障排除

### 问题：端口已被占用

```bash
# 查找占用端口的进程
lsof -i :3000

# 杀死进程
kill -9 <PID>

# 或使用不同的端口
PORT=8080 npm start
```

### 问题：内存泄漏

```bash
# 启用内存快照
node --inspect server.js

# 使用 Chrome DevTools 连接
# chrome://inspect
```

### 问题：性能慢

```bash
# 使用性能分析工具
node --prof server.js
node --prof-process isolate-*.log > processed.txt
```

## 📋 检查清单

在将服务器部署到生产环境之前，请确保：

- [ ] 所有依赖已安装 (`npm install`)
- [ ] 环境变量已配置 (`.env` 文件)
- [ ] 服务器正常运行 (`./start.sh status`)
- [ ] 健康检查成功 (`curl /health`)
- [ ] API 测试通过 (`npm test`)
- [ ] 日志记录已启用
- [ ] 错误处理已实现
- [ ] CORS 已正确配置
- [ ] SSL/TLS 已设置（如果使用 HTTPS）
- [ ] 监控和告警已配置
- [ ] 备份和灾难恢复计划已准备

## 📞 常见问题

### Q: 如何在多个端口上运行多个实例？

```bash
PORT=3000 npm start &
PORT=3001 npm start &
PORT=3002 npm start &
```

### Q: 如何集成到 CI/CD 管道？

查看 [CI/CD 集成指南](./CI_CD.md)

### Q: 如何优化性能？

1. 启用缓存
2. 使用 CDN
3. 优化数据库查询
4. 实现连接池

## 📚 相关文档

- [README.md](./README.md) - 主文档
- [QUICKSTART.md](./QUICKSTART.md) - 快速开始指南
- [API 文档](http://localhost:3000/api/docs) - 交互式 API 文档

---

**祝你部署顺利! 🚀**
