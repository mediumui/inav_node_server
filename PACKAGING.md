# INAV Node Server 打包指南

本指南介绍如何以多种方式打包和部署 INAV Node Server。

## 目录

1. [快速开始](#快速开始)
2. [打包方式](#打包方式)
3. [Docker 部署](#docker-部署)
4. [NPM 包分发](#npm-包分发)
5. [独立可执行文件](#独立可执行文件)
6. [CI/CD 自动化](#cicd-自动化)
7. [生产部署清单](#生产部署清单)

## 快速开始

### 方式 1：使用打包脚本（推荐）

```bash
# 查看帮助
./build.sh help

# 设置 Docker 配置
./build.sh docker-setup

# 生成所有包
./build.sh all

# 生成特定包
./build.sh docker      # Docker 镜像
./build.sh zip         # ZIP 压缩包
./build.sh npm         # NPM 包
```

### 方式 2：使用 Docker Compose（最简单）

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 打包方式

### 1. Docker 镜像打包

#### 优点

- ✅ 完整的隔离环境
- ✅ 跨平台运行
- ✅ 易于扩展和部署
- ✅ 支持容器编排（Kubernetes）

#### 生成方式

```bash
# 使用打包脚本
./build.sh docker-setup  # 创建 Dockerfile
./build.sh docker        # 生成镜像

# 或手动构建
docker build -t inav-node-server:1.0.0 .

# 保存为 tar 文件
docker save inav-node-server:1.0.0 -o inav-server.tar
```

#### 运行 Docker 镜像

```bash
# 基础运行
docker run -p 3000:3000 inav-node-server:1.0.0

# 带环境变量
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  inav-node-server:1.0.0

# 后台运行
docker run -d -p 3000:3000 \
  --name inav-server \
  --restart unless-stopped \
  inav-node-server:1.0.0

# 查看日志
docker logs -f inav-server

# 停止容器
docker stop inav-server
```

#### 推送到 Docker Hub

```bash
# 登录
docker login

# 标记镜像
docker tag inav-node-server:1.0.0 yourusername/inav-node-server:1.0.0
docker tag inav-node-server:1.0.0 yourusername/inav-node-server:latest

# 推送
docker push yourusername/inav-node-server:1.0.0
docker push yourusername/inav-node-server:latest
```

### 2. Docker Compose 部署

#### 优点

- ✅ 一键启动完整服务栈
- ✅ 易于管理多个容器
- ✅ 支持资源限制
- ✅ 便于本地开发

#### 使用方式

```bash
# 查看 docker-compose.yml
cat docker-compose.yml

# 构建并启动
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f inav-server

# 重启服务
docker-compose restart

# 停止并删除容器
docker-compose down

# 完全清理（包括卷）
docker-compose down -v
```

#### 访问服务

```bash
# 健康检查
curl http://localhost:3000/health

# 获取 API 文档
curl http://localhost:3000/api/docs

# Transpile 示例
curl -X POST http://localhost:3000/api/v1/transpile \
  -H "Content-Type: application/json" \
  -d '{"code": "if (inav.flight.isArmed) { inav.flight.disarm(); }"}'
```

### 3. ZIP 压缩包

#### 优点

- ✅ 便于传输
- ✅ 兼容性好
- ✅ 易于备份

#### 生成和使用

```bash
# 生成 ZIP
./build.sh zip

# 或手动创建
zip -r inav-node-server-1.0.0.zip \
  server.js routes/ js/ package.json package-lock.json \
  README.md START_HERE.md cli.js client.py start.sh

# 解压
unzip inav-node-server-1.0.0.zip
cd inav-node-server

# 安装和运行
npm install
npm start
```

### 4. NPM 包

#### 优点

- ✅ 作为库依赖使用
- ✅ 版本管理
- ✅ 易于集成

#### 发布

```bash
# 生成 npm 包
npm pack

# 或使用打包脚本
./build.sh npm

# 查看包内容
npm pack --pack-destination=./dist

# 发布到 npm（需要账户）
npm publish

# 发布到私有 registry
npm publish --registry https://your-registry.com
```

#### 使用发布的包

```bash
# 从 npm 安装
npm install inav-node-server

# 在代码中使用
import { Transpiler, Decompiler } from 'inav-node-server/js/transpiler/transpiler/index.js';
```

### 5. 独立可执行文件

#### 优点

- ✅ 无需 Node.js
- ✅ 单个文件部署
- ✅ 易于分发

#### 生成方式

```bash
# 安装 pkg（全局或本地）
npm install -g pkg
# 或
npm install --save-dev pkg

# 生成可执行文件
pkg server.js -o inav-server

# 或使用打包脚本
./build.sh exe

# 运行
./inav-server

# 指定端口
PORT=8080 ./inav-server
```

#### 支持的平台

```bash
# Windows
pkg server.js -t win-x64

# macOS
pkg server.js -t macos-x64

# Linux
pkg server.js -t linux-x64

# 多平台
pkg server.js -t win-x64,macos-x64,linux-x64
```

## NPM 包分发

### 更新 package.json

```json
{
  "name": "inav-node-server",
  "version": "1.0.0",
  "description": "INAV JavaScript Transpiler Node.js API Server",
  "main": "server.js",
  "bin": {
    "inav-server": "./server.js"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/yourusername/inav-node-server.git"
  },
  "keywords": ["inav", "transpiler", "javascript"],
  "author": "Your Name",
  "license": "MIT",
  "engines": {
    "node": ">=14.0.0"
  }
}
```

### 发布流程

```bash
# 1. 更新版本
npm version minor  # 或 patch, major

# 2. 创建 git 标签
git tag v1.0.0
git push origin v1.0.0

# 3. 生成包
npm pack

# 4. 测试包
npm install ./inav-node-server-1.0.0.tgz

# 5. 发布
npm publish
```

## CI/CD 自动化

### 使用 GitHub Actions

```bash
# 设置 CI/CD
./build.sh ci-setup
```

这会创建 `.github/workflows/build.yml`，在每次提交时自动：

- ✅ 构建 Docker 镜像
- ✅ 运行测试
- ✅ 推送到 Docker Hub
- ✅ 更新镜像标签

### 配置 Docker Hub 凭据

1. 登录 GitHub
2. Settings → Secrets → New repository secret
3. 添加以下密钥：
   - `DOCKER_USERNAME` - Docker Hub 用户名
   - `DOCKER_PASSWORD` - Docker Hub 密码或 token
   - `DOCKER_REGISTRY` - 镜像仓库（如 `docker.io/yourusername`）

## 生产部署清单

### 部署前检查

- [ ] 设置环境变量（`NODE_ENV=production`）
- [ ] 配置日志记录
- [ ] 设置错误监控（如 Sentry）
- [ ] 配置反向代理（Nginx）
- [ ] 启用 HTTPS/SSL
- [ ] 配置 CORS 策略
- [ ] 设置请求大小限制
- [ ] 配置速率限制
- [ ] 设置数据备份计划
- [ ] 配置监控和告警

### Nginx 反向代理配置

```nginx
upstream inav_api {
  server localhost:3000;
  # 可添加多个实例进行负载均衡
  # server localhost:3001;
  # server localhost:3002;
}

server {
  listen 80;
  server_name api.example.com;

  # 重定向到 HTTPS
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name api.example.com;

  # SSL 证书
  ssl_certificate /path/to/cert.pem;
  ssl_certificate_key /path/to/key.pem;

  # 安全头
  add_header Strict-Transport-Security "max-age=31536000" always;
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Content-Type-Options "nosniff" always;

  # 代理设置
  location / {
    proxy_pass http://inav_api;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;

    # 超时设置
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
  }
}
```

### 使用 PM2 进行进程管理

```bash
# 安装 PM2
npm install -g pm2

# 启动应用
pm2 start server.js --name "inav-api"

# 开机启动
pm2 startup
pm2 save

# 查看状态
pm2 status

# 查看日志
pm2 logs inav-api

# 集群模式（多核心）
pm2 start server.js -i max --name "inav-api"
```

### Kubernetes 部署

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inav-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: inav-server
  template:
    metadata:
      labels:
        app: inav-server
    spec:
      containers:
        - name: inav-server
          image: yourusername/inav-node-server:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "3000"
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: inav-server-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 3000
  selector:
    app: inav-server
```

## 常见问题

### Q: 我应该使用哪种打包方式？

**A**:

- **开发环境** → 直接运行 `npm start`
- **测试环境** → 使用 Docker Compose
- **生产环境** → Docker 镜像 + Kubernetes 或 Docker Swarm
- **简单部署** → ZIP 包 + PM2

### Q: 如何减小 Docker 镜像大小？

**A**:

- 使用多阶段构建（已在 Dockerfile 中实现）
- 使用 alpine 基础镜像
- 仅安装生产依赖（`npm ci --only=production`）
- 定期清理不必要的文件

### Q: 如何在生产环境中安全部署？

**A**:

- 使用非 root 用户运行应用
- 配置 HTTPS/SSL
- 设置防火墙规则
- 启用日志记录和监控
- 定期更新依赖包
- 使用反向代理（如 Nginx）

### Q: 如何处理应用更新？

**A**:

```bash
# Docker
docker pull yourusername/inav-node-server:latest
docker-compose down
docker-compose up -d

# PM2
pm2 reload inav-api
```

## 总结

| 方式           | 适用场景   | 难度 | 资源占用 |
| -------------- | ---------- | ---- | -------- |
| 直接运行       | 开发       | 低   | 低       |
| ZIP 包         | 简单部署   | 低   | 中       |
| Docker         | 标准部署   | 中   | 中       |
| Docker Compose | 完整栈     | 中   | 中       |
| Kubernetes     | 大规模     | 高   | 高       |
| 可执行文件     | 无依赖环境 | 中   | 低       |

---

**更新日期**: 2026-02-23  
**版本**: 1.0.0
