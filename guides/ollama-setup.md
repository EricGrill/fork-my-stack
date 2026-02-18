# Ollama Setup Guide

This is the fastest path to getting local inference running for background and low-cost tasks.

## 1) Install Ollama

### macOS/Linux
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Verify
```bash
ollama --version
ollama serve
```

## 2) Pull recommended models

```bash
# quality-focused local model
ollama pull qwen3:30b

# speed-focused lightweight model
ollama pull mistral:7b
```

Recommended split:
- `qwen3:30b` for better reasoning quality
- `mistral:7b` for fast/cheap recurring tasks

## 3) Add Ollama as an OpenClaw model provider

In your gateway config:

```yaml
models:
  providers:
    ollama:
      type: ollama
      baseUrl: http://YOUR_OLLAMA_HOST:11434
```

Then reference models as:
- `ollama/qwen3:30b`
- `ollama/mistral:7b`

## 4) Use the VRAM warm trick

Ollama may unload models after ~5 minutes of idle time.
If you want low-latency responses, schedule a lightweight cron that hits the model every 3-4 minutes.

Example strategy:
- keep one tiny recurring task running at `*/4 * * * *`
- route cheap monitoring prompts through your local model

That keeps the model warm and avoids repeated cold starts.

## 5) Cost comparison

- Cloud API only: variable monthly API spend
- Ollama local for recurring/background tasks: **$0/month in token fees**

You still pay power/hardware cost, but there’s no per-request API bill for local inference.
