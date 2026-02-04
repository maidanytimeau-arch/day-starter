#!/usr/bin/env node

/**
 * Direct Chrome Control (CDP WebSocket) - FIXED VERSION
 * 
 * Bypasses browser tool routing bug by controlling Chrome directly via CDP
 * Based on: https://github.com/openclaw/openclaw/issues/7132
 */

const WebSocket = require('ws');
const http = require('http');

const CHROME_PATH = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const CDP_PORT = 18800;
const USER_DATA_DIR = '~/.openclaw/browser/openclaw/user-data';

let ws = null;
let messageId = 1;
const pendingCommands = new Map();

/**
 * Start Chrome with remote debugging
 */
async function startChrome() {
  return new Promise((resolve, reject) => {
    const chrome = require('child_process').spawn(CHROME_PATH, [
      '--remote-debugging-port=' + CDP_PORT,
      '--user-data-dir=' + USER_DATA_DIR,
      '--remote-allow-origins=*',
      'about:blank'
    ]);

    // Give Chrome time to start
    setTimeout(() => {
      resolve(chrome);
    }, 3000);
  });
}

/**
 * Get WebSocket URL from CDP HTTP endpoint
 */
async function getCDPWebSocketURL() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port: CDP_PORT,
      path: '/json',
      method: 'GET'
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const targets = JSON.parse(body);
          const page = targets.find(t => t.type === 'page');
          if (page && page.webSocketDebuggerUrl) {
            resolve(page.webSocketDebuggerUrl);
          } else {
            reject(new Error('No page target found'));
          }
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
 * Connect to CDP via WebSocket
 */
async function connectCDP() {
  return new Promise((resolve, reject) => {
    getCDPWebSocketURL()
      .then(wsUrl => {
        ws = new WebSocket(wsUrl);
        
        ws.on('open', () => {
          console.log('[CDP] Connected to Chrome DevTools Protocol');
          
          // Enable domains we need
          sendCDPCommand('Page.enable');
          sendCDPCommand('Runtime.enable');
          sendCDPCommand('DOM.enable');
          
          resolve();
        });

        ws.on('error', (err) => {
          console.error('[CDP] WebSocket error:', err.message);
          reject(err);
        });

        ws.on('close', () => {
          console.log('[CDP] Connection closed');
          ws = null;
        });
      })
      .catch(reject);
  });
}

/**
 * Send CDP command and wait for result
 */
function sendCDPCommand(method, params = {}) {
  return new Promise((resolve, reject) => {
    if (!ws || ws.readyState !== WebSocket.OPEN) {
      reject(new Error('CDP WebSocket not connected'));
      return;
    }

    const id = messageId++;
    const message = JSON.stringify({ id, method, params });
    
    console.log(`[CDP] Sending: ${method} (id: ${id})`);
    ws.send(message);
    
    // Set up one-time listener for response
    const handler = (data) => {
      try {
        const msg = JSON.parse(data);
        
        // Check if this is a response to our command
        if (msg.id === id) {
          ws.removeListener('message', handler);
          
          if (msg.error) {
            console.error(`[CDP] Error for ${method}:`, msg.error);
            reject(new Error(msg.error.message));
          } else {
            console.log(`[CDP] Result received for ${method}`);
            resolve(msg.result);
          }
        }
      } catch (err) {
        console.error('[CDP] Failed to parse message:', err.message);
      }
    };
    
    ws.on('message', handler);
    
    // Timeout after 15 seconds
    setTimeout(() => {
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.removeListener('message', handler);
        reject(new Error('CDP command timeout'));
      }
    }, 15000);
  });
}

/**
 * Navigate to URL
 */
async function navigate(url) {
  console.log(`[Browser] Navigating to: ${url}`);
  
  try {
    // First enable page if not already enabled
    await sendCDPCommand('Page.enable');
    
    // Navigate to URL
    const navigateResult = await sendCDPCommand('Page.navigate', { url });
    
    if (!navigateResult || navigateResult.errorText) {
      throw new Error(`Navigation failed: ${navigateResult.errorText || 'Unknown error'}`);
    }
    
    // Wait for page to load (frameStoppedLoading)
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Try to get page content
    const contentResult = await sendCDPCommand('Runtime.evaluate', {
      expression: `(() => {
        try {
          return {
            title: document.title,
            url: window.location.href,
            html: document.documentElement ? document.documentElement.outerHTML.substring(0, 2000) : '',
            text: document.body ? document.body.innerText.substring(0, 1000) : ''
          };
        } catch (e) {
          return {
            title: document.title || '',
            url: window.location.href || '',
            html: '',
            text: 'Error: ' + e.message
          };
        }
      })()`,
      returnByValue: true
    });
    
    console.log('[Browser] Content result keys:', Object.keys(contentResult || {}));
    
    // CDP returns nested structure: { result: { type: "object", value: {...} }
    const data = contentResult && contentResult.result ? contentResult.result : contentResult;
    const pageData = data && data.value ? data.value : {};
    
    if (pageData) {
      const preview = pageData.text ? pageData.text.substring(0, 200) : 'N/A';
      console.log(`[Browser] ✅ Navigation complete (title: "${pageData.title}")`);
      console.log(`[Browser] Preview: ${preview}...`);
      return { 
        success: true, 
        title: pageData.title,
        url: pageData.url,
        html: pageData.html,
        text: pageData.text
      };
    } else {
      console.error('[Browser] Content result is null/undefined');
      throw new Error('Failed to get page content');
    }
  } catch (err) {
    console.error(`[Browser] Navigation failed: ${err.message}`);
    throw err;
  }
}

/**
 * Get page content
 */
async function getContent() {
  try {
    const result = await sendCDPCommand('Runtime.evaluate', {
      expression: `({
        title: document.title,
        url: window.location.href,
        html: document.documentElement.outerHTML.substring(0, 2000),
        text: document.body ? document.body.innerText.substring(0, 1000) : ''
      })`,
      returnByValue: true
    });
    
    console.log(`[Browser] ✅ Content retrieved (title: "${result.title}")`);
    return result;
  } catch (err) {
    console.error(`[Browser] Get content failed: ${err.message}`);
    throw err;
  }
}

/**
 * Take screenshot (if needed)
 */
async function screenshot(format = 'png') {
  try {
    await sendCDPCommand('Page.captureScreenshot');
    const result = await sendCDPCommand('Runtime.evaluate', {
      expression: 'window.lastScreenshot',
      returnByValue: true
    });
    console.log('[Browser] ✅ Screenshot captured');
    return result;
  } catch (err) {
    console.error('[Browser] Screenshot failed:', err.message);
    throw err;
  }
}

/**
 * Close CDP connection
 */
function close() {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.close();
    console.log('[CDP] Connection closed');
    ws = null;
  }
}

// CLI interface
if (require.main === module) {
  (async () => {
    const args = process.argv.slice(2);
    const command = args[0] || 'status';

    try {
      switch (command) {
        case 'start':
          await startChrome();
          console.log('[Browser] Chrome started');
          break;
          
        case 'connect':
          await connectCDP();
          break;
          
        case 'navigate':
          if (!args[1]) {
            console.error('[Browser] Usage: node chrome-cdp.js navigate <url>');
            process.exit(1);
          }
          await connectCDP();
          await navigate(args[1]);
          break;
          
        case 'content':
          await connectCDP();
          const content = await getContent();
          console.log(JSON.stringify(content, null, 2));
          break;
          
        case 'screenshot':
          await connectCDP();
          const screenshot = await screenshot();
          break;
          
        case 'status':
          try {
            const wsUrl = await getCDPWebSocketURL();
            console.log('[Browser] Chrome CDP is available');
            console.log('[Browser] WebSocket:', ws && ws.readyState === WebSocket.OPEN ? 'Connected' : 'Not connected');
          } catch (err) {
            console.error('[Browser] Chrome not running:', err.message);
          }
          break;
          
        default:
          console.log('[Browser] Usage:');
          console.log('  node chrome-cdp.js start    - Start Chrome with CDP');
          console.log('  node chrome-cdp.js connect   - Connect to CDP WebSocket');
          console.log('  node chrome-cdp.js status    - Check CDP availability');
          console.log('  node chrome-cdp.js navigate <url> - Navigate to URL and extract content');
          console.log('  node chrome-cdp.js content   - Get current page content (JSON)');
          console.log('  node chrome-cdp.js screenshot - Take screenshot');
      }
    } catch (err) {
      console.error('[Browser] Error:', err.message);
      process.exit(1);
    }
  })();
}

module.exports = { startChrome, connectCDP, navigate, getContent, screenshot, close };
