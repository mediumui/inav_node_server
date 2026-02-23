#!/bin/bash

# ============================================================================
# 快速验证脚本 - 检查所有项目文件是否已正确配置
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         INAV Node Server 快速验证                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
PASSED=0
FAILED=0
WARNINGS=0

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $1 (未找到)"
        ((FAILED++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $1/ (目录不存在)"
        ((FAILED++))
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 (可执行)"
        ((PASSED++))
    elif [ -f "$1" ]; then
        echo -e "${YELLOW}⚠${NC} $1 (存在但不可执行)"
        ((WARNINGS++))
    else
        echo -e "${RED}✗${NC} $1 (未找到)"
        ((FAILED++))
    fi
}

# 检查核心文件
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 项目结构检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_dir "js"
check_dir "js/transpiler"
check_dir "routes"
check_dir "dist"

# 检查源代码文件
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 源代码文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_file "server.js"
check_file "package.json"
check_file "cli.js"
check_file "routes/api.js"
check_file "js/transpiler/index.js"

# 检查配置文件
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️ 配置文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_file "Dockerfile"
check_file "docker-compose.yml"
check_file ".dockerignore"
check_executable "build.sh"

# 检查文档
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 文档文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_file "START_HERE.md"
check_file "BUILDS_READY.md"
check_file "BUILD_QUICK_START.md"
check_file "PACKAGING.md"
check_file "PACKAGING_SUMMARY.md"
check_file "DEPLOYMENT_COMPLETE.md"
check_file "DOCS_INDEX.md"
check_file "README.md"
check_file "USAGE.md"

# 检查打包产物
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 打包产物检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "dist/inav-node-server-1.0.0.zip" ]; then
    SIZE=$(du -h "dist/inav-node-server-1.0.0.zip" | cut -f1)
    echo -e "${GREEN}✓${NC} dist/inav-node-server-1.0.0.zip ($SIZE)"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} dist/inav-node-server-1.0.0.zip (未生成)"
    ((WARNINGS++))
fi

if [ -f "dist/inav-node-server-1.0.0.tgz" ]; then
    SIZE=$(du -h "dist/inav-node-server-1.0.0.tgz" | cut -f1)
    echo -e "${GREEN}✓${NC} dist/inav-node-server-1.0.0.tgz ($SIZE)"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} dist/inav-node-server-1.0.0.tgz (未生成)"
    ((WARNINGS++))
fi

# 检查依赖
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 npm 依赖检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC} node_modules 已安装"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} node_modules 未安装 (运行 npm install)"
    ((WARNINGS++))
fi

# 总结
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      验证结果总结                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "  ${GREEN}✓ 通过${NC}: $PASSED"
echo -e "  ${YELLOW}⚠ 警告${NC}: $WARNINGS"
echo -e "  ${RED}✗ 失败${NC}: $FAILED"
echo ""

# 给出建议
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 建议的后续步骤"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -d "node_modules" ]; then
    echo "1. 安装依赖:"
    echo "   npm install"
    echo ""
fi

echo "2. 选择启动方式:"
echo ""
echo "   方式 A (Docker Compose - 推荐):"
echo "   docker-compose up -d"
echo ""
echo "   方式 B (npm):"
echo "   npm start"
echo ""

echo "3. 验证服务:"
echo "   curl http://localhost:3000/health"
echo ""

echo "4. 查看文档:"
echo "   - START_HERE.md (快速开始)"
echo "   - DOCS_INDEX.md (文档导航)"
echo ""

if [ $FAILED -eq 0 ] && [ $WARNINGS -le 1 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 所有检查通过！系统已就绪！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🚀 立即启动: docker-compose up -d"
    echo ""
fi
