# Multi-Model Routing Guide

The fastest way to reduce cost and increase quality is to route tasks by model strengths.

## Recommended routing

### 1) Frontier model for conversation

Use a high-quality model (Opus / GPT-4 class) for:
- user-facing conversation
- planning and strategy
- nuanced judgment calls

### 2) Coding model for sub-agents

Use a coding-optimized model (Codex class) for:
- writing code
- refactors
- debugging
- project implementation in isolated sessions

### 3) Local model for cheap monitoring

Use Ollama models for:
- recurring cron checks
- summarization
- low-risk classification/routing
- high-frequency tasks where latency/cost matter

## Example OpenClaw config pattern

```yaml
models:
  routing:
    main_session: anthropic/claude-opus-4-6
    subagents: openai-codex/gpt-5.3-codex
    cheap_background: ollama/mistral:7b
```

## Practical rules

- Don’t spend frontier tokens on repetitive cron checks.
- Don’t use weak local models for high-stakes user responses.
- Keep model responsibilities explicit and documented.

## Suggested rollout

1. Start with one frontier + one coding model
2. Add one local Ollama model for cron tasks
3. Review performance weekly and adjust routing

Routing is a product decision, not just a config tweak.
