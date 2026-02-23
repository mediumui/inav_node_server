# 打包快速指南

## 📦 5 分钟快速打包

### 方案 1：最简单 - Docker Compose（推荐新手）

```bash
# 一条命令启动
docker-compose up -d

# 完成！服务已运行在 http://localhost:3000
```

### 方案 2：Docker 单镜像部署

```bash
# 构建镜像
docker build -t inav-server:1.0.0 .

# 运行
docker run -d -p 3000:3000 \
  --name inav-server \
  inav-server:1.0.0

# 查看日志
docker logs -f inav-server
```

### 方案 3：ZIP 包部署（无 Docker）

```bash
# 打包
./build.sh zip

# 解压到服务器
unzip dist/inav-node-server-1.0.0.zip

# 安装运行
npm install
npm start
```

### 方案 4：独立可执行文件（无需 Node.js）

```bash
# 生成可执行文件
./build.sh exe

# 直接运行（无需 Node.js）
./dist/inav-node-server-1.0.0

# 或指定端口
PORT=8080 ./dist/inav-node-server-1.0.0
```

---

## 🎯 按场景选择

| 场景         | 推荐方案    | 命令                   |
| ------------ | ----------- | ---------------------- |
| 本地开发     | 直接运行    | `npm start`            |
| 简单测试     | Docker      | `docker-compose up -d` |
| 生产部署     | Docker 镜像 | `./build.sh docker`    |
| 无 Node 环境 | 可执行文件  | `./build.sh exe`       |
| 跨平台分发   | ZIP 包      | `./build.sh zip`       |
| npm 库       | NPM 包      | `./build.sh npm`       |

---

## 🚀 生成所有包

```bash
# 一次性生成所有打包格式
./build.sh all

# 查看生成的文件
ls -lh dist/
```

输出示例：

```
dist/
├── inav-node-server-1.0.0.zip          # ZIP 包
├── inav-node-server-1.0.0.tgz          # NPM 包
└── inav-node-server-1.0.0.tar          # Docker 镜像 tar
```

---

## 📋 验证打包文件

### Docker 镜像验证

```bash
# 加载镜像
docker load -i dist/inav-node-server-1.0.0.tar

# 运行验证
docker run -p 3000:3000 inav-node-server:1.0.0

# 测试 API
curl http://localhost:3000/health
```

### ZIP 包验证

```bash
# 解压
unzip -t dist/inav-node-server-1.0.0.zip

# 完整解压和运行
unzip dist/inav-node-server-1.0.0.zip
cd inav-node-server
npm install
npm start
```

### NPM 包验证

```bash
# 本地安装测试
npm install ./dist/inav-node-server-1.0.0.tgz

# 验证内容
tar -tzf dist/inav-node-server-1.0.0.tgz | head -20
```

---

## 🌍 部署到云平台

### Heroku

```bash
# 1. 创建 Procfile
echo "web: node server.js" > Procfile

# 2. 部署
git push heroku main
```

### AWS

```bash
# 使用 Elastic Container Service (ECS)
# 上传 Docker 镜像到 ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

docker tag inav-node-server:1.0.0 <account-id>.dkr.ecr.us-east-1.amazonaws.com/inav-node-server:1.0.0
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/inav-node-server:1.0.0
```

### Google Cloud Run

```bash
# 构建并部署到 Cloud Run
gcloud run deploy inav-server \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Docker Hub 自动化

```bash
# 1. 建立 GitHub 关联
# Settings → Connected Accounts → GitHub

# 2. 创建自动构建
# Docker Hub → Account Settings → Linked Accounts

# 3. 每次 git push 时自动构建
```

---

## 🔒 生产环境最佳实践

### 1. 使用环境变量

```bash
# 创建 .env 文件
cat > .env << EOF
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
BODY_SIZE_LIMIT=10mb
CORS_ENABLED=true
CORS_ORIGINS=*
EOF

# Docker 中使用
docker run --env-file .env -p 3000:3000 inav-server:1.0.0
```

### 2. 启用 HTTPS

```bash
# Nginx 配置（见 PACKAGING.md）
# 或使用 Let's Encrypt + Certbot

certbot certonly --standalone -d api.example.com
```

### 3. 监控和日志

```bash
# 启用日志输出到文件
npm start > logs/server.log 2>&1 &

# 使用 PM2 管理进程
pm2 start server.js
pm2 logs
pm2 monit
```

### 4. 定期备份

```bash
# 定期备份配置和数据
0 0 * * * /backup.sh
```

---

## 🛠️ 故障排除

### Docker 镜像太大？

```bash
# 清理未使用的镜像和层
docker image prune -a
docker builder prune

# 使用多阶段构建（已在 Dockerfile 中实现）
```

### 打包时权限错误？

```bash
# 确保有执行权限
chmod +x build.sh start.sh

# 或使用 sudo
sudo ./build.sh all
```

### ZIP 文件无法解压？

```bash
# 确保有写入权限
mkdir -p ~/inav-extract
unzip dist/inav-node-server-1.0.0.zip -d ~/inav-extract
```

---

## 📊 打包大小对比

| 格式       | 大小   | 优点   | 缺点                   |
| ---------- | ------ | ------ | ---------------------- |
| 源代码     | ~50MB  | 最小   | 需要 Node.js           |
| ZIP        | ~100MB | 便携   | 解压后需要 npm install |
| Docker     | ~150MB | 完整   | 依赖 Docker            |
| 可执行文件 | ~80MB  | 无依赖 | 只支持特定系统         |
| NPM 包     | ~30MB  | 作为库 | 功能有限               |

---

## ✅ 打包清单

- [ ] 更新版本号 (`package.json`)
- [ ] 更新 `CHANGELOG.md`
- [ ] 运行测试 (`npm test`)
- [ ] 生成打包文件 (`./build.sh all`)
- [ ] 验证所有包 (见上面验证部分)
- [ ] 上传到 Docker Hub/npm
- [ ] 创建 Git tag (`git tag v1.0.0`)
- [ ] 发布 Release 说明
- [ ] 更新文档

---

## 🤝 需要帮助？

查看完整文档：

```bash
# 详细打包指南
cat PACKAGING.md

# 部署指南
cat DEPLOYMENT.md

# 使用指南
cat USAGE.md
```

---

**版本**: 1.0.0  
**最后更新**: 2026-02-23
