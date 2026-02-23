/**
 * INAV Node.js API Server
 * 
 * Provides REST API endpoints for:
 * 1. JavaScript to INAV Command transpilation
 * 2. INAV Command to JavaScript decompilation
 */

'use strict';

import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { transpileHandler, decompileHandler, healthCheck } from './routes/api.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', healthCheck);

// API v1 Routes
app.post('/api/v1/transpile', transpileHandler);
app.post('/api/v1/decompile', decompileHandler);

// API documentation
app.get('/api/docs', (req, res) => {
  res.json({
    name: 'INAV Transpiler API',
    version: '1.0.0',
    endpoints: [
      {
        method: 'POST',
        path: '/api/v1/transpile',
        description: 'Convert JavaScript code to INAV commands',
        requestBody: {
          code: 'string (JavaScript source code)'
        },
        responseBody: {
          success: 'boolean',
          commands: 'array of INAV CLI commands',
          output: 'string (formatted output)',
          warnings: 'array of warnings',
          errors: 'array of errors'
        },
        example: {
          code: "if (inav.flight.armed) { inav.flight.disarm(); }"
        }
      },
      {
        method: 'POST',
        path: '/api/v1/decompile',
        description: 'Convert INAV commands to JavaScript code',
        requestBody: {
          commands: 'array of INAV CLI commands or string (newline-separated)'
        },
        responseBody: {
          success: 'boolean',
          code: 'string (JavaScript source code)',
          warnings: 'array of warnings',
          errors: 'array of errors'
        },
        example: {
          commands: ['logic 0 1', 'setflight_arm']
        }
      }
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    error: err.message || 'Internal server error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    availableEndpoints: [
      'GET /health',
      'GET /api/docs',
      'POST /api/v1/transpile',
      'POST /api/v1/decompile'
    ]
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n========================================`);
  console.log(`INAV Node.js API Server`);
  console.log(`========================================`);
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`\nAPI Documentation: http://localhost:${PORT}/api/docs`);
  console.log(`Health Check: http://localhost:${PORT}/health`);
  console.log(`\nEndpoints:`);
  console.log(`  POST http://localhost:${PORT}/api/v1/transpile   - JS to INAV`);
  console.log(`  POST http://localhost:${PORT}/api/v1/decompile   - INAV to JS`);
  console.log(`========================================\n`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nServer shutting down...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\nServer shutting down...');
  process.exit(0);
});
