# fork-my-stack

This is my personal AI assistant starter kit, packaged so you can fork it and get your own setup running fast.

If you want an assistant that can:
- run all day,
- route work across multiple models,
- monitor your channels,
- maintain memory,
- and automate recurring workflows,
this repo gives you a practical baseline.

Built around:
- **OpenClaw** (agent runtime + channels + tools + crons)
- **Ollama** (optional local inference, $0 token cost)
- **MCP servers** (plug in external capabilities)

---

## What this is

`fork-my-stack` is a copyable scaffold for running a personal AI assistant with:
- a structured workspace (`AGENTS.md`, `SOUL.md`, `USER.md`, memory files)
- multi-model routing (frontier + coding + local)
- channel integrations (WhatsApp / Telegram / Slack / Discord stubs)
- cron-driven automation jobs
- MCP integrations for external tools

It’s designed to get you from zero to useful in an afternoon.

---

## What you get

- **Always-on assistant patterns** for messaging platforms (WhatsApp, Telegram, Slack, Discord)
- **Local GPU inference option** via Ollama for low-cost background tasks
- **Cron automation** for recurring workflows
- **Sub-agent workflow** for isolated project execution
- **Memory system** (daily notes + long-term memory)
- **Blog automation templates** (content pitches, build logs, publishing pipeline)

---

## Prerequisites

### Hardware
- Any machine with **8GB+ RAM**
- Optional GPU machine for local inference with Ollama

### Software
- [Node.js](https://nodejs.org/) (LTS recommended)
- [OpenClaw](https://github.com/EricGrill)
- Optional: [Ollama](https://ollama.com/)

You’ll also want API keys for any cloud providers you enable (Anthropic, OpenAI, messaging platforms, etc.).

---

## Quick start

```bash
# 1) Clone your fork
cd ~/Development
git clone https://github.com/YOUR_USERNAME/fork-my-stack.git
cd fork-my-stack

# 2) Copy templates into your OpenClaw workspace (example)
mkdir -p ~/.openclaw/workspace
cp -R workspace/* ~/.openclaw/workspace/

# 3) Create your gateway config from template
mkdir -p ~/.openclaw/config
cp config/gateway-template.yaml ~/.openclaw/config/gateway.yaml

# 4) Edit gateway config with your keys + channels
$EDITOR ~/.openclaw/config/gateway.yaml

# 5) Start OpenClaw gateway
openclaw gateway start
openclaw gateway status

# 6) Test locally
openclaw help
```

If you’re adding Ollama, follow [`guides/ollama-setup.md`](guides/ollama-setup.md).

If you want model strategy, read [`guides/multi-model-routing.md`](guides/multi-model-routing.md).

---

## Architecture overview

High-level flow:

1. **Channels** (Discord/Slack/Telegram/WhatsApp) feed messages into OpenClaw.
2. **Main agent** handles conversation, planning, and routing.
3. **Sub-agents** handle isolated build tasks.
4. **Model routing** chooses the right model for cost/performance.
5. **MCP servers** provide extra tools (infra, data, finance, automation, etc.).
6. **Memory files** preserve continuity between sessions.
7. **Crons** trigger recurring jobs (monitoring, content, cleanup).

---

## Cost breakdown

### Typically free
- Repo + templates
- Local runtime on your machine
- Ollama local inference (no per-token API fees)

### May cost money
- Cloud LLM APIs (Anthropic/OpenAI/etc.)
- Messaging API/provider usage
- Hosted infra (if you deploy servers)
- Optional paid MCP-connected services

Rule of thumb:
- Use frontier models where quality matters.
- Use coding models for implementation tasks.
- Use local models for recurring/cheap monitoring.

---

## Customization guide

Start here:
- `workspace/SOUL.md` → assistant personality
- `workspace/USER.md` → your context and preferences
- `workspace/AGENTS.md` → operating rules
- `workspace/TOOLS.md` → environment/tool notes
- `workspace/HEARTBEAT.md` → recurring checks

Then configure:
- `config/gateway-template.yaml` for models, channels, MCP
- `crons/*.json` for automations

---

## Links

- GitHub: <https://github.com/EricGrill>
- Blog: <https://ericgrill.com>
- Ollama setup guide: [`guides/ollama-setup.md`](guides/ollama-setup.md)
- MCP server guide: [`guides/mcp-servers.md`](guides/mcp-servers.md)
- Blog automation guide: [`guides/blog-automation.md`](guides/blog-automation.md)
- Multi-model routing guide: [`guides/multi-model-routing.md`](guides/multi-model-routing.md)

If you fork this and improve it, open a PR or publish your variant.
