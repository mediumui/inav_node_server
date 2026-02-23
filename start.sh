#!/bin/bash

# INAV Node.js API 服务器启动脚本
# 
# 这个脚本用于启动和管理INAV Node.js API服务器
# 
# 使用方法:
#   ./start.sh                    # 启动服务器
#   ./start.sh 8080              # 在端口8080启动
#   ./start.sh stop              # 停止服务器
#   ./start.sh restart           # 重启服务器
#   ./start.sh dev               # 开发模式（启用hot-reload）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
LOG_FILE="$SCRIPT_DIR/server.log"
PID_FILE="$SCRIPT_DIR/.server.pid"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 检查是否已安装依赖
check_dependencies() {
    if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
        print_warning "依赖未安装"
        print_info "正在安装依赖..."
        cd "$SCRIPT_DIR"
        npm install
        print_success "依赖安装完成"
    fi
}

# 启动服务器
start_server() {
    local port=${1:-3000}
    
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            print_error "服务器已在运行 (PID: $pid)"
            print_info "运行 './start.sh stop' 来停止服务器"
            return 1
        fi
    fi
    
    print_info "启动服务器..."
    check_dependencies
    
    cd "$SCRIPT_DIR"
    PORT=$port npm start > "$LOG_FILE" 2>&1 &
    
    local server_pid=$!
    echo $server_pid > "$PID_FILE"
    
    # 等待服务器启动
    sleep 2
    
    if kill -0 $server_pid 2>/dev/null; then
        print_success "服务器已启动 (PID: $server_pid)"
        print_info "监听端口: $port"
        print_info "API文档: http://localhost:$port/api/docs"
        print_info "查看日志: tail -f $LOG_FILE"
        return 0
    else
        print_error "服务器启动失败"
        cat "$LOG_FILE"
        return 1
    fi
}

# 停止服务器
stop_server() {
    if [ ! -f "$PID_FILE" ]; then
        print_error "服务器未运行"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if kill -0 "$pid" 2>/dev/null; then
        print_info "停止服务器 (PID: $pid)..."
        kill $pid
        sleep 1
        
        if kill -0 "$pid" 2>/dev/null; then
            print_warning "强制杀死进程"
            kill -9 $pid
        fi
        
        rm "$PID_FILE"
        print_success "服务器已停止"
    else
        print_error "进程不存在 (PID: $pid)"
        rm "$PID_FILE"
    fi
}

# 重启服务器
restart_server() {
    print_info "重启服务器..."
    stop_server || true
    sleep 1
    start_server
}

# 开发模式
dev_mode() {
    print_info "启动开发模式..."
    check_dependencies
    
    cd "$SCRIPT_DIR"
    PORT=${1:-3000} npm run dev
}

# 显示帮助
show_help() {
    echo "
INAV Node.js API 服务器启动脚本

使用方法:
  $0 [命令] [选项]

命令:
  start [端口]     启动服务器 (默认端口: 3000)
  stop             停止服务器
  restart          重启服务器
  dev [端口]       启动开发模式 (默认端口: 3000)
  status           显示服务器状态
  logs             显示服务器日志
  help             显示此帮助信息

示例:
  # 启动默认服务器
  $0 start
  
  # 在端口8080启动
  $0 start 8080
  
  # 停止服务器
  $0 stop
  
  # 开发模式
  $0 dev
  
  # 查看日志
  $0 logs
"
}

# 显示状态
show_status() {
    if [ ! -f "$PID_FILE" ]; then
        print_info "服务器状态: 未运行"
        return 0
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if kill -0 "$pid" 2>/dev/null; then
        print_success "服务器状态: 运行中 (PID: $pid)"
        
        # 尝试获取端口信息
        local port=$(lsof -i -P -n | grep "node.*LISTEN" | awk '{print $9}' | cut -d':' -f2 | head -1)
        if [ ! -z "$port" ]; then
            print_info "监听端口: $port"
            print_info "API文档: http://localhost:$port/api/docs"
        fi
    else
        print_error "服务器状态: 进程不存在 (PID: $pid)"
        rm "$PID_FILE"
    fi
}

# 显示日志
show_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        print_error "日志文件不存在"
        return 1
    fi
    
    tail -f "$LOG_FILE"
}

# 主程序
main() {
    case "${1:-start}" in
        start)
            start_server "${2:-3000}"
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        dev)
            dev_mode "${2:-3000}"
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
