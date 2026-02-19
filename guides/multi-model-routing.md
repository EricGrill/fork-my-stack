# Multi-Model Routing Guide

I treat model routing as a product decision, not a random config detail.

If you route well, you get:
- better quality where it matters
- much lower spend on recurring work
- faster turnaround on implementation tasks

If you route poorly, you get:
- expensive cron jobs
- slow feedback loops
- lower trust in agent output

This guide is the practical routing system I use in Fork My Stack.

## The core routing philosophy

I split work into three lanes:

1. Frontier lane
   - best reasoning
   - strategy and judgment
   - high-stakes communication
2. Coding lane
   - implementation speed
   - refactors and debugging
   - structured code edits
3. Local lane
   - low recurring cost
   - frequent automation jobs
   - routine transforms and summaries

In this repo, the mapping is:
- frontier: Opus or GPT-4 class
- coding: Codex class
- local: Ollama (`phi4:14b`, `gemma3:27b`, `qwen3:30b`)

## Why this split works

### Frontier models are for thinking quality

Use them when poor reasoning is expensive.

Examples:
- planning a migration
- writing sensitive user-facing decisions
- evaluating tradeoffs across multiple constraints

### Coding models are for shipping

Use them when the output is mostly implementation work.

Examples:
- adding features
- fixing build errors
- updating docs with code examples

### Local models are for recurring throughput

Use them when frequency matters more than top-tier reasoning.

Examples:
- daily pitch generation
- inbox triage
- channel monitoring
- weekly summaries

## Recommended default policy

I like policy before config.

### Policy in plain language

- main conversation defaults to frontier
- project subagents default to coding model
- cron and repetitive background jobs default to local model
- escalation exists when confidence is low

### Policy in config style

```yaml
models:
  default_model: anthropic/claude-opus-4-6

  routing:
    main_session: anthropic/claude-opus-4-6
    subagents: openai-codex/gpt-5.3-codex

    cheap_background: ollama/phi4:14b
    balanced_local: ollama/gemma3:27b
    deep_local: ollama/qwen3:30b

    fallback_frontier: openai/gpt-4.1
```

Use your own provider names as needed.

## Workload matrix I actually use

| Task Type | Risk | Frequency | Default Model | Escalation |
|---|---|---|---|---|
| Strategic planning | High | Medium | Frontier | Alternate frontier |
| User-facing nuanced reply | High | High | Frontier | Alternate frontier |
| Feature implementation | Medium | Medium | Codex | Frontier for design review |
| Refactor and tests | Medium | Medium | Codex | Frontier for failure analysis |
| Daily pitch cron | Low | High | Ollama `phi4:14b` | `gemma3:27b` |
| Weekly summary cron | Low | Medium | Ollama `gemma3:27b` | `qwen3:30b` |
| High-context local synthesis | Medium | Low | Ollama `qwen3:30b` | Frontier |
| Classification/tagging | Low | High | Ollama `phi4:14b` | `gemma3:27b` |

If you want to keep cost under control, this table matters more than any single model benchmark.

## Routing pattern 1: strict role-based routing

This is the easiest pattern to maintain.

```yaml
routingPolicies:
  - name: main-chat
    match:
      sessionType: main
    use: anthropic/claude-opus-4-6

  - name: subagent-coding
    match:
      sessionType: subagent
      intent: code
    use: openai-codex/gpt-5.3-codex

  - name: cron-default
    match:
      trigger: cron
    use: ollama/phi4:14b
```

Use this when you want deterministic behavior.

## Routing pattern 2: budget-aware escalation

I use this when I want the cheapest acceptable model first.

```yaml
routingPolicies:
  - name: recurring-low-risk
    match:
      trigger: cron
      risk: low
    chain:
      - ollama/phi4:14b
      - ollama/gemma3:27b
      - anthropic/claude-opus-4-6
```

Interpretation:
- try cheap local first
- retry on stronger local if output fails validation
- escalate to frontier only when still failing

## Routing pattern 3: latency-sensitive local lane

Some tasks care more about speed than depth.

```yaml
routingPolicies:
  - name: fast-monitoring
    match:
      taskClass: monitoring
      maxLatencyMs: 4000
    use: ollama/phi4:14b

  - name: slow-path-analysis
    match:
      taskClass: analysis
      latencyTolerant: true
    use: ollama/qwen3:30b
```

This keeps user-visible waits lower on high-frequency checks.

## Prompt design by lane

Routing fails when prompts are not lane-aware.

### Frontier prompt style

I ask for:
- explicit assumptions
- options with tradeoffs
- recommended path and rationale

### Coding prompt style

I ask for:
- concrete file edits
- tests or verification steps
- minimal speculative text

### Local prompt style

I ask for:
- strict structure
- short outputs
- deterministic formatting

Example local prompt:

```text
Read the input notes and output JSON only.
Keys: topic, audience, hook, cta.
Limit hook to 18 words.
No extra keys.
```

This greatly improves reliability for cron jobs.

## Validation rules before escalation

I do not escalate blindly.

I validate output first.

### Validation checklist

- correct schema
- non-empty fields
- no policy violations
- useful confidence threshold

If validation fails, then escalate model tier.

Pseudo flow:

```text
run local model
  -> validate
    -> pass: publish result
    -> fail: retry on stronger model
      -> validate
        -> pass: publish result
        -> fail: escalate to frontier
```

## Cost control tactics that work

### 1) Keep frontier out of cron by default

This single rule can dramatically cut monthly spend.

### 2) Bundle repetitive tasks

Instead of 10 tiny frontier calls, run one local summarization pass.

### 3) Cache stable transforms

If a transformation is deterministic, cache it and skip re-generation.

### 4) Use coding model for implementation loops

Do not pay frontier pricing for bulk file edits.

### 5) Add explicit escalation triggers

Only escalate when:
- schema fails twice
- confidence below threshold
- known critical task class

## Reliability tactics

### Maintain fallback providers

Keep at least one alternate frontier model and one alternate local tag.

### Pin model tags intentionally

Avoid accidental upgrades on critical automations.

### Log per-task model choice

I always log:
- selected model
- fallback path used
- latency
- validation pass/fail

That makes routing tuning straightforward.

## Example OpenClaw config starter

```yaml
gateway:
  name: fork-my-stack

models:
  providers:
    anthropic:
      type: anthropic
      apiKey: ${ANTHROPIC_API_KEY}
    openai:
      type: openai
      apiKey: ${OPENAI_API_KEY}
    ollama:
      type: ollama
      baseUrl: http://your-server-ip:11434

  default_model: anthropic/claude-opus-4-6

  routing:
    main_session: anthropic/claude-opus-4-6
    subagents: openai-codex/gpt-5.3-codex
    cheap_background: ollama/phi4:14b
    balanced_local: ollama/gemma3:27b
    deep_local: ollama/qwen3:30b
```

This is enough to get useful routing on day one.

## Example task-to-model map file

I often keep this as a reference artifact.

```yaml
taskMap:
  strategy:
    default: anthropic/claude-opus-4-6
    fallback: openai/gpt-4.1

  coding:
    default: openai-codex/gpt-5.3-codex
    fallback: anthropic/claude-opus-4-6

  cron_monitoring:
    default: ollama/phi4:14b
    fallback: ollama/gemma3:27b

  cron_synthesis:
    default: ollama/gemma3:27b
    fallback: ollama/qwen3:30b

  local_deep_reasoning:
    default: ollama/qwen3:30b
    fallback: anthropic/claude-opus-4-6
```

Simple maps like this reduce confusion across teams.

## Anti-patterns to avoid

- sending every task to one model
- using frontier model for repetitive cron prompts
- using smallest local model for high-stakes reasoning
- routing without output validation
- changing tags without testing

These mistakes are expensive and avoidable.

## Rollout plan in 7 days

Day 1:
- define task classes
- choose default model per class

Day 2:
- implement routing config
- add model usage logging

Day 3:
- move one cron workflow to local lane

Day 4:
- add validation and retry logic

Day 5:
- add escalation triggers

Day 6:
- tune prompts per lane

Day 7:
- compare cost and latency before vs after

## Quick troubleshooting

### Outputs are low quality on local lane

Fixes:
- tighten prompt format
- route to stronger local model
- reduce context noise

### Costs still high

Fixes:
- audit cron routes
- verify subagents are on coding model
- add escalation guardrails

### Latency spikes

Fixes:
- keep local model warm
- reduce concurrent heavy jobs
- reserve heavyweight model for selective tasks

## Final checklist

- [ ] Three-lane routing policy documented
- [ ] Main session mapped to frontier model
- [ ] Subagents mapped to coding model
- [ ] Cron jobs mapped to local models
- [ ] Validation before escalation implemented
- [ ] Fallback chain configured
- [ ] Logging enabled for model choice and latency

Once this is in place, your assistant stack feels faster, costs less, and behaves more predictably.
