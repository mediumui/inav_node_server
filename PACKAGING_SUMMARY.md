# 🎉 打包服务完整方案

## 概述

INAV Node Server 已配置完整的打包和部署方案，支持 5 种打包方式：

✅ **ZIP 包** - 快速分发  
✅ **NPM 包** - 库依赖使用  
✅ **Docker 镜像** - 容器化部署  
✅ **Docker Compose** - 一键启动  
✅ **可执行文件** - 无依赖运行

---

## 📦 已生成的打包文件

```
dist/
├── inav-node-server-1.0.0.zip  (263 KB) - 完整源代码包
└── inav-node-server-1.0.0.tgz  (199 KB) - NPM 包
```

### 文件内容对比

| 文件       | 大小    | 包含内容      | 用途                 |
| ---------- | ------- | ------------- | -------------------- |
| ZIP        | 263 KB  | 源代码 + 配置 | 跨平台分发、本地部署 |
| TGZ        | 199 KB  | 所有文件      | npm 库注册表、CI/CD  |
| Docker TAR | ~150 MB | 完整镜像      | 容器部署、镜像转移   |

---

## 🚀 快速开始

### 1️⃣ **最简单方案：Docker Compose**

无需任何配置，一条命令启动：

```bash
# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps

# 访问服务
curl http://localhost:3000/health

# 停止服务
docker-compose down
```

### 2️⃣ **最快部署：ZIP 包**

不需要 Docker 的简单部署：

```bash
# 解压
unzip dist/inav-node-server-1.0.0.zip
cd inav-node-server

# 安装和运行
npm install
npm start

# 或使用 PM2
npm install -g pm2
pm2 start server.js --name "inav-api"
```

### 3️⃣ **生产部署：Docker 镜像**

适合大规模生产环境：

```bash
# 构建镜像
docker build -t inav-server:1.0.0 .

# 运行容器
docker run -d -p 3000:3000 \
  --name inav-server \
  --restart unless-stopped \
  inav-server:1.0.0

# 查看日志
docker logs -f inav-server

# 查看运行的镜像
docker images | grep inav
```

### 4️⃣ **无 Node.js 部署：可执行文件**

完全独立，不需要 Node.js 环境：

```bash
# 生成可执行文件
npm install -g pkg
./build.sh exe

# 直接运行（无需 Node.js）
./dist/inav-node-server-1.0.0

# 或指定端口
PORT=8080 ./dist/inav-node-server-1.0.0
```

### 5️⃣ **库使用：NPM 包**

作为 npm 依赖引入：

```bash
# 安装
npm install ./dist/inav-node-server-1.0.0.tgz

# 或从 npm registry
npm install inav-node-server
```

---

## 🛠️ 打包工具使用

### 完整打包脚本

```bash
# 查看帮助
./build.sh help

# 清理之前的构建
./build.sh clean

# 生成特定格式
./build.sh zip              # ZIP 包
./build.sh npm              # NPM 包
./build.sh docker           # Docker 镜像
./build.sh exe              # 可执行文件（需要 pkg）

# 生成所有格式
./build.sh all

# 设置 Docker 配置
./build.sh docker-setup

# 设置 CI/CD 工作流
./build.sh ci-setup
```

### 打包脚本选项

```bash
# 清理并重新生成所有包
./build.sh clean all

# 仅生成 Docker 镜像
./build.sh docker

# 生成 Docker 镜像和 ZIP 包
./build.sh docker zip
```

---

## 📋 配置文件说明

### 1. **Dockerfile** - Docker 镜像定义

```dockerfile
FROM node:18-alpine  # 轻量级基础镜像
# 多阶段构建
# 非 root 用户运行
# 健康检查配置
```

**特性**：

- 多阶段构建（减少镜像大小）
- 安全性：非 root 用户运行
- 健康检查：自动监控服务状态
- 生产优化：仅包含生产依赖

### 2. **docker-compose.yml** - 一键启动配置

```yaml
version: "3.8"
services:
  inav-server:
    # 服务配置
    # 端口映射
    # 环境变量
    # 资源限制
    # 重启策略
```

**特性**：

- 自动重启
- 资源限制（CPU/内存）
- 卷挂载（日志持久化）
- 健康检查

### 3. **.dockerignore** - Docker 构建忽略文件

排除不必要的文件，减少镜像大小：

- node_modules（会重新安装）
- 文档文件（\*.md）
- 测试文件（test.js, \*.test.js）
- 日志和临时文件

### 4. **build.sh** - 打包自动化脚本

完全自动化的打包工具，支持：

- ZIP 包生成
- NPM 包生成
- Docker 镜像构建
- 可执行文件生成
- CI/CD 工作流配置

---

## 📊 部署方案对比

| 方案           | 难度   | 部署时间 | 资源占用 | 扩展性 | 最佳用途   |
| -------------- | ------ | -------- | -------- | ------ | ---------- |
| 直接运行       | ⭐     | 1分钟    | 低       | 低     | 开发       |
| ZIP + PM2      | ⭐⭐   | 5分钟    | 低       | 中     | 小规模生产 |
| Docker         | ⭐⭐   | 5分钟    | 中       | 高     | 标准生产   |
| Docker Compose | ⭐     | 1分钟    | 中       | 高     | 快速测试   |
| Kubernetes     | ⭐⭐⭐ | 15分钟   | 高       | 很高   | 大规模集群 |

---

## ✅ 部署检查清单

在部署到生产环境前，请检查：

- [ ] 更新 `package.json` 版本号
- [ ] 通过所有测试 (`npm test`)
- [ ] 生成打包文件 (`./build.sh all`)
- [ ] 验证 Docker 镜像 (`docker build -t ...`)
- [ ] 设置 `.env` 生产环境变量
- [ ] 配置 HTTPS/SSL 证书
- [ ] 配置反向代理（Nginx）
- [ ] 启用日志收集
- [ ] 设置监控告警
- [ ] 备份数据和配置
- [ ] 创建灾难恢复计划
- [ ] 文档更新
- [ ] 团队培训

---

## 🌍 云平台部署

### AWS Elastic Container Service (ECS)

```bash
# 1. 上传到 ECR
aws ecr get-login-password | docker login --username AWS --password-stdin <id>.dkr.ecr.region.amazonaws.com

# 2. 标记镜像
docker tag inav-server:1.0.0 <id>.dkr.ecr.region.amazonaws.com/inav-server:1.0.0

# 3. 推送
docker push <id>.dkr.ecr.region.amazonaws.com/inav-server:1.0.0
```

### Google Cloud Run

```bash
# 一条命令部署
gcloud run deploy inav-server \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Heroku

```bash
# 1. 创建 Procfile
echo "web: node server.js" > Procfile

# 2. 部署
git push heroku main
```

### DigitalOcean App Platform

```bash
# 连接 GitHub 仓库
# 自动监测 Dockerfile
# 自动构建和部署
```

---

## 📈 生产环境最佳实践

### 1. **进程管理**

使用 PM2 管理 Node.js 进程：

```bash
npm install -g pm2

# 启动应用
pm2 start server.js --name "inav-api" --instances max

# 开机自启
pm2 startup
pm2 save

# 监控
pm2 monit
pm2 logs
```

### 2. **反向代理 (Nginx)**

```nginx
upstream inav_api {
  server localhost:3000;
  # 可添加多个实例进行负载均衡
}

server {
  listen 80;
  server_name api.example.com;

  location / {
    proxy_pass http://inav_api;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

### 3. **监控和告警**

```bash
# 启用日志
npm start > logs/server.log 2>&1

# 使用监控工具
# - PM2 Plus（内置监控）
# - Datadog
# - New Relic
# - Prometheus + Grafana
```

### 4. **自动备份**

```bash
# 定期备份配置
0 0 * * * tar -czf backups/config-$(date +%Y%m%d).tar.gz config/
```

---

## 🆘 常见问题

### Q: 应该选择哪种打包方式？

**A**:

- **开发** → 直接 `npm start`
- **快速测试** → `docker-compose up -d`
- **生产部署** → Docker 镜像 + Nginx
- **无 Node 环境** → 可执行文件
- **分发** → ZIP 包

### Q: Docker 镜像太大怎么办？

**A**:

- 使用 alpine 基础镜像（已配置）
- 多阶段构建（已配置）
- 清理 node_modules：`docker image prune -a`
- 使用 Docker 层缓存

### Q: 如何处理更新和回滚？

**A**:

```bash
# 更新
docker pull inav-server:latest
docker-compose down
docker-compose up -d

# 回滚
docker image ls  # 查看历史版本
docker-compose up -d -f docker-compose-v1.0.0.yml
```

### Q: 如何跨机器转移 Docker 镜像？

**A**:

```bash
# 源机器：保存镜像
docker save inav-server:1.0.0 -o inav-server.tar

# 目标机器：加载镜像
docker load -i inav-server.tar
```

---

## 📚 相关文档

- [PACKAGING.md](PACKAGING.md) - 详细打包指南
- [BUILD_QUICK_START.md](BUILD_QUICK_START.md) - 快速入门指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署指南
- [USAGE.md](USAGE.md) - API 使用指南
- [QUICKSTART.md](QUICKSTART.md) - 5分钟快速开始

---

## 📞 获取帮助

查看完整文档：

```bash
# 打包指南
cat PACKAGING.md

# 快速指南
cat BUILD_QUICK_START.md

# 部署指南
cat DEPLOYMENT.md

# 查看打包脚本帮助
./build.sh help
```

---

## ✨ 总结

| 功能           | 状态 | 说明                        |
| -------------- | ---- | --------------------------- |
| ZIP 打包       | ✅   | 已实现并测试                |
| NPM 包         | ✅   | 已实现并测试                |
| Docker         | ✅   | 已配置，需 Docker 环境      |
| Docker Compose | ✅   | 一键启动，需 Docker         |
| 可执行文件     | ✅   | 已配置，需 pkg              |
| CI/CD          | ✅   | GitHub Actions 工作流已配置 |
| 打包脚本       | ✅   | 完整自动化脚本              |

**现在您可以选择任意方式部署 INAV Node Server！** 🚀

---

**版本**: 1.0.0  
**最后更新**: 2026-02-23  
**文件位置**: `/Users/jingsiyue/Documents/inav/node_server/`
