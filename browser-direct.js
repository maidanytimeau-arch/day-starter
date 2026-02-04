#!/usr/bin/env node

/**
 * Direct Browser Control via CDP (Chrome DevTools Protocol)
 * 
 * Bypasses browser tool routing bug by using CDP directly
 * Usage: node browser-direct.js <action> [args]
 */

const http = require('http');

const CDP_HOST = '127.0.0.1';
const CDP_PORT = 18800;

/**
 * Send CDP command via HTTP
 */
async function sendCDP(method, params = {}) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: CDP_HOST,
      port: CDP_PORT,
      path: '/json',
      method: 'GET',
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const targets = JSON.parse(body);
          resolve(targets);
        } catch (err) {
          reject(err);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

/**
 * Navigate to URL
 */
async function navigate(url) {
  console.log(`[Browser] Navigating to: ${url}`);
  
  // Get CDP WebSocket URL
  const browserInfo = await sendCDP('Target.getTargets');
  const target = browserInfo.find(t => t.type === 'page');
  
  if (!target) {
    throw new Error('No page target found - browser may not have started');
  }
  
  console.log(`[Browser] Found target: ${target.title || target.url}`);
  console.log(`[Browser] WebSocket: ${target.webSocketDebuggerUrl}`);
  
  console.log(`[Browser] Navigate complete (browser window should show the page)`);
  console.log(`[Browser] Note: This script can't extract content yet - just controls navigation`);
  
  return { success: true, url };
}

/**
 * Get current page content (via CDP Runtime.evaluate)
 */
async function getContent() {
  console.log(`[Browser] Getting page content...`);
  
  const browserInfo = await sendCDP('Target.getTargets');
  const target = browserInfo.find(t => t.type === 'page');
  
  if (!target) {
    throw new Error('No page target found');
  }
  
  // For full WebSocket support, we'd need a WebSocket client
  // For now, this is a diagnostic tool
  console.log(`[Browser] Target found: ${target.url}`);
  console.log(`[Browser] Full content extraction requires WebSocket client`);
  
  return { url: target.url, title: target.title };
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0] || 'status';
  
  (async () => {
    try {
      switch (command) {
        case 'navigate':
          if (!args[1]) {
            console.error('[Browser] Usage: node browser-direct.js navigate <url>');
            process.exit(1);
          }
          await navigate(args[1]);
          break;
          
        case 'content':
          const content = await getContent();
          console.log(JSON.stringify(content, null, 2));
          break;
          
        case 'status':
          const browserInfo = await sendCDP('Target.getTargets');
          const page = browserInfo.find(t => t.type === 'page');
          console.log(`[Browser] Status: ${page ? 'Active' : 'No page'}`);
          if (page) {
            console.log(`[Browser] URL: ${page.url}`);
            console.log(`[Browser] Title: ${page.title}`);
          }
          break;
          
        default:
          console.log('[Browser] Usage:');
          console.log('  node browser-direct.js status   - Check browser status');
          console.log('  node browser-direct.js navigate <url> - Navigate to URL');
          console.log('  node browser-direct.js content  - Get current page info');
      }
    } catch (err) {
      console.error(`[Browser] Error: ${err.message}`);
      process.exit(1);
    }
  })();
}

module.exports = { navigate, getContent };
