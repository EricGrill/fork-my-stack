# Ollama Setup Guide

I use Ollama to run local models for recurring tasks, background jobs, and anything I want to keep off paid APIs.

This guide is the exact setup I would use on a fresh machine.

If you follow it top to bottom, you will end with:
- Ollama running as a local inference server
- `qwen3:30b`, `gemma3:27b`, and `phi4:14b` pulled and tested
- basic performance tuning in place
- OpenClaw routing to local models for low-cost work

## Who this is for

Use this if you want any of the following:
- lower monthly AI spend
- better privacy for routine prompts
- faster turnaround for local cron tasks
- an offline-capable fallback when APIs are flaky

I do not recommend local inference as your only model layer if you need top-tier reasoning for every prompt.

My practical split is:
- frontier model for high-stakes strategy
- coding model for implementation tasks
- Ollama for recurring and low-risk workloads

## Step 1: Pick your hardware target first

Before installing anything, decide what model size your GPU can hold comfortably.

### Simple VRAM cheat sheet

- `phi4:14b`
  - comfortable: 12 GB to 16 GB VRAM
  - better: 16 GB+
  - use case: fast classification, summaries, cron prompts
- `gemma3:27b`
  - comfortable: 24 GB VRAM
  - better: 24 GB to 48 GB
  - use case: balanced quality for local assistant work
- `qwen3:30b`
  - comfortable: 24 GB+
  - better: 48 GB for headroom
  - use case: strongest local reasoning in this stack

If you only have CPU, Ollama will still run, but expect slower responses.

If you have multiple GPUs, use the one with the most free VRAM for best stability.

## Step 2: Install Ollama

### macOS and Linux

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Verify install

```bash
ollama --version
```

You should see a version string.

### Start the server

```bash
ollama serve
```

By default, Ollama listens on:

```text
http://127.0.0.1:11434
```

If you want it reachable on your LAN, configure host binding in your service manager and firewall.

## Step 3: Pull the recommended models

These are the three I recommend in this repo.

```bash
ollama pull qwen3:30b
ollama pull gemma3:27b
ollama pull phi4:14b
```

This can take a while depending on bandwidth.

### Check what is installed

```bash
ollama list
```

Expected output should include all three tags.

## Step 4: Run a quick sanity prompt per model

I always run one test prompt for each model before wiring anything else.

```bash
ollama run qwen3:30b "Summarize the value of local inference in 5 bullets."
```

```bash
ollama run gemma3:27b "Write a practical checklist for reducing hallucinations."
```

```bash
ollama run phi4:14b "Classify these tasks into urgent and non-urgent: inbox cleanup, patching, doc edits."
```

If each command returns coherent output, the base setup is good.

## Step 5: Decide task routing by model

I map models to task classes so I never guess at runtime.

### My default local routing

- `qwen3:30b`
  - deeper synthesis
  - architecture drafts
  - complex local reasoning
- `gemma3:27b`
  - everyday assistant tasks
  - medium complexity writing
  - policy-aware transformations
- `phi4:14b`
  - cron checks
  - short summaries
  - tagging, extraction, triage

This gives me a clean quality/latency/cost ladder.

## Step 6: Performance tuning that actually matters

I keep tuning simple and practical.

### 1) Keep prompts concise for local jobs

Local throughput improves when you avoid giant context dumps.

Do this:
- clear objective
- short input
- explicit output format

Avoid this:
- vague prompts
- unnecessary backstory
- giant pasted logs unless needed

### 2) Use warm workloads for recurring jobs

Model cold starts create avoidable latency spikes.

I keep at least one lightweight recurring task every few minutes on whichever model handles cron traffic.

### 3) Separate heavy and light jobs

Do not route short monitoring prompts to your heaviest model if speed matters.

Use `phi4:14b` for high-frequency checks.
Use `qwen3:30b` only when the problem justifies it.

### 4) Watch system pressure

If responses get inconsistent:
- check free VRAM
- check swap usage
- reduce concurrent requests
- move bulk jobs off peak hours

### 5) Cap context for cron workloads

For automation, I prefer strict prompt templates and small context windows.

That keeps latency stable and output predictable.

## Step 7: Configure OpenClaw provider for Ollama

Open your OpenClaw gateway config and add an `ollama` provider.

Example:

```yaml
models:
  providers:
    ollama:
      type: ollama
      baseUrl: http://YOUR_OLLAMA_HOST:11434
```

If OpenClaw runs on the same machine as Ollama, use:

```yaml
baseUrl: http://127.0.0.1:11434
```

If OpenClaw runs on another host on your LAN, use the Ollama server IP:

```yaml
baseUrl: http://your-server-ip:11434
```

Replace with your actual address.

## Step 8: Configure model routing in OpenClaw

Now define routing targets for different workload classes.

```yaml
models:
  default_model: anthropic/claude-opus-4-6

  routing:
    main_session: anthropic/claude-opus-4-6
    subagents: openai-codex/gpt-5.3-codex
    cheap_background: ollama/phi4:14b
    balanced_local: ollama/gemma3:27b
    deep_local: ollama/qwen3:30b
```

This gives you explicit knobs for each type of task.

## Step 9: Validate OpenClaw can hit Ollama

After restarting the gateway, run a small background test task using a local route.

Example prompt:

```text
Summarize these three bullet points and return JSON with keys: summary, risk, next_action.
```

If latency is reasonable and outputs are valid, routing is working.

If it fails:
- verify Ollama is running
- verify host and port
- verify firewall allows access
- verify model tag names match exactly

## Step 10: Production guardrails I always add

### Guardrail 1: Reserve frontier models for high impact work

I do not spend premium tokens on repetitive checks.

### Guardrail 2: Keep cron prompts deterministic

I request structured output:
- JSON keys
- bullet limits
- strict response format

### Guardrail 3: Log model used per task

I keep enough telemetry to answer:
- which model handled this
- how long it took
- was output accepted

### Guardrail 4: Retry strategy

For local jobs:
- first try `phi4:14b`
- retry once on `gemma3:27b` if output quality is weak
- escalate to frontier model only when needed

## Common troubleshooting

### Ollama command works but OpenClaw cannot connect

Likely causes:
- wrong `baseUrl`
- server bound to localhost only
- LAN access blocked by firewall

### Model runs out of memory

Actions:
- switch task to smaller model
- reduce concurrency
- free GPU memory from other processes

### First response is very slow

This is usually a cold start.

Fix:
- warm with a lightweight recurring prompt
- keep one small periodic task active

### Quality is inconsistent

Actions:
- tighten prompts
- reduce context noise
- route hard tasks to bigger local model or frontier model

## My practical defaults

If I was setting this up for a new fork today:

- `phi4:14b` for recurring cron jobs
- `gemma3:27b` for general local assistant work
- `qwen3:30b` for heavier local reasoning
- frontier model only when quality risk is high

That setup keeps costs low and quality predictable.

## Final checklist

- [ ] Ollama installed
- [ ] Ollama server running
- [ ] All three models pulled
- [ ] Per-model sanity prompts passed
- [ ] OpenClaw provider configured
- [ ] Routing rules configured
- [ ] End-to-end local task validated
- [ ] Warm workload strategy in place

If all boxes are checked, you have a production-ready local inference layer for Fork My Stack.
