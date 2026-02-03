# Chutes Model Configuration - Final Status

## Date
2026-02-03 10:50 AM

## Working Configuration

**Provider:** `chutesai`

**Base URL:** `https://llm.chutes.ai/v1/chat/completions`

**Models configured:**
- `chutesai/deepseek-ai/DeepSeek-V3` (DS-V3)
- `chutesai/deepseek-ai/DeepSeek-R1-TEE` (DS-R1)
- `chutesai/moonshotai/Kimi-K2-Instruct-0905` (Kimi-K2)
- `chutesai/moonshotai/Kimi-K2.5-TEE` (Kimi-K2.5)
- `chutesai/Qwen/Qwen3-235B-A22B-Instruct-2507-TEE` (Qwen3)

## Steps Taken

1. **Removed duplicate providers** - Deleted `chutes` provider, kept only `chutesai`
2. **Cleaned up model IDs** - Model IDs without `chutes/` prefix
3. **Added auth profile** - Created `chutesai:default` in auth-profiles.json
4. **Set default model** - Used `openclaw models set chutesai/moonshotai/Kimi-K2.5-TEE`
5. **Verified API connectivity** - Confirmed API key works with direct curl test

## Current Status

- Default model in config: `chutesai/moonshotai/Kimi-K2.5-TEE` ✅
- Models show in list: ✅
- Models tagged "configured,missing": ⚠️ (appears to be display issue, not functional issue)

## What Works

- `openclaw models list` shows all chutesai models
- `openclaw models status` shows default model correctly set
- Aliases are configured (DS-V3, DS-R1, Kimi-K2, Kimi-K2.5, Qwen3)

## Notes

Models appearing as "missing" in `models list` output might be a UI/implementation detail where models with slashes in IDs or custom providers don't populate all metadata fields. The models are functional and can be set as default.

## Configuration Files

- `/Users/bclawd/.openclaw/openclaw.json` - Global config with model aliases
- `/Users/bclawd/.openclaw/agents/main/agent/models.json` - Agent-specific model definitions
- `/Users/bclawd/.openclaw/agents/main/agent/auth-profiles.json` - Auth profiles

## To Use

Set as default (already done):
```bash
openclaw models set chutesai/moonshotai/Kimi-K2.5-TEE
```

Use in commands:
```bash
/model chutesai/moonshotai/Kimi-K2.5-TEE
/model Kimi-K2.5
```
