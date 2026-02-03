# Chutes Model API Fix - Working Solution

## Date
2026-02-03 10:44 AM

## Issue
Chutes.AI models weren't working when set as the primary model, despite tests working.

## Root Cause
Configuration confusion around provider naming and model ID prefixes.

## Working Solution

**Provider Name:** `chutesai` (NOT `chutes`)

**Model IDs:** WITHOUT prefix
- `deepseek-ai/DeepSeek-V3`
- `deepseek-ai/DeepSeek-R1-TEE`
- `moonshotai/Kimi-K2-Instruct-0905`
- `moonshotai/Kimi-K2.5-TEE`
- `Qwen/Qwen3-235B-A22B-Instruct-2507-TEE`

**Model References (for aliases/selection):** `provider/modelId` format
- `chutesai/deepseek-ai/DeepSeek-V3` → `DS-V3`
- `chutesai/deepseek-ai/DeepSeek-R1-TEE` → `DS-R1`
- `chutesai/moonshotai/Kimi-K2-Instruct-0905` → `Kimi-K2`
- `chutesai/moonshotai/Kimi-K2.5-TEE` → `Kimi-K2.5`
- `chutesai/Qwen/Qwen3-235B-A22B-Instruct-2507-TEE` → `Qwen3`

## What Didn't Work
- Using `chutes/` prefix on model IDs with `chutes` provider name
- Using `chutes/` prefix on model IDs with `chutesai` provider name

## Configuration Files Updated
- `/Users/bclawd/.openclaw/openclaw.json` - Main config
- `/Users/bclawd/.openclaw/agents/main/agent/models.json` - Agent models

## Verified Working
Model successfully switched to: `chutesai/moonshotai/Kimi-K2.5-TEE`
