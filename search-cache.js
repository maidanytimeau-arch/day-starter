#!/usr/bin/env node

/**
 * Search Cache Module
 * 
 * Caches web_search results to reduce API usage
 * Usage: node search-cache.js
 */

const fs = require('fs');
const path = require('path');

const CACHE_FILE = path.join(__dirname, '.search-cache.json');
const CACHE_TTL_MS = 48 * 60 * 60 * 1000; // 48 hours

/**
 * Load cache from disk
 */
function loadCache() {
  try {
    if (fs.existsSync(CACHE_FILE)) {
      const data = fs.readFileSync(CACHE_FILE, 'utf-8');
      return JSON.parse(data);
    }
  } catch (err) {
    console.error(`[Cache] Failed to load cache: ${err.message}`);
  }
  return {};
}

/**
 * Save cache to disk
 */
function saveCache(cache) {
  try {
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
  } catch (err) {
    console.error(`[Cache] Failed to save cache: ${err.message}`);
  }
}

/**
 * Generate cache key from query parameters
 */
function generateCacheKey(params) {
  const key = `${params.query}_${params.count || 5}_${params.freshness || 'all'}`;
  return Buffer.from(key).toString('base64').substring(0, 64);
}

/**
 * Check if cached result is fresh
 */
function isFresh(timestamp) {
  const age = Date.now() - timestamp;
  return age < CACHE_TTL_MS;
}

/**
 * Get cached search result
 */
function getFromCache(params) {
  const cache = loadCache();
  const key = generateCacheKey(params);
  
  if (cache[key] && isFresh(cache[key].timestamp)) {
    const age = Math.round((Date.now() - cache[key].timestamp) / (60 * 60 * 1000));
    console.log(`[Cache] HIT for query "${params.query.substring(0, 50)}" (${age}h old)`);
    return cache[key].results;
  }
  
  console.log(`[Cache] MISS for query "${params.query.substring(0, 50)}"`);
  return null;
}

/**
 * Store search result in cache
 */
function storeInCache(params, results) {
  const cache = loadCache();
  const key = generateCacheKey(params);
  
  cache[key] = {
    results: results,
    timestamp: Date.now(),
    query: params.query,
    freshness: params.freshness
  };
  
  saveCache(cache);
  console.log(`[Cache] STORED for query "${params.query.substring(0, 50)}"`);
}

/**
 * Clean expired cache entries
 */
function cleanExpired() {
  const cache = loadCache();
  const keys = Object.keys(cache);
  let cleaned = 0;
  
  for (const key of keys) {
    if (!isFresh(cache[key].timestamp)) {
      delete cache[key];
      cleaned++;
    }
  }
  
  if (cleaned > 0) {
    saveCache(cache);
    console.log(`[Cache] Cleaned ${cleaned} expired entries`);
  }
  
  return cleaned;
}

/**
 * Get cache statistics
 */
function getStats() {
  const cache = loadCache();
  const keys = Object.keys(cache);
  let fresh = 0;
  let expired = 0;
  
  for (const key of keys) {
    if (isFresh(cache[key].timestamp)) {
      fresh++;
    } else {
      expired++;
    }
  }
  
  return {
    total: keys.length,
    fresh,
    expired,
    ttl: Math.round(CACHE_TTL_MS / (60 * 60 * 1000))
  };
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0] || 'stats';
  
  switch (command) {
    case 'clean':
      cleanExpired();
      break;
    case 'stats':
      const stats = getStats();
      console.log(`[Cache] Stats: ${stats.fresh} fresh, ${stats.expired} expired (TTL: ${stats.ttl}h)`);
      break;
    default:
      console.log('[Cache] Usage:');
      console.log('  node search-cache.js stats   - Show cache statistics');
      console.log('  node search-cache.js clean  - Clean expired entries');
  }
}

module.exports = {
  getFromCache,
  storeInCache,
  cleanExpired,
  getStats,
  generateCacheKey
};
