# GitHub Actions CI/CD 配置指南

## 🎯 概述

本项目已配置完整的 GitHub Actions CI/CD 流程，包括：

- ✅ 自动化构建和测试
- ✅ Docker 镜像构建和推送
- ✅ NPM 包发布
- ✅ 代码质量检查
- ✅ 安全漏洞扫描
- ✅ 自动部署
- ✅ GitHub Pages 文档发布

---

## 📋 工作流说明

### 1. **CI/CD Pipeline** (`ci-cd.yml`)

**触发条件:**

- `push` 到 `main` 或 `develop` 分支
- `pull_request` 到 `main` 分支

**执行步骤:**

1. **build-and-test**
   - 在 Node.js 18.x 和 20.x 上运行
   - 安装依赖
   - 运行 linter 和测试
   - 验证 Docker Compose 配置

2. **build-docker**
   - 构建 Docker 镜像
   - 推送到 Docker Hub（需要认证）

3. **package**
   - 生成 ZIP 包
   - 生成 NPM 包
   - 上传制品
   - 发布到 NPM registry（需要 NPM Token）

4. **deploy**
   - 检查部署配置

### 2. **Deploy to Production** (`deploy.yml`)

**触发条件:**

- `push` 到 `main` 分支（仅当以下文件改变时）
- 手动触发 `workflow_dispatch`

**执行步骤:**

1. **deploy-docker-compose**
   - 验证 Docker Compose 配置
   - 构建镜像
   - 测试容器运行

2. **deploy-heroku**
   - 部署到 Heroku（可选）

3. **deploy-railway**
   - 部署到 Railway（可选）

### 3. **Code Quality & Security** (`quality.yml`)

**触发条件:**

- `push` 到 `main` 或 `develop`
- `pull_request` 到 `main`
- 每周日定时运行

**检查项:**

- 代码格式 (Prettier)
- ESLint
- npm 审计
- 依赖漏洞扫描 (Snyk)
- 密钥泄露检查 (Trufflehog)
- 过期依赖检查
- Docker 镜像扫描
- 性能基准测试
- 文档完整性

### 4. **Release & Publish** (`release.yml`)

**触发条件:**

- 创建版本标签 `v*.*.*`

**执行步骤:**

- 创建 GitHub Release
- 上传构建产物 (ZIP、NPM 包)
- 发布到 NPM
- 推送 Docker 镜像到 Docker Hub
- 部署文档到 GitHub Pages

---

## 🔐 需要配置的 Secrets

### 必须配置（用于完整功能）

#### 1. **Docker Hub**

在 GitHub 设置中添加:

```
DOCKER_USERNAME: 你的 Docker Hub 用户名
DOCKER_PASSWORD: 你的 Docker Hub 访问令牌
```

**获取方法:**

```bash
# 生成 Docker Hub 访问令牌
# 1. 访问 https://hub.docker.com/settings/security
# 2. 点击 "New Access Token"
# 3. 复制令牌
```

#### 2. **NPM Token**

```
NPM_TOKEN: 你的 NPM 访问令牌
```

**获取方法:**

```bash
# 生成 NPM Token
# 1. 访问 https://www.npmjs.com/settings/~/tokens
# 2. 点击 "Generate New Token"
# 3. 选择 "Automation" 类型
# 4. 复制令牌
```

#### 3. **Heroku** (可选)

```
HEROKU_API_KEY: 你的 Heroku API Key
HEROKU_EMAIL: 你的 Heroku 邮箱
```

#### 4. **Snyk** (可选，代码安全扫描)

```
SNYK_TOKEN: 你的 Snyk API Token
```

### 配置步骤

1. 打开 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 输入 Secret 名称和值
5. 点击 **Add secret**

---

## 🚀 使用示例

### 示例 1: 自动化测试和构建

推送代码到 `main` 分支时自动运行:

```bash
git push origin main
```

GitHub Actions 会自动:

- 运行测试
- 构建 Docker 镜像
- 生成 ZIP 和 NPM 包

### 示例 2: 发布新版本

创建版本标签来触发发布流程:

```bash
# 创建版本标签
git tag -a v1.0.1 -m "Release version 1.0.1"

# 推送标签到 GitHub
git push origin v1.0.1
```

GitHub Actions 会自动:

- 创建 Release
- 上传构建产物
- 发布到 NPM
- 推送 Docker 镜像

### 示例 3: 手动触发部署

在 GitHub 页面:

1. 点击 **Actions**
2. 选择 **Deploy to Production**
3. 点击 **Run workflow**
4. 选择环境并运行

---

## 📊 工作流状态检查

### 查看工作流运行状态

1. 打开 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看最近的工作流运行

### 查看工作流日志

点击具体的工作流运行 → 查看各个任务的详细日志

### 常见问题排查

**Docker 构建失败:**

```bash
# 本地测试 Dockerfile
docker build -t inav-node-server:test .
```

**npm 发布失败:**

```bash
# 检查 NPM Token 有效性
npm whoami

# 检查包名是否已存在
npm view inav-node-server
```

**测试失败:**

```bash
# 本地运行测试
npm test
```

---

## 📈 工作流文件说明

### `.github/workflows/ci-cd.yml`

主要的 CI/CD 流程，包括:

- Node.js 版本矩阵测试
- 依赖安装
- 代码检查
- Docker 构建
- 包生成

### `.github/workflows/deploy.yml`

部署工作流，包括:

- Docker Compose 验证
- Heroku 部署
- Railway 部署
- 部署通知

### `.github/workflows/quality.yml`

代码质量检查，包括:

- 代码格式检查
- 安全漏洞扫描
- 依赖审计
- 性能测试

### `.github/workflows/release.yml`

发布工作流，包括:

- GitHub Release 创建
- 构建产物上传
- NPM 发布
- Docker 镜像推送
- GitHub Pages 更新

---

## 🎯 最佳实践

### 1. 分支管理

```
main (生产分支)
  ↓
develop (开发分支)
  ↓
feature/* (功能分支)
```

每个分支都会触发不同的 CI 流程。

### 2. 提交消息规范

```
feat: 新增功能
fix: 修复 bug
docs: 文档更新
test: 测试更新
chore: 其他更改
```

### 3. 版本标签规范

```
v1.0.0  - 主版本更新
v1.0.1  - 补丁版本更新
v1.1.0  - 次版本更新
```

### 4. Pull Request 检查清单

- [ ] 代码通过所有测试
- [ ] 通过代码质量检查
- [ ] 文档已更新
- [ ] 没有安全漏洞
- [ ] Commit 消息清晰

---

## 🔄 工作流依赖关系

```
┌─────────────────┐
│  code push      │
└────────┬────────┘
         │
    ┌────▼────────────────┐
    │ CI/CD Pipeline      │
    │ (build & test)      │
    └────┬────────┬───────┘
         │        │
    ┌────▼──┐  ┌──▼──────────┐
    │Docker │  │Package      │
    │Build  │  │(ZIP, NPM)   │
    └────┬──┘  └──┬──────────┘
         │        │
    ┌────▼────────▼────────┐
    │  Code Quality Check   │
    │  (lint, security)     │
    └────┬─────────────────┘
         │
    ┌────▼──────────────────┐
    │  Deploy (Optional)     │
    │  (Docker, Heroku, etc) │
    └───────────────────────┘
```

---

## 📝 环境变量

GitHub Actions 可以访问以下环境变量:

```yaml
GITHUB_TOKEN          # 自动提供，用于 GitHub 操作
GITHUB_REF            # 当前 ref (branch/tag)
GITHUB_SHA            # Commit SHA
GITHUB_RUN_NUMBER     # 运行号
RUNNER_OS             # 运行系统 (Linux, Windows, macOS)
```

---

## 🎓 学习资源

- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [工作流语法参考](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [上下文参考](https://docs.github.com/en/actions/learn-github-actions/contexts)

---

## 💡 定制建议

1. **添加 Slack 通知**

   ```yaml
   - name: Slack notification
     uses: slackapi/slack-github-action@v1
   ```

2. **添加性能监控**

   ```yaml
   - name: Upload to Datadog
     uses: datadog/datadog-action@v1
   ```

3. **添加依赖更新**

   ```yaml
   - name: Dependabot alerts
     uses: dependabot/fetch-metadata@v1
   ```

4. **添加代码覆盖率**
   ```yaml
   - name: Upload coverage
     uses: codecov/codecov-action@v3
   ```

---

## ✅ 检查清单

- [ ] 配置了 Docker Hub Secrets
- [ ] 配置了 NPM Token
- [ ] 配置了 Heroku 信息（如需）
- [ ] 配置了 Snyk Token（如需）
- [ ] 测试了 CI 流程
- [ ] 创建了版本标签进行发布测试
- [ ] 验证了 Docker 镜像推送
- [ ] 验证了 NPM 包发布

---

## 🚀 快速开始

1. **配置 Secrets**

   ```
   Settings → Secrets and variables → Actions
   添加: DOCKER_USERNAME, DOCKER_PASSWORD, NPM_TOKEN
   ```

2. **推送代码**

   ```bash
   git push origin main
   ```

3. **查看工作流**

   ```
   Actions 标签 → 选择工作流
   ```

4. **发布版本**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

---

**项目**: INAV Node Server
**版本**: 1.0.0
**最后更新**: 2026-02-23
