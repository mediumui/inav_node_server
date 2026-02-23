#!/bin/bash

# GitHub Actions 配置检查脚本

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║         GitHub Actions 配置检查                                           ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

# 检查函数
check_workflow() {
    if [ -f ".github/workflows/$1" ]; then
        echo -e "${GREEN}✓${NC} 工作流 $1 存在"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} 工作流 $1 缺失"
        ((FAILED++))
    fi
}

check_git() {
    if command -v git &> /dev/null; then
        echo -e "${GREEN}✓${NC} Git 已安装"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Git 未安装"
        ((FAILED++))
    fi
}

check_remote() {
    if git remote get-url origin &> /dev/null; then
        REMOTE=$(git remote get-url origin)
        echo -e "${GREEN}✓${NC} Git remote: $REMOTE"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Git remote 未配置"
        ((FAILED++))
    fi
}

# 检查项
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 项目结构检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_git
check_remote

if [ -d ".git" ]; then
    echo -e "${GREEN}✓${NC} Git 仓库已初始化"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} 未检测到 .git 目录"
    ((WARNINGS++))
fi

# 检查工作流
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️ GitHub Actions 工作流检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_workflow "ci-cd.yml"
check_workflow "deploy.yml"
check_workflow "quality.yml"
check_workflow "release.yml"

# 检查文件
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 项目文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

required_files=("package.json" "Dockerfile" "docker-compose.yml" "server.js" "routes/api.js")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $file (缺失)"
        ((FAILED++))
    fi
done

# 检查文档
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 文档检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "GITHUB_ACTIONS_GUIDE.md" ]; then
    echo -e "${GREEN}✓${NC} GITHUB_ACTIONS_GUIDE.md"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} GITHUB_ACTIONS_GUIDE.md (缺失)"
    ((WARNINGS++))
fi

# 总结
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                         检查结果总结                                      ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "  ${GREEN}✓ 通过${NC}: $PASSED"
echo -e "  ${YELLOW}⚠ 警告${NC}: $WARNINGS"
echo -e "  ${RED}✗ 失败${NC}: $FAILED"
echo ""

# 建议
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 后续配置步骤"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "1️⃣  在 GitHub 仓库设置中添加 Secrets:"
echo ""
echo "   DOCKER_USERNAME     - Docker Hub 用户名"
echo "   DOCKER_PASSWORD     - Docker Hub 密码/Token"
echo "   NPM_TOKEN           - NPM 访问令牌"
echo "   HEROKU_API_KEY      - Heroku API Key (可选)"
echo "   HEROKU_EMAIL        - Heroku 邮箱 (可选)"
echo ""

echo "2️⃣  配置步骤:"
echo ""
echo "   1. 打开: https://github.com/mediumui/inav_node_server/settings/secrets/actions"
echo "   2. 点击: New repository secret"
echo "   3. 输入: Secret 名称和值"
echo "   4. 保存: Add secret"
echo ""

echo "3️⃣  获取 Secrets:"
echo ""
echo "   Docker Hub Token:"
echo "   - 访问: https://hub.docker.com/settings/security"
echo "   - 创建: New Access Token"
echo ""
echo "   NPM Token:"
echo "   - 访问: https://www.npmjs.com/settings/~/tokens"
echo "   - 创建: Generate New Token (Automation type)"
echo ""

echo "4️⃣  推送代码触发工作流:"
echo ""
echo "   git push origin main"
echo ""

echo "5️⃣  发布版本:"
echo ""
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 更多信息"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "查看详细指南: cat GITHUB_ACTIONS_GUIDE.md"
echo "或访问:"
echo "https://github.com/mediumui/inav_node_server/blob/main/GITHUB_ACTIONS_GUIDE.md"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ 配置检查完成！所有项目都已就绪。"
    echo ""
    echo "接下来:"
    echo "1. 在 GitHub 上添加 Secrets"
    echo "2. 推送代码: git push origin main"
    echo "3. 观看工作流运行: https://github.com/mediumui/inav_node_server/actions"
    echo ""
else
    echo "❌ 有一些问题需要解决。请查看上面的错误信息。"
    echo ""
fi
