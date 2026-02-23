/**
 * INAV API 测试套件
 * 
 * 运行所有测试用例以验证API功能
 * 
 * 使用: node test.js
 */

'use strict';

import http from 'http';
import assert from 'assert';

const API_URL = 'http://localhost:3000';
let testsPassed = 0;
let testsFailed = 0;

/**
 * 发送HTTP请求
 */
function makeRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const url = new URL(API_URL);
    const options = {
      hostname: url.hostname,
      port: url.port || 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            body: JSON.parse(body),
            headers: res.headers
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            body: body,
            headers: res.headers
          });
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

/**
 * 执行测试
 */
async function runTest(testName, testFn) {
  try {
    console.log(`\n▶ ${testName}`);
    await testFn();
    console.log(`✓ ${testName} 通过`);
    testsPassed++;
  } catch (error) {
    console.log(`✗ ${testName} 失败`);
    console.error(`  错误: ${error.message}`);
    testsFailed++;
  }
}

/**
 * 测试套件
 */
async function runTests() {
  console.log('\n========================================');
  console.log('INAV API 测试套件');
  console.log('========================================\n');

  // 测试1: 健康检查
  await runTest('健康检查 (GET /health)', async () => {
    const res = await makeRequest('GET', '/health');
    assert.strictEqual(res.status, 200, '应该返回200状态码');
    assert.strictEqual(res.body.success, true, '应该返回success: true');
    assert.strictEqual(res.body.status, 'healthy', '状态应该是healthy');
  });

  // 测试2: API文档
  await runTest('API文档 (GET /api/docs)', async () => {
    const res = await makeRequest('GET', '/api/docs');
    assert.strictEqual(res.status, 200, '应该返回200状态码');
    assert.ok(res.body.name, '应该有API名称');
    assert.ok(res.body.endpoints, '应该有endpoints');
    assert(Array.isArray(res.body.endpoints), 'endpoints应该是数组');
  });

  // 测试3: Transpile - 成功情况
  await runTest('Transpile - 有效的JS代码', async () => {
    const res = await makeRequest('POST', '/api/v1/transpile', {
      code: 'if (inav.flight.armed) { inav.flight.disarm(); }'
    });
    assert.strictEqual(res.status, 200, '应该返回200状态码');
    assert.ok(res.body.success !== false, '应该成功');
    assert(Array.isArray(res.body.commands), 'commands应该是数组');
  });

  // 测试4: Transpile - 错误情况（空代码）
  await runTest('Transpile - 空代码处理', async () => {
    const res = await makeRequest('POST', '/api/v1/transpile', {
      code: ''
    });
    assert.strictEqual(res.status, 400, '应该返回400状态码');
    assert.strictEqual(res.body.success, false, '应该失败');
  });

  // 测试5: Transpile - 错误情况（无code字段）
  await runTest('Transpile - 缺少code字段', async () => {
    const res = await makeRequest('POST', '/api/v1/transpile', {});
    assert.strictEqual(res.status, 400, '应该返回400状态码');
    assert.strictEqual(res.body.success, false, '应该失败');
  });

  // 测试6: Decompile - 数组格式
  await runTest('Decompile - 命令数组格式', async () => {
    const res = await makeRequest('POST', '/api/v1/decompile', {
      commands: ['logic 0 1']
    });
    assert.strictEqual(res.status, 200, '应该返回200状态码');
    assert.ok(res.body.success !== false, '应该成功');
    assert.strictEqual(typeof res.body.code, 'string', 'code应该是字符串');
  });

  // 测试7: Decompile - 字符串格式
  await runTest('Decompile - 命令字符串格式', async () => {
    const res = await makeRequest('POST', '/api/v1/decompile', {
      commands: 'logic 0 1\nlogic 1 2'
    });
    assert.strictEqual(res.status, 200, '应该返回200状态码');
    assert.ok(res.body.success !== false, '应该成功');
    assert.strictEqual(typeof res.body.code, 'string', 'code应该是字符串');
  });

  // 测试8: Decompile - 错误情况（无命令）
  await runTest('Decompile - 缺少命令', async () => {
    const res = await makeRequest('POST', '/api/v1/decompile', {});
    assert.strictEqual(res.status, 400, '应该返回400状态码');
    assert.strictEqual(res.body.success, false, '应该失败');
  });

  // 测试9: Decompile - 空数组
  await runTest('Decompile - 空命令数组', async () => {
    const res = await makeRequest('POST', '/api/v1/decompile', {
      commands: []
    });
    assert.strictEqual(res.status, 400, '应该返回400状态码');
    assert.strictEqual(res.body.success, false, '应该失败');
  });

  // 测试10: 404处理
  await runTest('404错误处理 (GET /invalid-path)', async () => {
    const res = await makeRequest('GET', '/invalid-path');
    assert.strictEqual(res.status, 404, '应该返回404状态码');
    assert.strictEqual(res.body.success, false, '应该包含success: false');
    assert.ok(res.body.availableEndpoints, '应该列出可用端点');
  });

  // 打印测试总结
  console.log('\n========================================');
  console.log('测试总结');
  console.log('========================================');
  console.log(`✓ 通过: ${testsPassed}`);
  console.log(`✗ 失败: ${testsFailed}`);
  console.log(`总计: ${testsPassed + testsFailed}`);
  console.log('========================================\n');

  if (testsFailed === 0) {
    console.log('🎉 所有测试通过!\n');
    process.exit(0);
  } else {
    console.log('❌ 一些测试失败\n');
    process.exit(1);
  }
}

// 检查服务器是否运行
async function checkServer() {
  try {
    const res = await makeRequest('GET', '/health');
    if (res.status === 200) {
      console.log('✓ 服务器正在运行\n');
      return true;
    }
  } catch (error) {
    console.error('✗ 无法连接到服务器');
    console.error(`  请先启动服务器: npm start`);
    console.error(`  或在另一个终端运行: npm start\n`);
    process.exit(1);
  }
}

// 运行测试
(async () => {
  await checkServer();
  await runTests();
})().catch(error => {
  console.error('测试执行出错:', error);
  process.exit(1);
});
