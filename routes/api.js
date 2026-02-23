/**
 * INAV API Routes
 * 
 * Handles transpilation (JS to INAV) and decompilation (INAV to JS) requests
 */

'use strict';

import { Transpiler } from '../js/transpiler/transpiler/index.js';
import { Decompiler } from '../js/transpiler/transpiler/decompiler.js';

// Initialize transpiler (reused across requests)
const transpiler = new Transpiler();

// Decompiler is created fresh for each request to avoid state issues

/**
 * Health check endpoint
 */
export function healthCheck(req, res) {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
}

/**
 * Transpile endpoint: JavaScript to INAV commands
 * 
 * POST /api/v1/transpile
 * Body: { code: string }
 * 
 * Returns:
 * {
 *   success: boolean,
 *   commands: array,
 *   output: string,
 *   warnings: array,
 *   errors: array
 * }
 */
export function transpileHandler(req, res) {
  try {
    const { code } = req.body;

    // Validation
    if (!code || typeof code !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Invalid request: code must be a non-empty string',
        example: {
          code: 'if (inav.flight.armed) { inav.flight.disarm(); }'
        }
      });
    }

    // Transpile
    const result = transpiler.transpile(code);

    // Debug logging
    if (!result.success) {
      console.warn('Transpile warning - not successful:', {
        code: code.substring(0, 100),
        result: JSON.stringify(result).substring(0, 200)
      });
    }

    // Response
    res.json({
      success: result.success !== false,
      commands: result.commands || [],
      output: result.output || '',
      warnings: result.warnings || [],
      errors: result.errors || [],
      lineCount: result.commands ? result.commands.length : 0,
      timestamp: new Date().toISOString(),
      // Include details if transpilation failed
      ...(result.success === false && {
        details: {
          message: result.message || 'Transpilation produced no output',
          debug: result
        }
      })
    });

  } catch (error) {
    console.error('Transpile error:', error);
    res.status(400).json({
      success: false,
      error: error.message || 'Transpilation failed',
      details: error.details || error.stack || null
    });
  }
}

/**
 * Decompile endpoint: INAV commands to JavaScript
 * 
 * POST /api/v1/decompile
 * Body: { commands: array or string }
 * 
 * Returns:
 * {
 *   success: boolean,
 *   code: string,
 *   warnings: array,
 *   errors: array
 * }
 */
export function decompileHandler(req, res) {
  try {
    let { commands } = req.body;

    // Validation
    if (!commands) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request: commands must be provided',
        example: {
          commands: ['logic 0 1', 'setflight_arm']
        }
      });
    }

    // Handle both string and array formats
    if (typeof commands === 'string') {
      commands = commands
        .split('\n')
        .map(line => line.trim())
        .filter(line => line.length > 0);
    }

    if (!Array.isArray(commands) || commands.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request: commands must be a non-empty array',
        example: {
          commands: ['logic 0 1', 'setflight_arm']
        }
      });
    }

    // Parse logic commands to structured objects
    // Format: "logic INDEX ENABLED ACTIVATOR OP OPA_TYPE OPA_VAL OPB_TYPE OPB_VAL FLAGS"
    const logicConditions = [];
    for (const cmd of commands) {
      if (typeof cmd !== 'string') continue;
      
      const trimmed = cmd.trim();
      if (!trimmed.startsWith('logic ')) continue;
      
      const parts = trimmed.split(/\s+/);
      if (parts.length < 10) continue;
      
      const lc = {
        index: parseInt(parts[1]),
        enabled: parseInt(parts[2]),
        activatorId: parseInt(parts[3]),
        operation: parseInt(parts[4]),
        operandAType: parseInt(parts[5]),
        operandAValue: parseInt(parts[6]),
        operandBType: parseInt(parts[7]),
        operandBValue: parseInt(parts[8]),
        flags: parseInt(parts[9]) || 0
      };
      logicConditions.push(lc);
    }

    // Create fresh decompiler instance for each request
    // to avoid any potential state issues
    const freshDecompiler = new Decompiler();
    
    // Decompile
    // Note: If there are no logic commands, decompiler still needs the array
    // (it will return a boilerplate with warnings)
    const result = freshDecompiler.decompile(logicConditions);

    // Response
    res.json({
      success: result.success !== false,
      code: result.code || '',
      warnings: result.warnings || [],
      errors: result.errors || [],
      commandCount: commands.length,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Decompile error:', error);
    res.status(400).json({
      success: false,
      error: error.message || 'Decompilation failed',
      details: error.details || null
    });
  }
}
