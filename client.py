#!/usr/bin/env python3

"""
INAV API Python 客户端

用法:
  python3 client.py transpile "<JavaScript代码>"
  python3 client.py decompile "<命令1>" "<命令2>" ...
"""

import requests
import json
import sys
import argparse
from typing import List, Dict, Any

# API配置
API_BASE_URL = "http://localhost:3000"
TRANSPILE_ENDPOINT = "/api/v1/transpile"
DECOMPILE_ENDPOINT = "/api/v1/decompile"

class INAVClient:
    """INAV API客户端"""
    
    def __init__(self, base_url: str = API_BASE_URL):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({"Content-Type": "application/json"})
    
    def transpile(self, code: str) -> Dict[str, Any]:
        """JavaScript转INAV命令"""
        url = f"{self.base_url}{TRANSPILE_ENDPOINT}"
        response = self.session.post(url, json={"code": code})
        return response.json()
    
    def decompile(self, commands: List[str]) -> Dict[str, Any]:
        """INAV命令转JavaScript"""
        url = f"{self.base_url}{DECOMPILE_ENDPOINT}"
        response = self.session.post(url, json={"commands": commands})
        return response.json()
    
    def health_check(self) -> bool:
        """检查服务器健康状态"""
        try:
            response = self.session.get(f"{self.base_url}/health")
            return response.status_code == 200
        except:
            return False

def print_result(result: Dict[str, Any], title: str = ""):
    """格式化打印结果"""
    if title:
        print(f"\n{'='*50}")
        print(title)
        print('='*50)
    
    print(json.dumps(result, indent=2, ensure_ascii=False))

def transpile_command(args):
    """处理transpile命令"""
    client = INAVClient()
    
    if not client.health_check():
        print("错误: 无法连接到API服务器")
        print("请先启动服务器: npm start")
        sys.exit(1)
    
    code = " ".join(args.code)
    print("输入JavaScript代码:")
    print(code)
    
    try:
        result = client.transpile(code)
        print_result(result, "转译结果 (JS → INAV)")
        
        if result.get("success") and result.get("commands"):
            print("\n生成的INAV命令:")
            for i, cmd in enumerate(result["commands"], 1):
                print(f"  {i}. {cmd}")
    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)

def decompile_command(args):
    """处理decompile命令"""
    client = INAVClient()
    
    if not client.health_check():
        print("错误: 无法连接到API服务器")
        print("请先启动服务器: npm start")
        sys.exit(1)
    
    commands = args.commands
    print("输入INAV命令:")
    for i, cmd in enumerate(commands, 1):
        print(f"  {i}. {cmd}")
    
    try:
        result = client.decompile(commands)
        print_result(result, "反编译结果 (INAV → JS)")
        
        if result.get("success") and result.get("code"):
            print("\n生成的JavaScript:")
            print(result["code"])
    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)

def main():
    """主程序"""
    parser = argparse.ArgumentParser(
        description="INAV API Python客户端",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # Transpile
  python3 client.py transpile "if (inav.flight.armed) { inav.flight.disarm(); }"
  
  # Decompile
  python3 client.py decompile "logic 0 1" "setflight_arm"
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="命令")
    
    # Transpile命令
    transpile_parser = subparsers.add_parser("transpile", help="JavaScript转INAV命令")
    transpile_parser.add_argument("code", nargs="+", help="JavaScript代码")
    transpile_parser.set_defaults(func=transpile_command)
    
    # Decompile命令
    decompile_parser = subparsers.add_parser("decompile", help="INAV命令转JavaScript")
    decompile_parser.add_argument("commands", nargs="+", help="INAV命令")
    decompile_parser.set_defaults(func=decompile_command)
    
    args = parser.parse_args()
    
    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
