#!/usr/bin/env node

/**
 * INAV CLI 工具
 * 
 * 从命令行快速测试transpiler和decompiler功能
 * 
 * 使用示例:
 *   node cli.js transpile "if (inav.flight.armed) { inav.flight.disarm(); }"
 *   node cli.js decompile "logic 0 1" "setflight_arm"
 */

'use strict';

import { Transpiler } from './js/transpiler/transpiler/index.js';
import { Decompiler } from './js/transpiler/transpiler/decompiler.js';

const transpiler = new Transpiler();
const decompiler = new Decompiler();

/**
 * 格式化输出
 */
function formatOutput(title, data) {
  console.log(`\n${'='.repeat(50)}`);
  console.log(title);
  console.log('='.repeat(50));
  console.log(JSON.stringify(data, null, 2));
}

/**
 * Transpile命令
 */
function transpileCommand(args) {
  if (args.length === 0) {
    console.error('Error: 请提供JavaScript代码');
    console.error('用法: node cli.js transpile "<JavaScript代码>"');
    process.exit(1);
  }

  const code = args.join(' ');
  console.log('输入JavaScript代码:');
  console.log(code);

  try {
    const result = transpiler.transpile(code);
    formatOutput('转译结果 (JS → INAV)', result);
  } catch (error) {
    console.error('\n错误:', error.message);
    process.exit(1);
  }
}

/**
 * Decompile命令
 */
function decompileCommand(args) {
  if (args.length === 0) {
    console.error('Error: 请提供INAV命令');
    console.error('用法: node cli.js decompile "<命令1>" "<命令2>" ...');
    process.exit(1);
  }

  const commands = args;
  console.log('输入INAV命令:');
  commands.forEach((cmd, i) => {
    console.log(`  ${i + 1}. ${cmd}`);
  });

  try {
    // Parse logic commands to structured objects
    // Format: "logic INDEX ENABLED ACTIVATOR OP OPA_TYPE OPA_VAL OPB_TYPE OPB_VAL FLAGS"
    const logicConditions = [];
    for (const cmd of commands) {
      const trimmed = cmd.trim();
      if (!trimmed.startsWith('logic ')) continue;
      
      const parts = trimmed.split(/\s+/);
      if (parts.length < 10) continue;
      
      logicConditions.push({
        index: parseInt(parts[1]),
        enabled: parseInt(parts[2]),
        activatorId: parseInt(parts[3]),
        operation: parseInt(parts[4]),
        operandAType: parseInt(parts[5]),
        operandAValue: parseInt(parts[6]),
        operandBType: parseInt(parts[7]),
        operandBValue: parseInt(parts[8]),
        flags: parseInt(parts[9]) || 0
      });
    }

    const result = decompiler.decompile(logicConditions);
    formatOutput('反编译结果 (INAV → JS)', result);
  } catch (error) {
    console.error('\n错误:', error.message);
    process.exit(1);
  }
}

/**
 * 显示帮助
 */
function showHelp() {
  console.log(`
INAV CLI 工具 - 本地JavaScript Transpiler

使用:
  node cli.js <命令> [参数...]

命令:
  transpile <代码>              将JavaScript转换为INAV命令
  decompile <命令1> <命令2> ...  将INAV命令转换为JavaScript
  help                         显示此帮助信息

示例:
  # Transpile
  node cli.js transpile "if (inav.flight.armed) { inav.flight.disarm(); }"
  
  # Decompile
  node cli.js decompile "logic 0 1" "setflight_arm"
  
  # 帮助
  node cli.js help
  node cli.js -h
  node cli.js --help
`);
}

/**
 * 主程序
 */
function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    showHelp();
    process.exit(0);
  }

  const command = args[0].toLowerCase();
  const commandArgs = args.slice(1);

  switch (command) {
    case 'transpile':
      transpileCommand(commandArgs);
      break;
    case 'decompile':
      decompileCommand(commandArgs);
      break;
    case 'help':
    case '-h':
    case '--help':
      showHelp();
      break;
    default:
      console.error(`未知命令: ${command}`);
      console.error('运行 "node cli.js help" 查看帮助');
      process.exit(1);
  }
}

main();
