#!/bin/bash

# INAV Node Server 打包脚本
# 用法: ./build.sh [options]
# 选项: 
#   docker    - 生成 Docker 镜像
#   zip       - 生成 ZIP 压缩包
#   pkg       - 生成独立可执行文件
#   all       - 全部打包

set -e

BUILD_DIR="./dist"
VERSION="1.0.0"
PACKAGE_NAME="inav-node-server"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}INAV Node Server 打包工具${NC}"
echo -e "${GREEN}================================${NC}"

# 创建构建目录
mkdir -p "$BUILD_DIR"

# 清理构建目录
clean() {
    echo -e "${YELLOW}清理旧构建...${NC}"
    rm -rf "$BUILD_DIR"/*
    mkdir -p "$BUILD_DIR"
}

# 生成 ZIP 包
build_zip() {
    echo -e "${YELLOW}生成 ZIP 压缩包...${NC}"
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # 复制文件
    mkdir -p "$TEMP_DIR/$PACKAGE_NAME"
    cp -r server.js routes/ js/ "$TEMP_DIR/$PACKAGE_NAME/"
    cp -r cli.js client.py "$TEMP_DIR/$PACKAGE_NAME/"
    cp package.json package-lock.json .env.example "$TEMP_DIR/$PACKAGE_NAME/"
    cp README.md START_HERE.md USAGE.md DEPLOYMENT.md QUICKSTART.md "$TEMP_DIR/$PACKAGE_NAME/"
    cp start.sh "$TEMP_DIR/$PACKAGE_NAME/" && chmod +x "$TEMP_DIR/$PACKAGE_NAME/start.sh"
    
    # 生成 ZIP
    cd "$TEMP_DIR"
    zip -r "$OLDPWD/$BUILD_DIR/$PACKAGE_NAME-$VERSION.zip" "$PACKAGE_NAME" -q
    cd "$OLDPWD"
    
    echo -e "${GREEN}✅ ZIP 包已生成: $BUILD_DIR/$PACKAGE_NAME-$VERSION.zip${NC}"
}

# 生成 Docker 镜像
build_docker() {
    echo -e "${YELLOW}生成 Docker 镜像...${NC}"
    
    # 检查 Dockerfile
    if [ ! -f "Dockerfile" ]; then
        echo -e "${RED}❌ 找不到 Dockerfile${NC}"
        echo -e "${YELLOW}请创建 Dockerfile 或使用 ./build.sh docker-setup${NC}"
        return 1
    fi
    
    docker build -t "$PACKAGE_NAME:$VERSION" .
    docker tag "$PACKAGE_NAME:$VERSION" "$PACKAGE_NAME:latest"
    
    echo -e "${GREEN}✅ Docker 镜像已生成:${NC}"
    echo "  - $PACKAGE_NAME:$VERSION"
    echo "  - $PACKAGE_NAME:latest"
    
    # 保存 Docker 镜像
    docker save -o "$BUILD_DIR/$PACKAGE_NAME-$VERSION.tar" "$PACKAGE_NAME:$VERSION"
    echo -e "${GREEN}✅ Docker 镜像文件: $BUILD_DIR/$PACKAGE_NAME-$VERSION.tar${NC}"
}

# 生成 NPM 包
build_npm() {
    echo -e "${YELLOW}生成 NPM 包...${NC}"
    
    # 创建 tarball
    npm pack --pack-destination="$BUILD_DIR" 2>&1 | grep -E "^(npm|.*\.tgz)" || true
    
    echo -e "${GREEN}✅ NPM 包已生成${NC}"
    ls -lh "$BUILD_DIR"/*.tgz 2>/dev/null || echo "NPM 包生成出错"
}

# 生成可执行文件（需要 pkg）
build_executable() {
    echo -e "${YELLOW}生成独立可执行文件...${NC}"
    
    # 检查 pkg 是否安装
    if ! command -v pkg &> /dev/null; then
        echo -e "${YELLOW}pkg 未安装，安装中...${NC}"
        npm install -g pkg
    fi
    
    # 使用 pkg 打包
    pkg server.js -o "$BUILD_DIR/$PACKAGE_NAME-$VERSION" --compress Brotli
    chmod +x "$BUILD_DIR/$PACKAGE_NAME-$VERSION"
    
    echo -e "${GREEN}✅ 可执行文件已生成: $BUILD_DIR/$PACKAGE_NAME-$VERSION${NC}"
}

# 生成 Docker 配置
setup_docker() {
    echo -e "${YELLOW}创建 Docker 配置...${NC}"
    
    cat > Dockerfile << 'EOF'
# Build stage
FROM node:18-alpine as builder

WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装依赖（生产和开发）
RUN npm ci

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
COPY .env.example .env

# 创建非 root 用户
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# 改变权限
RUN chown -R appuser:appuser /app

# 切换用户
USER appuser

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# 启动命令
CMD ["node", "server.js"]
EOF
    
    # 创建 .dockerignore
    cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.DS_Store
test.js
cli.js
client.py
examples/
dist/
*.log
EOF
    
    echo -e "${GREEN}✅ Docker 配置已创建${NC}"
}

# 生成 .github/workflows/build.yml 用于 CI/CD
setup_ci() {
    echo -e "${YELLOW}创建 CI/CD 工作流...${NC}"
    
    mkdir -p .github/workflows
    
    cat > .github/workflows/build.yml << 'EOF'
name: Build and Push Docker

on:
  push:
    branches: [main, master]
    tags: ['v*']
  pull_request:
    branches: [main, master]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        if: github.event_name != 'pull_request'
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: |
            ${{ secrets.DOCKER_REGISTRY }}/inav-node-server:latest
            ${{ secrets.DOCKER_REGISTRY }}/inav-node-server:${{ github.sha }}
          cache-from: type=registry,ref=${{ secrets.DOCKER_REGISTRY }}/inav-node-server:latest
          cache-to: type=inline
EOF
    
    echo -e "${GREEN}✅ CI/CD 工作流已创建${NC}"
}

# 显示帮助
show_help() {
    cat << EOF
用法: ./build.sh [COMMAND]

命令:
  docker      - 生成 Docker 镜像并保存为 tar 文件
  zip         - 生成 ZIP 压缩包
  npm         - 生成 NPM 包 (tgz)
  exe         - 生成独立可执行文件 (需要 pkg)
  all         - 执行全部打包 (zip + npm + docker)
  clean       - 清理构建目录
  docker-setup - 设置 Docker 配置文件
  ci-setup    - 设置 CI/CD 工作流
  help        - 显示此帮助信息

示例:
  ./build.sh docker        # 仅生成 Docker 镜像
  ./build.sh all           # 生成所有包
  ./build.sh clean all     # 清理后生成所有包

EOF
}

# 主程序
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
        clean)
            clean
            ;;
        zip)
            build_zip
            ;;
        docker)
            build_docker
            ;;
        npm)
            build_npm
            ;;
        exe|executable)
            build_executable
            ;;
        all)
            clean
            build_zip
            build_npm
            build_docker
            ;;
        docker-setup)
            setup_docker
            ;;
        ci-setup|ci)
            setup_ci
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
    shift
done

echo -e "${GREEN}✅ 打包完成！${NC}"
echo -e "${GREEN}构建文件位置: $BUILD_DIR/${NC}"
ls -lh "$BUILD_DIR" 2>/dev/null | tail -n +2
