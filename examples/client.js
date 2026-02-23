/**
 * INAV API Client Examples
 * 
 * Demonstrates how to use the INAV Transpiler API
 * 
 * Usage:
 *   node examples/client.js
 */

'use strict';

import http from 'http';

const API_URL = 'http://localhost:3000';

/**
 * Make HTTP request helper
 */
function makeRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const url = new URL(API_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
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
          resolve(JSON.parse(body));
        } catch (e) {
          resolve(body);
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
 * Test transpile (JS to INAV)
 */
async function testTranspile() {
  console.log('\n========== TRANSPILE TEST (JS to INAV) ==========\n');

  const jsCode = `
if (inav.flight.armed) {
  inav.flight.disarm();
}
`;

  console.log('Input JavaScript:');
  console.log(jsCode);

  try {
    const response = await makeRequest('POST', '/api/v1/transpile', {
      code: jsCode
    });

    console.log('Response:');
    console.log(JSON.stringify(response, null, 2));

    if (response.success) {
      console.log('\nGenerated INAV Commands:');
      if (response.commands && Array.isArray(response.commands)) {
        response.commands.forEach((cmd, i) => {
          console.log(`  ${i + 1}. ${cmd}`);
        });
      }
    }
  } catch (error) {
    console.error('Error:', error.message);
  }
}

/**
 * Test decompile (INAV to JS)
 */
async function testDecompile() {
  console.log('\n========== DECOMPILE TEST (INAV to JS) ==========\n');

  const commands = [
    'logic 0 1',
    'setflight_arm'
  ];

  console.log('Input INAV Commands:');
  commands.forEach((cmd, i) => {
    console.log(`  ${i + 1}. ${cmd}`);
  });

  try {
    const response = await makeRequest('POST', '/api/v1/decompile', {
      commands: commands
    });

    console.log('\nResponse:');
    console.log(JSON.stringify(response, null, 2));

    if (response.success) {
      console.log('\nGenerated JavaScript:');
      console.log(response.code);
    }
  } catch (error) {
    console.error('Error:', error.message);
  }
}

/**
 * Test API documentation
 */
async function testDocs() {
  console.log('\n========== API DOCUMENTATION ==========\n');

  try {
    const response = await makeRequest('GET', '/api/docs', null);
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.error('Error:', error.message);
  }
}

/**
 * Test health check
 */
async function testHealth() {
  console.log('\n========== HEALTH CHECK ==========\n');

  try {
    const response = await makeRequest('GET', '/health', null);
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.error('Error:', error.message);
  }
}

/**
 * Run all tests
 */
async function runAllTests() {
  try {
    await testHealth();
    await testDocs();
    await testTranspile();
    await testDecompile();
    
    console.log('\n========================================');
    console.log('All tests completed!');
    console.log('========================================\n');
  } catch (error) {
    console.error('Test failed:', error);
  }
}

// Run tests
runAllTests();
