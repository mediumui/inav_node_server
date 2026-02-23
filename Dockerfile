# Build stage
FROM node:18-alpine as builder

WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装依赖（仅生产依赖）
RUN npm ci --only=production

# Runtime stage
FROM node:18-alpine

WORKDIR /app

# 安装 curl 用于健康检查
RUN apk add --no-cache curl

# 复制依赖
COPY --from=builder /app/node_modules ./node_modules

# 复制应用文件
COPY package*.json ./
COPY server.js .
COPY routes ./routes
COPY js ./js

# 创建非 root 用户以提高安全性
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# 改变权限
RUN chown -R appuser:appuser /app

# 切换用户
USER appuser

# 暴露端口
EXPOSE 3000

# 环境变量
ENV NODE_ENV=production
ENV PORT=3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# 启动命令
CMD ["node", "server.js"]
